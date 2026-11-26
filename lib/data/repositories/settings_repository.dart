import '../../core/balancer/balance_request.dart';
import '../../core/models/team_constraint.dart';
import '../../core/scoring/weights.dart';
import '../db/app_database.dart';

/// 모임 설정 (SPEC F10). 모임 데이터와 함께 공유된다.
class GroupPreferences {
  const GroupPreferences({
    this.repeatAvoidance = RepeatAvoidance.medium,
    this.defaultTeamCount = 2,
    this.defaultKeeperMode = KeeperMode.rotation,
    this.weights = BalanceWeights.standard,
  });

  final RepeatAvoidance repeatAvoidance;
  final int defaultTeamCount;
  final KeeperMode defaultKeeperMode;

  /// 밸런스 점수 비중 (전력·공격·수비·포지션).
  final BalanceWeights weights;

  static GroupPreferences fromMap(Map<String, String> m) {
    T byName<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    double w(String key, double fallback) =>
        double.tryParse(m[key] ?? '') ?? fallback;
    const d = BalanceWeights.standard;
    return GroupPreferences(
      repeatAvoidance: byName(
        RepeatAvoidance.values,
        m[keyRepeat],
        RepeatAvoidance.medium,
      ),
      defaultTeamCount: (int.tryParse(m[keyTeamCount] ?? '') ?? 2).clamp(2, 4),
      defaultKeeperMode: byName(
        KeeperMode.values,
        m[keyKeeper],
        KeeperMode.rotation,
      ),
      weights: BalanceWeights(
        strength: w(keyWStrength, d.strength),
        attack: w(keyWAttack, d.attack),
        defense: w(keyWDefense, d.defense),
        position: w(keyWPosition, d.position),
      ),
    );
  }

  static const keyRepeat = 'repeatAvoidance';
  static const keyTeamCount = 'defaultTeamCount';
  static const keyKeeper = 'defaultKeeperMode';
  static const keyWStrength = 'weight.strength';
  static const keyWAttack = 'weight.attack';
  static const keyWDefense = 'weight.defense';
  static const keyWPosition = 'weight.position';
}

class SettingsRepository {
  SettingsRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<Map<String, String>> raw(String groupId) async => {
    for (final r in await (_db.select(
      _db.groupSettings,
    )..where((s) => s.groupId.equals(groupId))).get())
      r.key: r.value,
  };

  Stream<GroupPreferences> watch(String groupId) =>
      (_db.select(
        _db.groupSettings,
      )..where((s) => s.groupId.equals(groupId))).watch().map(
        (rows) =>
            GroupPreferences.fromMap({for (final r in rows) r.key: r.value}),
      );

  Future<GroupPreferences> load(String groupId) async =>
      GroupPreferences.fromMap(await raw(groupId));

  Future<void> set(String groupId, String key, String value) => _db
      .into(_db.groupSettings)
      .insertOnConflictUpdate(
        GroupSettingsCompanion.insert(
          groupId: groupId,
          key: key,
          value: value,
          updatedAt: _now(),
        ),
      );
}
