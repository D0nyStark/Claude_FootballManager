import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/formation.dart';
import '../../core/models/group_role.dart';
import '../db/app_database.dart';

/// 화면에서 쓰는 모임 정보.
class GroupInfo {
  const GroupInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.role,
    required this.defaultFormat,
    required this.onboardingStep,
    required this.lastUsedAt,
    this.myDisplayName,
    this.playerCount = 0,
    this.lastSharedAt,
  });

  factory GroupInfo.fromRow(GroupRow row, {int playerCount = 0}) => GroupInfo(
    id: row.id,
    name: row.name,
    icon: row.icon,
    color: row.color,
    role: row.myRole,
    defaultFormat: row.defaultFormat,
    onboardingStep: row.onboardingStep,
    lastUsedAt: row.lastUsedAt,
    myDisplayName: row.myDisplayName,
    playerCount: playerCount,
    lastSharedAt: row.lastSharedAt,
  );

  /// 생성 마법사 단계 수 (모임 정보·선수 명단·간단 스펙·초대).
  static const int onboardingSteps = 4;

  final String id;
  final String name;
  final String icon;
  final int color;
  final GroupRole role;
  final MatchFormat defaultFormat;
  final int onboardingStep;
  final DateTime lastUsedAt;
  final String? myDisplayName;
  final int playerCount;

  /// 마지막으로 초대·변경 공유를 보내거나 받은 시각.
  final DateTime? lastSharedAt;

  bool get onboardingDone => onboardingStep >= onboardingSteps;
}

/// 모임 저장소 (SPEC F11).
class GroupRepository {
  GroupRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  /// 최근 사용 순 모임 목록 + 선수 수.
  Stream<List<GroupInfo>> watchGroups() {
    final count = _db.players.id.count();
    final query =
        _db.select(_db.groups).join([
            leftOuterJoin(
              _db.players,
              _db.players.groupId.equalsExp(_db.groups.id) &
                  _db.players.deletedAt.isNull(),
              useColumns: false,
            ),
          ])
          ..addColumns([count])
          ..groupBy([_db.groups.id])
          ..orderBy([OrderingTerm.desc(_db.groups.lastUsedAt)]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          GroupInfo.fromRow(
            r.readTable(_db.groups),
            playerCount: r.read(count) ?? 0,
          ),
      ],
    );
  }

  Stream<GroupInfo?> watchGroup(String id) =>
      (_db.select(_db.groups)..where((g) => g.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : GroupInfo.fromRow(r));

  Future<String> createGroup({
    required String name,
    String icon = '⚽',
    int color = 0xFF1B8A3C,
    MatchFormat defaultFormat = MatchFormat.fiveVsFive,
    String? myDisplayName,
    GroupRole role = GroupRole.owner,
    int onboardingStep = 0,
  }) async {
    final id = _uuid.v4();
    final now = _now();
    await _db
        .into(_db.groups)
        .insert(
          GroupsCompanion.insert(
            id: id,
            name: name.trim(),
            icon: Value(icon),
            color: Value(color),
            myRole: role,
            myDisplayName: Value(_blankToNull(myDisplayName)),
            defaultFormat: Value(defaultFormat),
            onboardingStep: Value(onboardingStep),
            createdAt: now,
            updatedAt: now,
            lastUsedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateGroup(
    String id, {
    String? name,
    String? icon,
    int? color,
    MatchFormat? defaultFormat,
    String? Function()? myDisplayName,
  }) => (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
    GroupsCompanion(
      name: name == null ? const Value.absent() : Value(name.trim()),
      icon: Value.absentIfNull(icon),
      color: Value.absentIfNull(color),
      defaultFormat: Value.absentIfNull(defaultFormat),
      myDisplayName: myDisplayName == null
          ? const Value.absent()
          : Value(_blankToNull(myDisplayName())),
      updatedAt: Value(_now()),
    ),
  );

  Future<void> setOnboardingStep(String id, int step) =>
      (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
        GroupsCompanion(onboardingStep: Value(step)),
      );

  /// 초대 링크·변경 공유를 보낸 시각 기록.
  Future<void> markShared(String id) =>
      (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
        GroupsCompanion(lastSharedAt: Value(_now())),
      );

  /// 마지막 공유 이후 바뀐 항목 수 ("공유 안 된 변경 N건", SPEC F13.4).
  /// 한 번도 공유하지 않았으면 null.
  Stream<int?> watchUnsharedChanges(String id) {
    final query = _db.customSelect(
      'SELECT g.last_shared_at AS since, '
      '(SELECT COUNT(*) FROM players p WHERE p.group_id = g.id AND p.updated_at > g.last_shared_at) + '
      '(SELECT COUNT(*) FROM player_constraints c WHERE c.group_id = g.id AND c.updated_at > g.last_shared_at) + '
      '(SELECT COUNT(*) FROM lineup_histories h WHERE h.group_id = g.id AND h.updated_at > g.last_shared_at) + '
      '(SELECT COUNT(*) FROM group_settings s WHERE s.group_id = g.id AND s.updated_at > g.last_shared_at) AS n '
      'FROM groups g WHERE g.id = ?',
      variables: [Variable.withString(id)],
      readsFrom: {
        _db.groups,
        _db.players,
        _db.playerConstraints,
        _db.lineupHistories,
        _db.groupSettings,
      },
    );
    return query.watchSingleOrNull().map((row) {
      if (row == null || row.data['since'] == null) return null;
      return row.read<int>('n');
    });
  }

  /// 모임에 들어갈 때 호출 → 목록에서 최근 사용 순 정렬.
  Future<void> touch(String id) =>
      (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
        GroupsCompanion(lastUsedAt: Value(_now())),
      );

  /// 이 기기에서 모임 삭제(모임 나가기). 선수·제약도 함께 지워진다.
  Future<void> deleteGroup(String id) => _db.transaction(() async {
    await (_db.delete(
      _db.sessionDrafts,
    )..where((d) => d.groupId.equals(id))).go();
    await (_db.delete(
      _db.lineupHistories,
    )..where((h) => h.groupId.equals(id))).go();
    await (_db.delete(
      _db.groupSettings,
    )..where((s) => s.groupId.equals(id))).go();
    await (_db.delete(
      _db.playerConstraints,
    )..where((c) => c.groupId.equals(id))).go();
    await (_db.delete(_db.players)..where((p) => p.groupId.equals(id))).go();
    await (_db.delete(_db.groups)..where((g) => g.id.equals(id))).go();
  });

  static String? _blankToNull(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();
}
