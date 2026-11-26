import '../models/player_stats.dart';

/// 공격력·수비력 계산 가중치 (SPEC §4.4). 모임 설정에서 조정 가능.
class IndexWeights {
  const IndexWeights({required this.attack, required this.defense});

  /// 공격력 = 0.30·슈팅 + 0.25·드리블 + 0.20·창의력 + 0.15·스피드 + 0.10·체력
  /// 수비력 = 0.30·피지컬 + 0.30·협력(수비 가담) + 0.15·체력 + 0.15·스피드 + 0.10·패스
  static const IndexWeights standard = IndexWeights(
    attack: {
      Stat.shooting: 0.30,
      Stat.dribbling: 0.25,
      Stat.creativity: 0.20,
      Stat.speed: 0.15,
      Stat.stamina: 0.10,
    },
    defense: {
      Stat.physical: 0.30,
      Stat.teamwork: 0.30,
      Stat.stamina: 0.15,
      Stat.speed: 0.15,
      Stat.passing: 0.10,
    },
  );

  final Map<Stat, double> attack;
  final Map<Stat, double> defense;

  double attackOf(PlayerStats stats) => _weighted(stats, attack);

  double defenseOf(PlayerStats stats) => _weighted(stats, defense);

  static double _weighted(PlayerStats stats, Map<Stat, double> weights) {
    var sum = 0.0;
    var total = 0.0;
    weights.forEach((stat, w) {
      sum += stats[stat] * w;
      total += w;
    });
    return total == 0 ? stats.ovr : sum / total;
  }
}

/// 밸런스 점수 비중 (SPEC §6.5).
class BalanceWeights {
  const BalanceWeights({
    this.strength = 0.30,
    this.attack = 0.30,
    this.defense = 0.30,
    this.position = 0.10,
    this.maxDiff = 0.6,
    this.benchBeta = 0.3,
  });

  static const BalanceWeights standard = BalanceWeights();

  final double strength;
  final double attack;
  final double defense;
  final double position;

  /// 팀 평균 차이가 이 값 이상이면 해당 지표 점수 0 (1~5 스케일).
  final double maxDiff;

  /// 초과 팀에서 후보의 영향 비율 β (SPEC §6.3).
  final double benchBeta;

  double get _sum => strength + attack + defense + position;

  /// 0~100 지표 점수들을 가중 합산.
  double combine({
    required double strength,
    required double attack,
    required double defense,
    required double position,
  }) =>
      (this.strength * strength +
          this.attack * attack +
          this.defense * defense +
          this.position * position) /
      _sum;
}
