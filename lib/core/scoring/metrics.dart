import '../models/player.dart';
import 'weights.dart';

/// 균형을 비교하는 세 가지 지표.
enum Metric {
  strength('전력'),
  attack('공격'),
  defense('수비');

  const Metric(this.label);

  final String label;
}

/// 선수 한 명의 지표값 (1.0~5.0).
class PlayerMetrics {
  const PlayerMetrics({
    required this.ovr,
    required this.attack,
    required this.defense,
  });

  factory PlayerMetrics.of(
    Player player, [
    IndexWeights weights = IndexWeights.standard,
  ]) => PlayerMetrics(
    ovr: player.stats.ovr,
    attack: weights.attackOf(player.stats),
    defense: weights.defenseOf(player.stats),
  );

  final double ovr;
  final double attack;
  final double defense;

  double operator [](Metric m) => switch (m) {
    Metric.strength => ovr,
    Metric.attack => attack,
    Metric.defense => defense,
  };
}

/// 팀 지표의 슬롯당 평균 x̄ (SPEC §6.3 슬롯 정규화).
///
/// - [fieldSum]/[fieldCount]: 팀의 필드 선수(고정 키퍼 제외) 전체 합계/인원
/// - [slots]: 비교 기준 필드 슬롯 수 F (로테이션 N, 키퍼 고정 N−1)
/// - [deckMean]: 출전 덱 전체 평균 — 부족 팀의 빈 자리를 채우는 가상 선수 값
/// - [starterSum]: 초과 팀의 선발 F명 합계. null이면 팀 평균으로 근사.
double slotAverage({
  required double fieldSum,
  required int fieldCount,
  required int slots,
  required double deckMean,
  double? starterSum,
  double benchBeta = 0.3,
}) {
  if (slots <= 0) return deckMean;
  if (fieldCount == slots) return fieldSum / slots;
  if (fieldCount < slots) {
    return (fieldSum + (slots - fieldCount) * deckMean) / slots;
  }
  final mean = fieldSum / fieldCount;
  if (starterSum == null) return mean;
  return ((1 - benchBeta) * starterSum + benchBeta * mean * slots) / slots;
}

/// 팀 간 차이를 0~100 점수로: 100 × max(0, 1 − (max−min)/maxDiff).
double spreadScore(Iterable<double> teamValues, double maxDiff) {
  if (teamValues.length < 2) return 100;
  var lo = double.infinity;
  var hi = double.negativeInfinity;
  for (final v in teamValues) {
    if (v < lo) lo = v;
    if (v > hi) hi = v;
  }
  final d = hi - lo;
  final s = 1 - d / maxDiff;
  return 100 * (s < 0 ? 0 : s);
}
