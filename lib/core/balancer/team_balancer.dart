import 'dart:math' as math;

import '../models/formation.dart';
import '../models/lineup.dart';
import '../models/player.dart';
import '../models/position.dart';
import '../models/team_constraint.dart';
import '../scoring/balance_score.dart';
import '../scoring/lineup_evaluator.dart';
import '../scoring/metrics.dart';
import '../scoring/position_fit.dart';
import '../scoring/weights.dart';
import 'balance_request.dart';
import 'balance_result.dart';
import 'repetition.dart';
import 'team_sizes.dart';

/// 자동 팀 편성 엔진 (SPEC §6).
///
/// 1. 팀 나누기: 공격·수비·전력 균형 중심의 비용 함수를 시뮬레이티드 어닐링으로 최소화
/// 2. 자리 배치: 팀마다 포지션 원 배치를 완전 탐색, 초과 팀은 후보 선정
///
/// Flutter에 의존하지 않는 순수 Dart 코드다.
class TeamBalancer {
  const TeamBalancer({
    this.indexWeights = IndexWeights.standard,
    this.balanceWeights = BalanceWeights.standard,
  });

  final IndexWeights indexWeights;
  final BalanceWeights balanceWeights;

  /// 밸런스 보호: 반복 회피 때문에 이 점수 이상 손해 보지 않는다 (SPEC §6.6).
  static const double balanceTolerance = 2.0;

  /// 편성안끼리 최소 이만큼 달라야 한다 (SPEC §6.7-5).
  static const double minDistinctness = 0.3;

  /// 직전 편성의 후보였던 선수를 다시 후보로 고를 때의 작은 페널티.
  static const double repeatBenchPenalty = 0.05;

  BalanceResult balance(BalanceRequest request) {
    // 모임 설정의 밸런스 비중이 요청에 있으면 그것을 쓴다 (SPEC F10).
    final ctx = _Context.build(
      request,
      indexWeights,
      request.balanceWeights ?? balanceWeights,
    );
    if (ctx.issues.isNotEmpty) return BalanceFailure(ctx.issues);

    final repWeight = ctx.repetition.isEmpty
        ? 0.0
        : request.repeatAvoidance.weight;

    // 반복 회피를 켠 탐색과, 밸런스 보호 기준을 구하기 위한 회피 없는 탐색.
    final found = <_Candidate>[];
    final seen = <String>{};
    void addCandidate(List<int> state) {
      final key = ctx.signature(state);
      if (!seen.add(key)) return;
      found.add(ctx.realize(state, repWeight));
    }

    for (var r = 0; r < request.restarts; r++) {
      final rng = math.Random(request.seed * 7919 + r);
      final initial = ctx.initialState(rng, noise: r == 0 ? 0 : 0.35);
      final best = ctx.anneal(initial, rng, request.iterations, repWeight);
      for (final s in best) {
        addCandidate(s);
      }
    }

    var bestPure = found.map((c) => c.balance.total).fold(0.0, math.max);
    if (repWeight > 0) {
      final pureRuns = math.max(2, request.restarts ~/ 3);
      for (var r = 0; r < pureRuns; r++) {
        final rng = math.Random(request.seed * 104729 + r + 1);
        final initial = ctx.initialState(rng, noise: r == 0 ? 0 : 0.35);
        final best = ctx.anneal(initial, rng, request.iterations, 0);
        for (final s in best) {
          bestPure = math.max(bestPure, ctx.realize(s, 0).balance.total);
        }
      }
    }

    // 제약을 가장 많이 지킨 후보만 남긴다. 모두 지킬 수 없으면 알림 없이 최대한 지킨 편성을 쓴다.
    final fewest = found.map((c) => c.violations.length).reduce(math.min);
    final valid = found.where((c) => c.violations.length == fewest).toList();

    // 밸런스 보호 → 비용 순 정렬 → 서로 충분히 다른 편성안 선택.
    var pool = valid;
    if (repWeight > 0) {
      final protected = valid
          .where((c) => c.balance.total >= bestPure - balanceTolerance)
          .toList();
      if (protected.isNotEmpty) pool = protected;
    }
    pool.sort((a, b) {
      final byCost = a.cost.compareTo(b.cost);
      return byCost != 0 ? byCost : a.signature.compareTo(b.signature);
    });

    final avoid = [
      for (final l in request.avoidLineups)
        [for (final t in l.teams) t.playerIds],
    ];
    final picked = <_Candidate>[];
    for (final threshold in [minDistinctness, 0.15, 0.0]) {
      for (final c in pool) {
        if (picked.length >= request.maxCandidates) break;
        if (picked.contains(c)) continue;
        final teams = c.teamSets;
        final farFromPicked = picked.every(
          (p) => lineupDistance(p.teamSets, teams) >= threshold && p != c,
        );
        final farFromAvoid = avoid.every(
          (a) => lineupDistance(a, teams) >= math.max(threshold, 1e-9),
        );
        if (farFromPicked && farFromAvoid) picked.add(c);
      }
      if (picked.length >= request.maxCandidates) break;
    }
    if (picked.isEmpty) picked.add(pool.first);

    return BalanceSuccess([
      for (final c in picked)
        LineupCandidate(
          lineup: c.lineup,
          balance: c.balance,
          repetitionPenalty: c.repetition,
          repeatedPairs: c.repeatedPairs,
          unmetConstraints: c.violations,
        ),
    ]);
  }
}

/// 키퍼 고정 모드의 [자동 배정]: 키퍼 가능 선수 중 무작위로 팀별 1명.
Map<int, String> autoAssignKeepers(
  List<Player> deck,
  int teamCount,
  math.Random rng,
) {
  final keepers = deck.where((p) => p.canKeep).toList()..shuffle(rng);
  return {
    for (var t = 0; t < teamCount && t < keepers.length; t++) t: keepers[t].id,
  };
}

class _Candidate {
  _Candidate({
    required this.lineup,
    required this.balance,
    required this.repetition,
    required this.repeatedPairs,
    required this.cost,
    required this.violations,
    required this.signature,
  });

  final Lineup lineup;
  final BalanceBreakdown balance;
  final double repetition;
  final int repeatedPairs;
  final double cost;
  final List<TeamConstraint> violations;
  final String signature;

  late final List<Set<String>> teamSets = [
    for (final t in lineup.teams) t.playerIds,
  ];
}

/// 한 번의 편성 요청에 대한 전처리 결과와 탐색 도구.
class _Context {
  _Context._(this.request, this.evaluator, this.balanceWeights);

  final BalanceRequest request;
  final LineupEvaluator evaluator;
  final BalanceWeights balanceWeights;
  final issues = <BalanceIssue>[];

  late final List<Player> players;
  late final int n;
  late final int k;
  late final int slotsN;
  late final Map<Position, int> demand;
  late final List<List<double>> metric; // [Metric.index][player]
  late final List<double> deckMean; // [Metric.index]
  late final List<int> fixedKeeperOfTeam; // -1 없음
  late final List<bool> isFixedKeeper;
  late List<List<int>> units;
  late List<int> unitPinnedTeam;
  late List<int> movableUnits;
  late final List<int> targetSizes;
  late final List<List<int>> apartPairs; // [i, j, constraintIndex]
  late final List<TeamConstraint> apartConstraints;
  late final Set<int> pinnedPlayers;
  late final Map<int, Slot> pinnedSlot;
  late final Set<String> previousBench;
  late final RepetitionModel repetition;

  static _Context build(
    BalanceRequest req,
    IndexWeights indexWeights,
    BalanceWeights balanceWeights,
  ) {
    final ctx = _Context._(
      req,
      LineupEvaluator(
        req.players,
        indexWeights: indexWeights,
        balanceWeights: balanceWeights,
      ),
      balanceWeights,
    );
    ctx._prepare();
    return ctx;
  }

  void _prepare() {
    // 입력 순서와 무관하게 결정적인 결과를 내기 위해 id로 정렬.
    players = [...request.players]..sort((a, b) => a.id.compareTo(b.id));
    n = players.length;
    k = request.teamCount;
    slotsN = request.format.playersPerTeam;
    demand = request.format.positionDemand;
    repetition = RepetitionModel([
      for (final p in players) p.id,
    ], request.history);
    previousBench = request.history.isEmpty
        ? const {}
        : request.history.first.bench;

    if (k < BalanceRequest.minTeams || k > BalanceRequest.maxTeams) {
      issues.add(
        BalanceIssue(
          '팀 수는 ${BalanceRequest.minTeams}~${BalanceRequest.maxTeams}팀이어야 해요.',
        ),
      );
      return;
    }
    if (n < k) {
      issues.add(BalanceIssue('출전 인원($n명)이 팀 수($k팀)보다 적어요.'));
      return;
    }
    if ({for (final p in players) p.id}.length != n) {
      issues.add(const BalanceIssue('출전 덱에 같은 선수가 중복되어 있어요.'));
      return;
    }

    final index = {for (var i = 0; i < n; i++) players[i].id: i};
    metric = [
      for (final m in Metric.values)
        [for (final p in players) evaluator.metricsOf(p.id)[m]],
    ];

    // 고정 키퍼.
    fixedKeeperOfTeam = List.filled(k, -1);
    isFixedKeeper = List.filled(n, false);
    if (request.keeperMode == KeeperMode.fixed) {
      request.fixedKeepers.forEach((team, id) {
        // 잘못된 지정(덱에 없음, 팀 번호 오류, 중복)은 조용히 무시한다.
        final i = index[id];
        if (team < 0 || team >= k || i == null || isFixedKeeper[i]) return;
        fixedKeeperOfTeam[team] = i;
        isFixedKeeper[i] = true;
      });
    }

    final field = [
      for (var i = 0; i < n; i++)
        if (!isFixedKeeper[i]) i,
    ];
    deckMean = [
      for (final m in Metric.values)
        field.isEmpty
            ? 0.0
            : field.map((i) => metric[m.index][i]).reduce((a, b) => a + b) /
                  field.length,
    ];

    // 고정(Pin): 팀 고정 + 고정 키퍼.
    final pinTeam = List.filled(n, -1);
    pinnedPlayers = {};
    pinnedSlot = {};
    request.pinnedTeams.forEach((id, team) {
      final i = index[id];
      if (i == null || team < 0 || team >= k) return;
      pinTeam[i] = team;
      pinnedPlayers.add(i);
      final slot = request.pinnedSlots[id];
      if (slot != null && request.format.slots.contains(slot)) {
        pinnedSlot[i] = slot;
      }
    });
    for (var t = 0; t < k; t++) {
      final i = fixedKeeperOfTeam[t];
      if (i < 0) continue;
      pinTeam[i] = t; // 키퍼 고정이 선수 고정보다 우선.
      pinnedSlot[i] = Slot.gk;
    }

    // "같은 팀" 제약 → 묶음(unit). Union-Find.
    final parent = List.generate(n, (i) => i);
    int find(int x) => parent[x] == x ? x : (parent[x] = find(parent[x]));
    final apart = <TeamConstraint>[];
    for (final c in request.constraints) {
      final members = [
        for (final id in c.playerIds)
          if (index.containsKey(id)) index[id]!,
      ];
      if (members.length < 2) continue;
      if (c.type == ConstraintType.together) {
        for (final m in members.skip(1)) {
          parent[find(m)] = find(members.first);
        }
      } else {
        apart.add(c);
      }
    }
    final groups = <int, List<int>>{};
    for (var i = 0; i < n; i++) {
      groups.putIfAbsent(find(i), () => []).add(i);
    }
    units = groups.values.toList();
    unitPinnedTeam = [];
    for (final u in units) {
      // 묶음 안의 고정 팀이 서로 다르면 고정 키퍼 → 먼저 나온 고정 순으로 하나만 따른다.
      final keeper = u.where((i) => isFixedKeeper[i]);
      final pinned = u.where((i) => pinTeam[i] >= 0);
      unitPinnedTeam.add(
        keeper.isNotEmpty
            ? pinTeam[keeper.first]
            : (pinned.isNotEmpty ? pinTeam[pinned.first] : -1),
      );
    }

    // "다른 팀" 제약 → 쌍 목록. 같은 묶음 안에 있으면 불가능.
    apartConstraints = apart;
    apartPairs = [];
    for (var c = 0; c < apart.length; c++) {
      final members = [
        for (final id in apart[c].playerIds)
          if (index.containsKey(id)) index[id]!,
      ];
      for (var a = 0; a < members.length; a++) {
        for (var b = a + 1; b < members.length; b++) {
          // "같은 팀"과 "다른 팀"이 함께 걸린 쌍은 "같은 팀"을 따른다.
          if (find(members[a]) == find(members[b])) continue;
          apartPairs.add([members[a], members[b], c]);
        }
      }
    }

    targetSizes = distributeTeamSizes(n, k);
    _repairFeasibility();
  }

  /// 팀 정원 안에 들어가지 않는 고정·묶음을 조용히 풀어 항상 편성할 수 있게 한다.
  /// 1) 한 팀에 고정된 인원이 정원보다 많으면 키퍼가 아닌 고정 묶음부터 고정 해제
  /// 2) 묶음을 팀 정원에 나눠 담을 수 없으면 가장 큰 묶음부터 개인으로 분리
  void _repairFeasibility() {
    while (true) {
      final pinnedCount = _pinnedCounts();
      final order = _teamsByPinned(pinnedCount);
      final over = [
        for (var r = 0; r < k; r++)
          if (pinnedCount[order[r]] > targetSizes[r]) order[r],
      ];
      if (over.isEmpty) break;
      final t = over.first;
      final candidates =
          [
            for (var u = 0; u < units.length; u++)
              if (unitPinnedTeam[u] == t) u,
          ]..sort((a, b) {
            final ka = units[a].any((i) => isFixedKeeper[i]) ? 1 : 0;
            final kb = units[b].any((i) => isFixedKeeper[i]) ? 1 : 0;
            return ka != kb ? ka - kb : units[b].length - units[a].length;
          });
      final u = candidates.first;
      if (units[u].any((i) => isFixedKeeper[i]) && units[u].length > 1) {
        _split(u); // 키퍼 묶음은 키퍼만 남기고 분리
      } else {
        unitPinnedTeam[u] = -1;
        for (final i in units[u]) {
          pinnedPlayers.remove(i);
          pinnedSlot.remove(i);
        }
      }
    }
    while (!_packable()) {
      final blocks = [
        for (var u = 0; u < units.length; u++)
          if (units[u].length > 1) u,
      ]..sort((a, b) => units[b].length.compareTo(units[a].length));
      if (blocks.isEmpty) break;
      _split(blocks.first);
    }
    movableUnits = [
      for (var u = 0; u < units.length; u++)
        if (unitPinnedTeam[u] < 0) u,
    ];
  }

  /// 묶음을 개인 단위로 분리. 고정 키퍼만 팀 고정을 유지한다.
  void _split(int u) {
    final members = units[u];
    final team = unitPinnedTeam[u];
    units.removeAt(u);
    unitPinnedTeam.removeAt(u);
    for (final i in members) {
      final keep = isFixedKeeper[i];
      units.add([i]);
      unitPinnedTeam.add(keep ? team : -1);
      if (!keep) {
        pinnedPlayers.remove(i);
        pinnedSlot.remove(i);
      }
    }
  }

  List<int> _pinnedCounts() {
    final count = List.filled(k, 0);
    for (var u = 0; u < units.length; u++) {
      if (unitPinnedTeam[u] >= 0) count[unitPinnedTeam[u]] += units[u].length;
    }
    return count;
  }

  List<int> _teamsByPinned(List<int> pinnedCount) =>
      List.generate(k, (t) => t)..sort((a, b) {
        final c = pinnedCount[b].compareTo(pinnedCount[a]);
        return c != 0 ? c : a.compareTo(b);
      });

  /// 팀별 정원: 고정 인원이 많은 팀에 큰 정원.
  List<int> _capacities() {
    final order = _teamsByPinned(_pinnedCounts());
    final capacity = List.filled(k, 0);
    for (var r = 0; r < k; r++) {
      capacity[order[r]] = targetSizes[r];
    }
    return capacity;
  }

  /// 고정 인원 + 묶음(큰 것부터 First-Fit)을 정원 안에 담을 수 있는지.
  bool _packable() {
    final capacity = _capacities();
    final count = _pinnedCounts();
    final blocks = [
      for (var u = 0; u < units.length; u++)
        if (unitPinnedTeam[u] < 0 && units[u].length > 1) units[u].length,
    ]..sort((a, b) => b - a);
    for (final size in blocks) {
      var best = -1;
      for (var t = 0; t < k; t++) {
        if (count[t] + size > capacity[t]) continue;
        if (best < 0 || capacity[t] - count[t] > capacity[best] - count[best]) {
          best = t;
        }
      }
      if (best < 0) return false;
      count[best] += size;
    }
    return true;
  }

  // ───────────────────────── 초기해 ─────────────────────────

  /// 고정 → 묶음(큰 것부터) → 개인(OVR 스네이크 드래프트) 순서로 배치.
  /// [noise]는 재시작마다 다른 출발점을 만들기 위한 정렬 흔들기.
  List<int> initialState(math.Random rng, {double noise = 0}) {
    final state = List.filled(units.length, -1);
    final count = List.filled(k, 0);
    final teamOfPlayer = List.filled(n, -1);

    final capacity = _capacities();

    int apartHits(int u, int t) {
      var hits = 0;
      for (final pair in apartPairs) {
        final inU0 = units[u].contains(pair[0]);
        final inU1 = units[u].contains(pair[1]);
        if (inU0 && teamOfPlayer[pair[1]] == t) hits++;
        if (inU1 && teamOfPlayer[pair[0]] == t) hits++;
      }
      return hits;
    }

    void place(int u, int t) {
      state[u] = t;
      count[t] += units[u].length;
      for (final i in units[u]) {
        teamOfPlayer[i] = t;
      }
    }

    for (var u = 0; u < units.length; u++) {
      final t = unitPinnedTeam[u];
      if (t < 0) continue;
      place(u, t); // _repairFeasibility()가 정원 안에 들어감을 보장
    }

    // 묶음: 남은 자리가 가장 많은 팀부터 (_packable()과 같은 규칙).
    final blocks = [
      for (final u in movableUnits)
        if (units[u].length > 1) u,
    ]..sort((a, b) => units[b].length.compareTo(units[a].length));
    for (final u in blocks) {
      var bestTeam = -1;
      for (var t = 0; t < k; t++) {
        if (count[t] + units[u].length > capacity[t]) continue;
        if (bestTeam < 0) {
          bestTeam = t;
          continue;
        }
        final hits = apartHits(u, t).compareTo(apartHits(u, bestTeam));
        final room = (capacity[bestTeam] - count[bestTeam]).compareTo(
          capacity[t] - count[t],
        );
        if (hits < 0 || (hits == 0 && room > 0)) bestTeam = t;
      }
      place(u, bestTeam < 0 ? _mostRoom(capacity, count) : bestTeam);
    }

    final singles = [
      for (final u in movableUnits)
        if (units[u].length == 1) u,
    ];
    final key = {
      for (final u in singles)
        u:
            metric[Metric.strength.index][units[u].first] +
            (noise > 0 ? (rng.nextDouble() * 2 - 1) * noise : 0),
    };
    singles.sort((a, b) => key[b]!.compareTo(key[a]!));

    var pick = 0;
    for (final u in singles) {
      // 스네이크 순서: 0,1,..,k-1,k-1,..,0,0,1,...
      final round = pick ~/ k;
      final pos = pick % k;
      final preferred = round.isEven ? pos : k - 1 - pos;
      pick++;
      int? chosen;
      for (var step = 0; step < k; step++) {
        final t = (preferred + step) % k;
        if (count[t] >= capacity[t]) continue;
        if (apartHits(u, t) == 0) {
          chosen = t;
          break;
        }
        chosen ??= t;
      }
      place(u, chosen ?? _mostRoom(capacity, count));
    }
    return state;
  }

  int _mostRoom(List<int> capacity, List<int> count) {
    var best = 0;
    for (var t = 1; t < k; t++) {
      if (capacity[t] - count[t] > capacity[best] - count[best]) best = t;
    }
    return best;
  }

  // ───────────────────────── 근사 비용 ─────────────────────────

  List<List<int>> teamsOf(List<int> state) {
    final teams = List.generate(k, (_) => <int>[]);
    for (var u = 0; u < units.length; u++) {
      teams[state[u]].addAll(units[u]);
    }
    return teams;
  }

  int violationCount(List<int> teamOfPlayer) {
    var v = 0;
    for (final pair in apartPairs) {
      if (teamOfPlayer[pair[0]] == teamOfPlayer[pair[1]]) v++;
    }
    return v;
  }

  /// 포지션 쏠림 페널티: 같은 주 포지션이 한 팀에 과도하게 몰림.
  double styleSpreadPenalty(List<List<int>> teams) {
    var penalty = 0.0;
    for (final pos in Position.values) {
      var lo = 1 << 30, hi = -1;
      for (final team in teams) {
        var c = 0;
        for (final i in team) {
          if (!isFixedKeeper[i] && players[i].mainPosition == pos) c++;
        }
        lo = math.min(lo, c);
        hi = math.max(hi, c);
      }
      if (hi - lo > 1) penalty += hi - lo - 1;
    }
    return penalty;
  }

  /// 탐색용 빠른 비용 (낮을수록 좋음). 초과 팀은 팀 평균, 포지션은 그룹 매칭으로 근사.
  double approxCost(List<int> state, double repWeight) {
    final teams = teamsOf(state);
    final teamOfPlayer = List.filled(n, -1);
    for (var t = 0; t < k; t++) {
      for (final i in teams[t]) {
        teamOfPlayer[i] = t;
      }
    }

    final perMetric = List.generate(Metric.values.length, (_) => <double>[]);
    var fitSum = 0.0;
    var fillSum = 0;
    for (var t = 0; t < k; t++) {
      final hasKeeper = fixedKeeperOfTeam[t] >= 0;
      final f = hasKeeper ? slotsN - 1 : slotsN;
      final field = [
        for (final i in teams[t])
          if (!isFixedKeeper[i]) i,
      ];
      for (final m in Metric.values) {
        var sum = 0.0;
        for (final i in field) {
          sum += metric[m.index][i];
        }
        perMetric[m.index].add(
          slotAverage(
            fieldSum: sum,
            fieldCount: field.length,
            slots: f,
            deckMean: deckMean[m.index],
          ),
        );
      }
      final fill = hasKeeper
          ? math.min(field.length, slotsN - 1)
          : math.min(field.length, slotsN) - 1;
      if (fill > 0) {
        fitSum +=
            estimateFitRatio(
              [for (final i in field) players[i]],
              demand,
              fill,
            ) *
            fill;
        fillSum += fill;
      }
    }

    final maxDiff = balanceWeights.maxDiff;
    final score = balanceWeights.combine(
      strength: spreadScore(perMetric[Metric.strength.index], maxDiff),
      attack: spreadScore(perMetric[Metric.attack.index], maxDiff),
      defense: spreadScore(perMetric[Metric.defense.index], maxDiff),
      position: fillSum == 0 ? 100 : 100 * fitSum / fillSum,
    );
    return (100 - score) +
        repWeight * repetition.penalty(teams) +
        styleSpreadPenalty(teams) +
        1000.0 * violationCount(teamOfPlayer);
  }

  // ───────────────────────── 시뮬레이티드 어닐링 ─────────────────────────

  /// 반환: 이번 실행에서 찾은 가장 좋은 상태들 (최대 4개, 서로 다른 것).
  List<List<int>> anneal(
    List<int> initial,
    math.Random rng,
    int iterations,
    double repWeight,
  ) {
    var state = List.of(initial);
    var cost = approxCost(state, repWeight);
    final elites = <(double, List<int>)>[(cost, List.of(state))];
    if (movableUnits.isEmpty) return [state];

    final sizes = List.filled(k, 0);
    for (var u = 0; u < units.length; u++) {
      sizes[state[u]] += units[u].length;
    }

    const t0 = 4.0, tEnd = 0.02;
    for (var it = 0; it < iterations; it++) {
      final temp = t0 * math.pow(tEnd / t0, it / iterations);
      final u = movableUnits[rng.nextInt(movableUnits.length)];
      final a = state[u];
      var b = rng.nextInt(k - 1);
      if (b >= a) b++;

      // 후보 이동: 교환(swap) 또는 이동(move). 팀 인원 구성(멀티셋)은 유지.
      int? v;
      if (rng.nextDouble() < 0.7) {
        final inB = [
          for (final w in movableUnits)
            if (state[w] == b) w,
        ];
        if (inB.isNotEmpty) v = inB[rng.nextInt(inB.length)];
      }
      final su = units[u].length;
      final sv = v == null ? 0 : units[v].length;
      final newA = sizes[a] - su + sv;
      final newB = sizes[b] - sv + su;
      final keeps =
          (newA == sizes[a] && newB == sizes[b]) ||
          (newA == sizes[b] && newB == sizes[a]);
      if (!keeps) continue;

      state[u] = b;
      if (v != null) state[v] = a;
      final next = approxCost(state, repWeight);
      final delta = next - cost;
      if (delta <= 0 || rng.nextDouble() < math.exp(-delta / temp)) {
        cost = next;
        sizes[a] = newA;
        sizes[b] = newB;
        _offerElite(elites, cost, state);
      } else {
        state[u] = a;
        if (v != null) state[v] = b;
      }
    }
    return [for (final e in elites) e.$2];
  }

  void _offerElite(List<(double, List<int>)> elites, double cost, List<int> s) {
    const maxElites = 4;
    if (elites.length >= maxElites && cost >= elites.last.$1) return;
    final key = signature(s);
    if (elites.any((e) => signature(e.$2) == key)) return;
    elites.add((cost, List.of(s)));
    elites.sort((x, y) => x.$1.compareTo(y.$1));
    if (elites.length > maxElites) elites.removeLast();
  }

  /// 팀 번호를 바꿔도 같은 편성이면 같은 서명 (고정이 없는 팀끼리는 순서 무관).
  String signature(List<int> state) {
    final teams = teamsOf(state);
    final parts = <String>[];
    for (var t = 0; t < k; t++) {
      final ids = [for (final i in teams[t]) players[i].id]..sort();
      final anchored = _teamHasAnchor(t);
      parts.add('${anchored ? 't$t' : ''}[${ids.join(',')}]');
    }
    final anchored = [
      for (var t = 0; t < k; t++)
        if (_teamHasAnchor(t)) parts[t],
    ];
    final free = [
      for (var t = 0; t < k; t++)
        if (!_teamHasAnchor(t)) parts[t],
    ]..sort();
    return [...anchored, ...free].join('|');
  }

  bool _teamHasAnchor(int t) =>
      fixedKeeperOfTeam[t] >= 0 || unitPinnedTeam.contains(t);

  // ───────────────────────── 실제 배치 (자리·후보) ─────────────────────────

  _Candidate realize(List<int> state, double repWeight) {
    final teams = teamsOf(state);
    final benchEligible = <int, List<int>>{};
    final benchSize = List.filled(k, 0);
    final bench = List.generate(k, (_) => <int>[]);

    for (var t = 0; t < k; t++) {
      final hasKeeper = fixedKeeperOfTeam[t] >= 0;
      final f = hasKeeper ? slotsN - 1 : slotsN;
      final field = [
        for (final i in teams[t])
          if (!isFixedKeeper[i]) i,
      ];
      benchSize[t] = math.max(0, field.length - f);
      if (benchSize[t] == 0) continue;
      var eligible = [
        for (final i in field)
          if (!pinnedPlayers.contains(i)) i,
      ];
      if (eligible.length < benchSize[t]) eligible = field;
      benchEligible[t] = eligible;
      // 출발점: 적합도가 가장 낮은 선수 대신 id 순 첫 선수들 (이후 좌표 하강으로 최적화).
      bench[t] = eligible.take(benchSize[t]).toList();
    }

    final slotCache = <String, Map<Slot, int>>{};
    Map<Slot, int> slotsFor(int t, List<int> teamBench) {
      final key = '$t:${(List.of(teamBench)..sort()).join(',')}';
      return slotCache.putIfAbsent(key, () {
        final benchSet = teamBench.toSet();
        final starters = [
          for (final i in teams[t])
            if (!benchSet.contains(i)) i,
        ];
        return _assignSlots(t, starters);
      });
    }

    Lineup build(List<List<int>> benches) => Lineup(
      format: request.format,
      keeperMode: request.keeperMode,
      teams: [
        for (var t = 0; t < k; t++)
          TeamLineup(
            slots: slotsFor(
              t,
              benches[t],
            ).map((slot, i) => MapEntry(slot, players[i].id)),
            bench: [for (final i in benches[t]) players[i].id],
            fixedKeeperId: fixedKeeperOfTeam[t] >= 0
                ? players[fixedKeeperOfTeam[t]].id
                : null,
          ),
      ],
    );

    double benchScore(List<List<int>> benches) {
      final score = evaluator.evaluate(build(benches)).total;
      var repeat = 0;
      for (final b in benches) {
        for (final i in b) {
          if (previousBench.contains(players[i].id)) repeat++;
        }
      }
      return score - TeamBalancer.repeatBenchPenalty * repeat;
    }

    // 후보 선정: 팀별 좌표 하강 (SPEC §6.4).
    if (benchEligible.isNotEmpty) {
      var current = benchScore(bench);
      for (var pass = 0; pass < 2; pass++) {
        var improved = false;
        for (final t in benchEligible.keys) {
          for (final combo in _combinations(benchEligible[t]!, benchSize[t])) {
            final trial = [...bench];
            trial[t] = combo;
            final s = benchScore(trial);
            if (s > current + 1e-9) {
              current = s;
              bench[t] = combo;
              improved = true;
            }
          }
        }
        if (!improved) break;
      }
    }

    final lineup = build(bench);
    final balance = evaluator.evaluate(lineup);
    final teamOfPlayer = List.filled(n, -1);
    for (var t = 0; t < k; t++) {
      for (final i in teams[t]) {
        teamOfPlayer[i] = t;
      }
    }
    final violated = <TeamConstraint>{
      for (final pair in apartPairs)
        if (teamOfPlayer[pair[0]] == teamOfPlayer[pair[1]])
          apartConstraints[pair[2]],
    }.toList();
    final rep = repetition.penalty(teams);

    return _Candidate(
      lineup: lineup,
      balance: balance,
      repetition: rep,
      repeatedPairs: repetition.repeatedPairsWithLatest(teams),
      cost:
          (100 - balance.total) +
          repWeight * rep +
          styleSpreadPenalty(teams) +
          1000.0 * violated.length,
      violations: violated,
      signature: signature(state),
    );
  }

  /// 팀 안에서 선발 선수를 포지션 원에 배치.
  Map<Slot, int> _assignSlots(int t, List<int> starters) {
    final result = <Slot, int>{};
    final fieldSlots = [...request.format.fieldSlots];
    var free = [...starters];

    // 자리까지 고정된 선수 먼저.
    for (final i in starters) {
      final slot = pinnedSlot[i];
      if (slot == null || result.containsKey(slot)) continue;
      result[slot] = i;
      fieldSlots.remove(slot);
      free.remove(i);
    }

    int? keeper = result[Slot.gk];
    if (keeper == null && free.isNotEmpty) {
      // 로테이션: 시작 키퍼 = 키퍼 가능 선수 우선, 그중 필드 배치가 가장 좋아지는 선수.
      final canKeep = [
        for (final i in free)
          if (players[i].canKeep) i,
      ];
      final candidates = canKeep.isNotEmpty ? canKeep : free;
      var bestFit = -1;
      for (final c in candidates) {
        final rest = [
          for (final i in free)
            if (i != c) players[i],
        ];
        final fit = bestFieldAssignment(rest, fieldSlots).fit;
        if (fit > bestFit) {
          bestFit = fit;
          keeper = c;
        }
      }
      result[Slot.gk] = keeper!;
      free = [
        for (final i in free)
          if (i != keeper) i,
      ];
    }

    final assignment = bestFieldAssignment([
      for (final i in free) players[i],
    ], fieldSlots);
    final byId = {for (final i in free) players[i].id: i};
    assignment.slots.forEach((slot, p) => result[slot] = byId[p.id]!);
    return result;
  }

  static Iterable<List<int>> _combinations(List<int> items, int r) sync* {
    if (r == 0) {
      yield const [];
      return;
    }
    for (var i = 0; i <= items.length - r; i++) {
      for (final rest in _combinations(items.sublist(i + 1), r - 1)) {
        yield [items[i], ...rest];
      }
    }
  }
}
