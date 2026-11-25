import '../models/formation.dart';
import '../models/lineup.dart';
import '../models/player.dart';
import '../models/team_constraint.dart';
import 'balance_score.dart';
import 'metrics.dart';
import 'weights.dart';

/// 실제 배치된 편성의 밸런스 점수를 계산한다 (SPEC §6.5).
///
/// 자동 편성 엔진의 최종 평가와 수동 수정 시 실시간 점수가 같은 코드를 쓴다.
class LineupEvaluator {
  LineupEvaluator(
    Iterable<Player> players, {
    this.indexWeights = IndexWeights.standard,
    this.balanceWeights = BalanceWeights.standard,
  }) : _players = {for (final p in players) p.id: p},
       _metrics = {
         for (final p in players) p.id: PlayerMetrics.of(p, indexWeights),
       };

  final IndexWeights indexWeights;
  final BalanceWeights balanceWeights;
  final Map<String, Player> _players;
  final Map<String, PlayerMetrics> _metrics;

  Player player(String id) =>
      _players[id] ?? (throw ArgumentError('알 수 없는 선수: $id'));

  PlayerMetrics metricsOf(String id) =>
      _metrics[id] ?? (throw ArgumentError('알 수 없는 선수: $id'));

  /// 주 포지션도 가능 포지션도 아닌 자리에 배치됐는지 (`↔` 배지).
  bool isOffPosition(String playerId, Slot slot) =>
      !slot.isKeeper && player(playerId).fitFor(slot.position!) == 0;

  BalanceBreakdown evaluate(Lineup lineup) {
    final n = lineup.format.playersPerTeam;
    final fixedMode = lineup.keeperMode == KeeperMode.fixed;

    // 필드 선수 = 팀 전원에서 고정 키퍼 제외.
    final fieldByTeam = <List<String>>[];
    final startersByTeam = <List<String>>[];
    final slotsByTeam = <int>[];
    for (final team in lineup.teams) {
      final keeper = fixedMode ? team.fixedKeeperId : null;
      fieldByTeam.add([
        for (final id in team.playerIds)
          if (id != keeper) id,
      ]);
      startersByTeam.add([
        for (final id in team.starterIds)
          if (id != keeper) id,
      ]);
      slotsByTeam.add(keeper != null ? n - 1 : n);
    }

    final allField = fieldByTeam.expand((e) => e).toList();
    final deckMean = {
      for (final m in Metric.values)
        m: allField.isEmpty
            ? 0.0
            : allField.map((id) => metricsOf(id)[m]).reduce((a, b) => a + b) /
                  allField.length,
    };

    final summaries = <TeamSummary>[];
    final perMetric = {for (final m in Metric.values) m: <double>[]};
    for (var t = 0; t < lineup.teams.length; t++) {
      final field = fieldByTeam[t];
      final starters = startersByTeam[t];
      final values = <Metric, double>{};
      for (final m in Metric.values) {
        final fieldSum = field.fold(0.0, (s, id) => s + metricsOf(id)[m]);
        final starterSum = starters.fold(0.0, (s, id) => s + metricsOf(id)[m]);
        values[m] = slotAverage(
          fieldSum: fieldSum,
          fieldCount: field.length,
          slots: slotsByTeam[t],
          deckMean: deckMean[m]!,
          starterSum: field.length > slotsByTeam[t] ? starterSum : null,
          benchBeta: balanceWeights.benchBeta,
        );
        perMetric[m]!.add(values[m]!);
      }
      final team = lineup.teams[t];
      summaries.add(
        TeamSummary(
          ovr: values[Metric.strength]!,
          attack: values[Metric.attack]!,
          defense: values[Metric.defense]!,
          size: team.size,
          fieldSlots: slotsByTeam[t],
          fieldCount: field.length,
          benchCount: team.bench.length,
        ),
      );
    }

    // 포지션 적합도: 채워진 필드 슬롯(GK 제외)만 계산.
    var fit = 0;
    var maxFit = 0;
    for (final team in lineup.teams) {
      team.slots.forEach((slot, id) {
        if (slot.isKeeper) return;
        fit += player(id).fitFor(slot.position!);
        maxFit += 2;
      });
    }

    final maxDiff = balanceWeights.maxDiff;
    final strength = spreadScore(perMetric[Metric.strength]!, maxDiff);
    final attack = spreadScore(perMetric[Metric.attack]!, maxDiff);
    final defense = spreadScore(perMetric[Metric.defense]!, maxDiff);
    final position = maxFit == 0 ? 100.0 : 100.0 * fit / maxFit;

    return BalanceBreakdown(
      total: balanceWeights.combine(
        strength: strength,
        attack: attack,
        defense: defense,
        position: position,
      ),
      strength: strength,
      attack: attack,
      defense: defense,
      position: position,
      teams: summaries,
    );
  }
}
