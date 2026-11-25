import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/member_type.dart';
import '../../core/models/player.dart';
import '../../core/models/player_stats.dart';
import '../../core/models/position.dart';
import '../../core/models/team_constraint.dart';
import '../db/app_database.dart';

/// 선수·상시 제약 저장소 (SPEC F1). 삭제는 공유 병합을 위해 삭제 표시(tombstone)로 남긴다.
class PlayerRepository {
  PlayerRepository(this._db, this.deviceId, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final String deviceId;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  static String newId() => _uuid.v4();

  // ───────────────────────── 선수 ─────────────────────────

  Stream<List<Player>> watchPlayers(String groupId) =>
      (_db.select(_db.players)
            ..where((p) => p.groupId.equals(groupId) & p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .watch()
          .map((rows) => rows.map(toPlayer).toList());

  Future<List<Player>> players(String groupId) =>
      (_db.select(_db.players)
            ..where((p) => p.groupId.equals(groupId) & p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .get()
          .then((rows) => rows.map(toPlayer).toList());

  /// 새 선수면 추가, 있으면 수정.
  Future<void> savePlayer(String groupId, Player player) async {
    final now = _now();
    final existing = await (_db.select(
      _db.players,
    )..where((p) => p.id.equals(player.id))).getSingleOrNull();
    await _db
        .into(_db.players)
        .insertOnConflictUpdate(
          _companion(groupId, player, existing?.createdAt ?? now, now),
        );
  }

  /// 생성 마법사 ②: 이름만으로 여러 명 추가 (일반멤버 · 아라 · 3점, 간단 입력 상태).
  Future<List<String>> addPlayersByName(
    String groupId,
    Iterable<String> names,
  ) async {
    final ids = <String>[];
    await _db.batch((b) {
      var t = _now();
      for (final name in names) {
        final id = newId();
        ids.add(id);
        final player = Player(
          id: id,
          name: name,
          stats: PlayerStats.uniform(PlayerStats.defaultValue),
          mainPosition: Position.ala,
          statsSimple: true,
        );
        // 입력 순서를 유지하려고 생성 시각을 1ms씩 늘린다.
        t = t.add(const Duration(milliseconds: 1));
        b.insert(_db.players, _companion(groupId, player, t, t));
      }
    });
    return ids;
  }

  Future<void> deletePlayer(String playerId) =>
      (_db.update(_db.players)..where((p) => p.id.equals(playerId))).write(
        PlayersCompanion(
          deletedAt: Value(_now()),
          updatedAt: Value(_now()),
          updatedBy: Value(deviceId),
        ),
      );

  PlayersCompanion _companion(
    String groupId,
    Player p,
    DateTime createdAt,
    DateTime updatedAt,
  ) => PlayersCompanion.insert(
    id: p.id,
    groupId: groupId,
    name: p.name.trim(),
    nickname: Value(p.nickname?.trim().isEmpty ?? true ? null : p.nickname),
    memberType: p.memberType,
    shooting: p.stats[Stat.shooting],
    dribbling: p.stats[Stat.dribbling],
    speed: p.stats[Stat.speed],
    passing: p.stats[Stat.passing],
    physical: p.stats[Stat.physical],
    creativity: p.stats[Stat.creativity],
    teamwork: p.stats[Stat.teamwork],
    mainPosition: p.mainPosition,
    subPositions: Value(p.subPositions.map((e) => e.name).join(',')),
    canKeep: Value(p.canKeep),
    isGuest: Value(p.isGuest),
    statsSimple: Value(p.statsSimple),
    memo: Value(p.memo?.trim().isEmpty ?? true ? null : p.memo),
    createdAt: createdAt,
    updatedAt: updatedAt,
    updatedBy: deviceId,
    deletedAt: const Value(null),
  );

  static Player toPlayer(PlayerRow r) => Player(
    id: r.id,
    name: r.name,
    nickname: r.nickname,
    memberType: r.memberType,
    stats: PlayerStats(
      shooting: r.shooting,
      dribbling: r.dribbling,
      speed: r.speed,
      passing: r.passing,
      physical: r.physical,
      creativity: r.creativity,
      teamwork: r.teamwork,
    ),
    mainPosition: r.mainPosition,
    subPositions: {
      for (final s in r.subPositions.split(','))
        if (s.isNotEmpty) Position.values.byName(s),
    },
    canKeep: r.canKeep,
    isGuest: r.isGuest,
    memo: r.memo,
    statsSimple: r.statsSimple,
  );

  // ───────────────────────── 상시 제약 ─────────────────────────

  Stream<List<TeamConstraint>> watchConstraints(String groupId) =>
      (_db.select(_db.playerConstraints)
            ..where((c) => c.groupId.equals(groupId) & c.deletedAt.isNull()))
          .watch()
          .map(
            (rows) => [
              for (final r in rows)
                if (r.playerIds.split(',').length >= 2)
                  TeamConstraint(
                    id: r.id,
                    type: r.type,
                    playerIds: r.playerIds.split(',').toSet(),
                    note: r.note,
                  ),
            ],
          );

  Future<String> addConstraint(
    String groupId,
    ConstraintType type,
    Set<String> playerIds, {
    String? note,
  }) async {
    final id = newId();
    await _db
        .into(_db.playerConstraints)
        .insert(
          PlayerConstraintsCompanion.insert(
            id: id,
            groupId: groupId,
            type: type,
            playerIds: playerIds.join(','),
            note: Value(note),
            updatedAt: _now(),
            updatedBy: deviceId,
          ),
        );
    return id;
  }

  Future<void> deleteConstraint(String id) =>
      (_db.update(_db.playerConstraints)..where((c) => c.id.equals(id))).write(
        PlayerConstraintsCompanion(
          deletedAt: Value(_now()),
          updatedAt: Value(_now()),
          updatedBy: Value(deviceId),
        ),
      );
}

/// 선수 목록 정렬 기준 (SPEC F1.2).
enum PlayerSort {
  name('이름'),
  ovr('OVR'),
  attack('공격력'),
  defense('수비력');

  const PlayerSort(this.label);

  final String label;
}

/// 주멤버가 먼저 오도록 분리.
({List<Player> core, List<Player> regular}) splitByMemberType(
  Iterable<Player> players,
) => (
  core: [
    for (final p in players)
      if (p.memberType == MemberType.core) p,
  ],
  regular: [
    for (final p in players)
      if (p.memberType == MemberType.regular) p,
  ],
);
