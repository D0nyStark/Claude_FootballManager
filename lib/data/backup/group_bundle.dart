import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../../core/models/formation.dart';
import '../../core/models/group_role.dart';
import '../../core/models/player_stats.dart';
import 'raw_deflate.dart';

/// 모임 데이터 묶음 (SPEC §7.2) — 백업 파일(.mug)과 초대 링크가 같은 형식을 쓴다.
///
/// JSON → deflate 압축 → base64url. 삭제한 항목도 삭제 표시(deletedAt)와 함께 담아
/// 다른 기기에 병합할 때 삭제가 전파되게 한다.
class GroupBundle {
  GroupBundle({
    required this.group,
    required this.players,
    required this.constraints,
    required this.lineups,
    required this.settings,
    required this.exportedAt,
    required this.from,
    this.role,
  });

  static const int schemaVersion = 1;
  static const String prefix = 'MUG1:';

  final Map<String, Object?> group;
  final List<Map<String, Object?>> players;
  final List<Map<String, Object?>> constraints;
  final List<Map<String, Object?>> lineups;
  final List<Map<String, Object?>> settings;
  final DateTime exportedAt;

  /// 보낸 기기 id.
  final String from;

  /// 초대 링크의 역할 (백업 파일은 null).
  final String? role;

  String get groupId => group['id'] as String;
  String get groupName => group['name'] as String;

  int get playerCount => players.where((p) => p['deletedAt'] == null).length;
  int get constraintCount =>
      constraints.where((c) => c['deletedAt'] == null).length;
  int get lineupCount => lineups.where((l) => l['deletedAt'] == null).length;

  Map<String, Object?> toJson() => {
    'v': schemaVersion,
    'at': exportedAt.toUtc().toIso8601String(),
    'from': from,
    'role': role,
    'g': group,
    'players': players,
    'constraints': constraints,
    'lineups': lineups,
    'settings': settings,
  };

  factory GroupBundle.fromJson(Map<String, Object?> j) {
    final v = j['v'] as int? ?? 0;
    if (v < 1 || v > schemaVersion) {
      throw const FormatException('지원하지 않는 백업 버전');
    }
    List<Map<String, Object?>> list(String key) => [
      for (final e in (j[key] as List?) ?? const [])
        (e as Map).cast<String, Object?>(),
    ];
    return GroupBundle(
      group: (j['g'] as Map).cast<String, Object?>(),
      players: list('players'),
      constraints: list('constraints'),
      lineups: list('lineups'),
      settings: list('settings'),
      exportedAt: DateTime.parse(j['at'] as String),
      from: j['from'] as String? ?? '',
      role: j['role'] as String?,
    );
  }

  /// 압축 문자열 ("MUG1:" + base64url).
  String encode() {
    final bytes = deflateRaw(utf8.encode(jsonEncode(toJson())));
    return '$prefix${base64Url.encode(bytes).replaceAll('=', '')}';
  }

  static GroupBundle decode(String text) {
    var s = text.trim();
    final i = s.indexOf(prefix);
    if (i < 0) throw const FormatException('풋살 팀메이커 백업이 아니에요');
    s = s.substring(i + prefix.length).split(RegExp(r'\s')).first;
    final padded = s.padRight((s.length + 3) ~/ 4 * 4, '=');
    final json = utf8.decode(inflateRaw(base64Url.decode(padded)));
    return GroupBundle.fromJson((jsonDecode(json) as Map).cast());
  }
}

/// 가져오기 방식 (SPEC F9).
enum ImportMode {
  /// 이 기기의 모임 데이터를 파일 내용으로 바꾼다.
  overwrite,

  /// 항목별로 더 최근에 수정된 쪽을 남긴다.
  merge,
}

/// 가져오기 결과 요약 ("추가 2 · 수정 5 · 삭제 1").
class ImportSummary {
  int added = 0;
  int updated = 0;
  int deleted = 0;
  bool createdGroup = false;
  bool roleUpgraded = false;

  bool get isEmpty => added == 0 && updated == 0 && deleted == 0;

  @override
  String toString() => '추가 $added · 수정 $updated · 삭제 $deleted';
}

/// DB ↔ 묶음 변환과 병합.
class BundleService {
  BundleService(this._db, this.deviceId, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final String deviceId;
  final DateTime Function() _now;

  static const int keepLineups = 3;

  // ───────────────────────── 내보내기 ─────────────────────────

  Future<GroupBundle> export(String groupId, {String? role}) async {
    final g = await (_db.select(
      _db.groups,
    )..where((t) => t.id.equals(groupId))).getSingle();
    final players = await (_db.select(
      _db.players,
    )..where((t) => t.groupId.equals(groupId))).get();
    final constraints = await (_db.select(
      _db.playerConstraints,
    )..where((t) => t.groupId.equals(groupId))).get();
    final lineups = await (_db.select(
      _db.lineupHistories,
    )..where((t) => t.groupId.equals(groupId))).get();
    final settings = await (_db.select(
      _db.groupSettings,
    )..where((t) => t.groupId.equals(groupId))).get();
    return GroupBundle(
      group: {
        'id': g.id,
        'name': g.name,
        'icon': g.icon,
        'color': g.color,
        'defaultFormat': g.defaultFormat.name,
        'updatedAt': g.updatedAt.toUtc().toIso8601String(),
      },
      players: [for (final p in players) _strip(p.toJson())],
      constraints: [for (final c in constraints) _strip(c.toJson())],
      lineups: [for (final l in lineups) _strip(l.toJson())],
      settings: [for (final s in settings) _strip(s.toJson())],
      exportedAt: _now(),
      from: deviceId,
      role: role,
    );
  }

  /// 모임 id는 묶음 바깥(g)에 있으므로 항목에서는 뺀다 (크기 절약).
  static Map<String, Object?> _strip(Map<String, dynamic> json) =>
      Map<String, Object?>.of(json)..remove('groupId');

  // ───────────────────────── 가져오기 ─────────────────────────

  Future<bool> groupExists(String groupId) async =>
      await (_db.select(
        _db.groups,
      )..where((t) => t.id.equals(groupId))).getSingleOrNull() !=
      null;

  /// [bundle]을 이 기기에 반영한다.
  ///
  /// - 모임이 없으면 [role] 역할로 새로 만든다.
  /// - 이미 있고 [role]이 운영진이면 멤버를 운영진으로 올린다 (내리지는 않는다).
  /// - 능력치가 빠진 묶음(멤버가 보낸 변경)은 이 기기의 능력치를 그대로 둔다.
  Future<ImportSummary> import(
    GroupBundle bundle, {
    required ImportMode mode,
    String role = 'owner',
  }) => _db.transaction(() => _import(bundle, mode, role));

  /// 실제로 저장하지 않고 "추가·수정·삭제" 건수만 계산한다 (변경 사항 미리보기).
  Future<ImportSummary> preview(
    GroupBundle bundle, {
    ImportMode mode = ImportMode.merge,
  }) async {
    ImportSummary? summary;
    try {
      await _db.transaction(() async {
        summary = await _import(bundle, mode, 'member');
        throw const _Rollback();
      });
    } on _Rollback {
      // 되돌림
    }
    return summary!;
  }

  Future<ImportSummary> _import(
    GroupBundle bundle,
    ImportMode mode,
    String role,
  ) async {
    final newGroupRole = role;
    final summary = ImportSummary();
    final gid = bundle.groupId;
    final now = _now();
    final g = bundle.group;
    final existing = await (_db.select(
      _db.groups,
    )..where((t) => t.id.equals(gid))).getSingleOrNull();
    if (existing == null) {
      summary.createdGroup = true;
      await _db
          .into(_db.groups)
          .insert(
            GroupsCompanion.insert(
              id: gid,
              name: g['name'] as String,
              icon: Value(g['icon'] as String? ?? '⚽'),
              color: Value(g['color'] as int? ?? 0xFF1B8A3C),
              myRole: _role(newGroupRole),
              defaultFormat: Value(_format(g['defaultFormat'] as String?)),
              // 초대받은 모임은 생성 마법사가 필요 없다.
              onboardingStep: const Value(4),
              createdAt: now,
              updatedAt: now,
              lastUsedAt: now,
            ),
          );
    } else {
      if (role == GroupRole.manager.name &&
          existing.myRole == GroupRole.member) {
        await (_db.update(_db.groups)..where((t) => t.id.equals(gid))).write(
          const GroupsCompanion(myRole: Value(GroupRole.manager)),
        );
        summary.roleUpgraded = true;
      }
    }
    if (existing != null && mode == ImportMode.overwrite) {
      await (_db.update(_db.groups)..where((t) => t.id.equals(gid))).write(
        GroupsCompanion(
          name: Value(g['name'] as String),
          icon: Value(g['icon'] as String? ?? existing.icon),
          color: Value(g['color'] as int? ?? existing.color),
          updatedAt: Value(now),
        ),
      );
      await (_db.delete(_db.players)..where((t) => t.groupId.equals(gid))).go();
      await (_db.delete(
        _db.playerConstraints,
      )..where((t) => t.groupId.equals(gid))).go();
      await (_db.delete(
        _db.lineupHistories,
      )..where((t) => t.groupId.equals(gid))).go();
      await (_db.delete(
        _db.groupSettings,
      )..where((t) => t.groupId.equals(gid))).go();
    }

    Map<String, Object?> withGroup(Map<String, Object?> j) => {
      ...j,
      'groupId': gid,
    };

    // 선수
    final localPlayers = {
      for (final p in await (_db.select(
        _db.players,
      )..where((t) => t.groupId.equals(gid))).get())
        p.id: p,
    };
    for (final j in bundle.players) {
      var data = withGroup(j);
      if (!data.containsKey('shooting')) {
        // 능력치 없는 변경: 이 기기의 능력치 유지, 새 선수는 기본 3점(간단).
        final local = localPlayers[data['id']]?.toJson();
        data = {
          ...data,
          for (final s in _statKeys) s: local?[s] ?? 3,
          'statsSimple': local?['statsSimple'] ?? true,
        };
      } else if (!data.containsKey('stamina')) {
        // 체력이 없던 예전 백업(1.0.2 이전): 나머지 7개 평균으로 채운다.
        data = {
          ...data,
          'stamina': PlayerStats.legacyStamina([
            for (final s in _statKeys)
              if (s != 'stamina') data[s] as int,
          ]),
        };
      }
      final incoming = PlayerRow.fromJson(data);
      _count(
        summary,
        localPlayers[incoming.id]?.updatedAt,
        localPlayers[incoming.id]?.deletedAt,
        incoming.updatedAt,
        incoming.deletedAt,
      );
      if (_newer(localPlayers[incoming.id]?.updatedAt, incoming.updatedAt)) {
        await _db.into(_db.players).insertOnConflictUpdate(incoming);
      }
    }
    // 상시 제약
    final localConstraints = {
      for (final c in await (_db.select(
        _db.playerConstraints,
      )..where((t) => t.groupId.equals(gid))).get())
        c.id: c,
    };
    for (final j in bundle.constraints) {
      final incoming = ConstraintRow.fromJson(withGroup(j));
      final local = localConstraints[incoming.id];
      _count(
        summary,
        local?.updatedAt,
        local?.deletedAt,
        incoming.updatedAt,
        incoming.deletedAt,
      );
      if (_newer(local?.updatedAt, incoming.updatedAt)) {
        await _db.into(_db.playerConstraints).insertOnConflictUpdate(incoming);
      }
    }
    // 편성 이력: 합친 뒤 최신 3개만 유지
    final localLineups = {
      for (final l in await (_db.select(
        _db.lineupHistories,
      )..where((t) => t.groupId.equals(gid))).get())
        l.id: l,
    };
    for (final j in bundle.lineups) {
      final incoming = LineupHistoryRow.fromJson(withGroup(j));
      final local = localLineups[incoming.id];
      if (_newer(local?.updatedAt, incoming.updatedAt)) {
        await _db.into(_db.lineupHistories).insertOnConflictUpdate(incoming);
      }
    }
    final alive =
        await (_db.select(_db.lineupHistories)
              ..where((t) => t.groupId.equals(gid) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.confirmedAt)]))
            .get();
    for (final old in alive.skip(keepLineups)) {
      await (_db.update(_db.lineupHistories)..where((t) => t.id.equals(old.id)))
          .write(LineupHistoriesCompanion(deletedAt: Value(now)));
    }
    // 모임 설정
    final localSettings = {
      for (final s in await (_db.select(
        _db.groupSettings,
      )..where((t) => t.groupId.equals(gid))).get())
        s.key: s,
    };
    for (final j in bundle.settings) {
      final incoming = GroupSettingRow.fromJson(withGroup(j));
      if (_newer(localSettings[incoming.key]?.updatedAt, incoming.updatedAt)) {
        await _db.into(_db.groupSettings).insertOnConflictUpdate(incoming);
      }
    }
    await (_db.update(_db.groups)..where((t) => t.id.equals(gid))).write(
      GroupsCompanion(lastSharedAt: Value(now)),
    );
    return summary;
  }

  static const _statKeys = [
    'shooting',
    'dribbling',
    'speed',
    'passing',
    'physical',
    'stamina',
    'creativity',
    'teamwork',
  ];

  static bool _newer(DateTime? local, DateTime incoming) =>
      local == null || incoming.isAfter(local);

  static void _count(
    ImportSummary s,
    DateTime? localAt,
    DateTime? localDeleted,
    DateTime incomingAt,
    DateTime? incomingDeleted,
  ) {
    if (localAt == null) {
      if (incomingDeleted == null) s.added++;
      return;
    }
    if (!incomingAt.isAfter(localAt)) return;
    if (incomingDeleted != null && localDeleted == null) {
      s.deleted++;
    } else {
      s.updated++;
    }
  }

  static T _byName<T extends Enum>(List<T> values, String? name, T fallback) =>
      values.where((v) => v.name == name).firstOrNull ?? fallback;

  static GroupRole _role(String name) =>
      _byName(GroupRole.values, name, GroupRole.member);

  static MatchFormat _format(String? name) =>
      _byName(MatchFormat.values, name, MatchFormat.fiveVsFive);
}

class _Rollback implements Exception {
  const _Rollback();
}
