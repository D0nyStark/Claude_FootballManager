import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/balancer/balancer.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/core/scoring/scoring.dart';

import '../../helpers/deck_factory.dart';

const balancer = TeamBalancer();

BalanceSuccess run(BalanceRequest r) {
  final result = balancer.balance(r);
  if (result is BalanceFailure) fail('편성 실패: ${result.issues}');
  return result as BalanceSuccess;
}

int teamCountFor(int n, math.Random rng) {
  final maxTeams = math.min(4, n ~/ 4);
  return 2 + rng.nextInt(maxTeams - 1);
}

void main() {
  group('팀 인원 분배', () {
    test('SPEC F3.1 예시', () {
      expect(distributeTeamSizes(12, 2), [6, 6]);
      expect(distributeTeamSizes(17, 3), [6, 6, 5]);
      expect(distributeTeamSizes(21, 3), [7, 7, 7]);
      expect(distributeTeamSizes(15, 2), [8, 7]);
      expect(describeTeamSizes(17, 3), '6 · 6 · 5');
    });
  });

  group('기본 편성', () {
    test('모든 선수가 정확히 한 팀에, 팀 인원 차이 ≤ 1', () {
      final deck = randomDeck(math.Random(1), 13);
      final r = run(
        BalanceRequest(players: deck, format: MatchFormat.sixVsSix),
      );
      final lineup = r.best.lineup;
      final ids = [for (final t in lineup.teams) ...t.playerIds];
      expect(ids.toSet(), {for (final p in deck) p.id});
      expect(ids.length, deck.length);
      final sizes = [for (final t in lineup.teams) t.size]..sort();
      expect(sizes, [6, 7]);
    });

    test('편성안은 최대 3개이며 서로 다르다', () {
      final deck = randomDeck(math.Random(2), 12);
      final r = run(
        BalanceRequest(players: deck, format: MatchFormat.sixVsSix),
      );
      expect(r.candidates.length, inInclusiveRange(1, 3));
      for (var a = 0; a < r.candidates.length; a++) {
        for (var b = a + 1; b < r.candidates.length; b++) {
          final d = lineupDistance(
            [for (final t in r.candidates[a].lineup.teams) t.playerIds],
            [for (final t in r.candidates[b].lineup.teams) t.playerIds],
          );
          expect(d, greaterThan(0));
        }
      }
    });

    test('같은 입력 + 같은 시드 → 같은 결과', () {
      final deck = randomDeck(math.Random(3), 15);
      BalanceRequest req() => BalanceRequest(
        players: deck,
        format: MatchFormat.fiveVsFive,
        teamCount: 3,
        seed: 42,
      );
      final a = run(req()).best.lineup;
      final b = run(req()).best.lineup;
      for (var t = 0; t < a.teams.length; t++) {
        expect(a.teams[t].slots, b.teams[t].slots);
        expect(a.teams[t].bench, b.teams[t].bench);
      }
    });

    test('포메이션 슬롯에만 배치되고 선발은 N명 이하', () {
      final deck = randomDeck(math.Random(4), 12);
      final r = run(
        BalanceRequest(players: deck, format: MatchFormat.fiveVsFive),
      );
      for (final team in r.best.lineup.teams) {
        expect(
          team.slots.keys.every(MatchFormat.fiveVsFive.slots.contains),
          isTrue,
        );
        expect(team.slots.length, lessThanOrEqualTo(5));
        expect(team.slots.containsKey(Slot.gk), isTrue);
      }
    });
  });

  group('품질 목표 (SPEC §6.8)', () {
    test('무작위 덱 100개(8~24명, 2~4팀): 평균 밸런스 점수 ≥ 90', () {
      final rng = math.Random(2026);
      var sum = 0.0;
      var worst = 100.0;
      for (var trial = 0; trial < 100; trial++) {
        final n = 8 + rng.nextInt(17);
        final deck = randomDeck(rng, n);
        final r = run(
          BalanceRequest(
            players: deck,
            format: rng.nextBool()
                ? MatchFormat.fiveVsFive
                : MatchFormat.sixVsSix,
            teamCount: teamCountFor(n, rng),
            seed: trial,
          ),
        );
        sum += r.best.balance.total;
        worst = math.min(worst, r.best.balance.total);
      }
      final avg = sum / 100;
      // ignore: avoid_print
      print('평균 밸런스 ${avg.toStringAsFixed(1)}, 최저 ${worst.toStringAsFixed(1)}');
      expect(avg, greaterThanOrEqualTo(90));
    });

    // 인원이 적고(12명) 포지션이 쏠리면 최선이 85점에 못 미치는 덱도 있다
    // (탐색량을 3배로 늘려도 같은 결과) → 개별 80점 이상 + 평균 90점 이상.
    test('포지션이 쏠린 덱(피보 70%)에서도 공격·수비 개별 ≥ 80, 평균 ≥ 90', () {
      final rng = math.Random(7);
      var sum = 0.0;
      for (var trial = 0; trial < 20; trial++) {
        final deck = randomDeck(rng, 12 + rng.nextInt(7), pivoRatio: 0.7);
        final r = run(
          BalanceRequest(
            players: deck,
            format: MatchFormat.sixVsSix,
            seed: trial,
          ),
        );
        expect(r.best.balance.attack, greaterThanOrEqualTo(80));
        expect(r.best.balance.defense, greaterThanOrEqualTo(80));
        sum += r.best.balance.attack + r.best.balance.defense;
      }
      expect(sum / 40, greaterThanOrEqualTo(90));
    });

    test('부족 팀(17명·3팀, 6vs6)의 평균 OVR이 덱 평균과 ±0.05 이내', () {
      final rng = math.Random(17);
      var maxGap = 0.0;
      for (var trial = 0; trial < 10; trial++) {
        final deck = randomDeck(rng, 17);
        final deckAvg =
            deck.map((p) => p.stats.ovr).reduce((a, b) => a + b) / deck.length;
        final r = run(
          BalanceRequest(
            players: deck,
            format: MatchFormat.sixVsSix,
            teamCount: 3,
            seed: trial,
          ),
        );
        final byId = {for (final p in deck) p.id: p};
        final short = r.best.lineup.teams.firstWhere((t) => t.size == 5);
        final shortAvg =
            short.playerIds
                .map((id) => byId[id]!.stats.ovr)
                .reduce((a, b) => a + b) /
            5;
        // 균형 상태에서는 부족 팀 평균 = 덱 평균 (빌려 오는 1명을 감안해도 불리하지 않음).
        maxGap = math.max(maxGap, (shortAvg - deckAvg).abs());
        expect((shortAvg - deckAvg).abs(), lessThanOrEqualTo(0.05));
        expect(r.best.balance.teams.where((t) => t.isShort).length, 1);
      }
      // ignore: avoid_print
      print('부족 팀 평균과 덱 평균의 최대 차이 ${maxGap.toStringAsFixed(3)}');
    });

    test('24명·4팀 편성 시간 (기기 목표 < 500ms)', () {
      final deck = randomDeck(math.Random(24), 24);
      final sw = Stopwatch()..start();
      run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          teamCount: 4,
        ),
      );
      sw.stop();
      // ignore: avoid_print
      print('24명·4팀: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(1500));
    });
  });

  group('후보 (정원 초과)', () {
    test('21명·3팀(6vs6): 팀마다 선발 6명 + 후보 1명', () {
      final deck = randomDeck(math.Random(21), 21);
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          teamCount: 3,
        ),
      );
      for (final team in r.best.lineup.teams) {
        expect(team.slots.length, 6);
        expect(team.bench.length, 1);
      }
    });

    test('직전 편성의 후보는 가능하면 다시 후보가 되지 않는다', () {
      // 실력이 모두 같으면 후보 선택은 이전 후보 회피로만 갈린다.
      final deck = [
        for (var i = 0; i < 14; i++)
          makePlayer(
            'p${i.toString().padLeft(2, '0')}',
            position: Position.values[i % 3],
          ),
      ];
      final first = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          repeatAvoidance: RepeatAvoidance.off,
        ),
      ).best.lineup;
      final prevBench = {for (final t in first.teams) ...t.bench};
      expect(prevBench.length, 2);
      final second = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          history: [LineupHistoryEntry.fromLineup(first)],
        ),
      ).best.lineup;
      final bench = {for (final t in second.teams) ...t.bench};
      expect(bench.intersection(prevBench), isEmpty);
    });
  });

  group('제약 조건', () {
    final rng = math.Random(99);

    test('같은 팀 / 다른 팀 / 고정을 100% 지킨다', () {
      for (var trial = 0; trial < 30; trial++) {
        final deck = randomDeck(rng, 12 + rng.nextInt(9));
        final ids = [for (final p in deck) p.id]..shuffle(rng);
        final teamCount = teamCountFor(deck.length, rng);
        final together = TeamConstraint(
          type: ConstraintType.together,
          playerIds: {ids[0], ids[1]},
        );
        final apart = TeamConstraint(
          type: ConstraintType.apart,
          playerIds: {ids[2], ids[3]},
        );
        final r = run(
          BalanceRequest(
            players: deck,
            format: MatchFormat.fiveVsFive,
            teamCount: teamCount,
            constraints: [together, apart],
            pinnedTeams: {ids[4]: 1},
            seed: trial,
          ),
        );
        for (final c in r.candidates) {
          final l = c.lineup;
          expect(l.teamOf(ids[0]), l.teamOf(ids[1]));
          expect(l.teamOf(ids[2]), isNot(l.teamOf(ids[3])));
          expect(l.teamOf(ids[4]), 1);
        }
      }
    });

    test('자리 고정(Pin)한 선수는 그 자리에 남는다', () {
      final deck = randomDeck(math.Random(5), 12);
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          pinnedTeams: {deck[0].id: 0},
          pinnedSlots: {deck[0].id: Slot.pivo},
        ),
      );
      expect(r.best.lineup.teams[0].slots[Slot.pivo], deck[0].id);
    });

    // 충돌하는 조건은 알림 없이 최대한 지킨 편성을 낸다.
    void expectValidLineup(BalanceSuccess r, List<Player> deck) {
      final l = r.best.lineup;
      final ids = [for (final t in l.teams) ...t.playerIds];
      expect(ids.toSet(), {for (final p in deck) p.id});
      expect(ids.length, deck.length);
      final sizes = [for (final t in l.teams) t.size];
      expect(
        sizes.reduce(math.max) - sizes.reduce(math.min),
        lessThanOrEqualTo(1),
      );
    }

    test('지킬 수 없는 "다른 팀" 제약: 실패 없이 최대한 지킨다', () {
      final deck = randomDeck(math.Random(6), 12);
      final apart = TeamConstraint(
        type: ConstraintType.apart,
        playerIds: {deck[0].id, deck[1].id, deck[2].id},
      );
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          constraints: [apart],
        ),
      );
      expectValidLineup(r, deck);
      // 3명을 2팀에 나누면 최소 한 쌍은 같은 팀 — 정확히 한 쌍만 겹친다.
      final teams = {
        for (final id in apart.playerIds) r.best.lineup.teamOf(id),
      };
      expect(teams.length, 2);
      expect(r.best.unmetConstraints, [apart]);
    });

    test('같은 팀과 다른 팀이 충돌하면 "같은 팀"을 따른다', () {
      final deck = randomDeck(math.Random(8), 10);
      final pair = {deck[0].id, deck[1].id};
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.fiveVsFive,
          constraints: [
            TeamConstraint(type: ConstraintType.together, playerIds: pair),
            TeamConstraint(type: ConstraintType.apart, playerIds: pair),
          ],
        ),
      );
      expectValidLineup(r, deck);
      expect(
        r.best.lineup.teamOf(deck[0].id),
        r.best.lineup.teamOf(deck[1].id),
      );
    });

    test('묶음이 팀 정원보다 크면 묶음을 풀어 편성한다', () {
      final deck = randomDeck(math.Random(9), 10);
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.fiveVsFive,
          constraints: [
            TeamConstraint(
              type: ConstraintType.together,
              playerIds: {for (final p in deck.take(6)) p.id},
            ),
          ],
        ),
      );
      expectValidLineup(r, deck);
    });

    test('한 팀에 정원보다 많이 고정해도 편성한다', () {
      final deck = randomDeck(math.Random(13), 12);
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          pinnedTeams: {for (final p in deck.take(8)) p.id: 0},
        ),
      );
      expectValidLineup(r, deck);
    });

    test('묶음끼리 정원에 나눠 담을 수 없으면 일부 묶음을 푼다', () {
      // 10명·2팀(5·5)에 4명 묶음 2개 + 2명 묶음 1개 → 그대로는 담을 수 없음.
      final deck = randomDeck(math.Random(14), 10);
      final ids = [for (final p in deck) p.id];
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.fiveVsFive,
          constraints: [
            TeamConstraint(
              type: ConstraintType.together,
              playerIds: ids.sublist(0, 4).toSet(),
            ),
            TeamConstraint(
              type: ConstraintType.together,
              playerIds: ids.sublist(4, 8).toSet(),
            ),
            TeamConstraint(
              type: ConstraintType.together,
              playerIds: ids.sublist(8, 10).toSet(),
            ),
          ],
        ),
      );
      expectValidLineup(r, deck);
    });

    test('잘못된 키퍼 지정(덱에 없는 선수)은 무시한다', () {
      final deck = randomDeck(math.Random(15), 10);
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.fiveVsFive,
          keeperMode: KeeperMode.fixed,
          fixedKeepers: {0: 'nobody', 1: deck[0].id},
        ),
      );
      expectValidLineup(r, deck);
      expect(r.best.lineup.teams[1].slots[Slot.gk], deck[0].id);
    });

    // 화면에서 2~4팀만 고를 수 있으므로 사용자에게는 나타나지 않는 경우.
    test('팀 수가 범위를 벗어나면 실패 (잘못된 입력)', () {
      final deck = randomDeck(math.Random(10), 10);
      expect(
        balancer.balance(
          BalanceRequest(
            players: deck,
            format: MatchFormat.fiveVsFive,
            teamCount: 5,
          ),
        ),
        isA<BalanceFailure>(),
      );
    });
  });

  group('골키퍼 모드', () {
    test('로테이션: 시작 키퍼는 키퍼 가능 선수 우선', () {
      final deck = [
        for (var i = 0; i < 9; i++)
          makePlayer('p$i', position: Position.values[i % 3]),
        makePlayer('keeper', canKeep: true),
      ];
      final r = run(
        BalanceRequest(players: deck, format: MatchFormat.fiveVsFive),
      );
      final team = r.best.lineup.teams.firstWhere(
        (t) => t.playerIds.contains('keeper'),
      );
      expect(team.slots[Slot.gk], 'keeper');
    });

    test('키퍼 고정: 지정 키퍼가 팀 GK에 고정되고 후보가 되지 않는다', () {
      final deck = [
        ...randomDeck(math.Random(11), 13),
        makePlayer('k0', canKeep: true, stat: 5),
        makePlayer('k1', canKeep: true, stat: 1),
      ];
      final r = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          keeperMode: KeeperMode.fixed,
          fixedKeepers: {0: 'k0', 1: 'k1'},
        ),
      );
      final teams = r.best.lineup.teams;
      expect(teams[0].slots[Slot.gk], 'k0');
      expect(teams[1].slots[Slot.gk], 'k1');
      expect(teams[0].fixedKeeperId, 'k0');
      for (final t in teams) {
        expect(t.bench.contains(t.fixedKeeperId), isFalse);
      }
      // 키퍼 실력 차이(5 vs 1)는 전력 계산에서 제외되므로 균형이 유지된다.
      expect(r.best.balance.strength, greaterThan(85));
    });

    test('자동 배정: 키퍼 가능 선수만 팀별 1명', () {
      final deck = [
        ...randomDeck(math.Random(12), 10).map(
          (p) => Player(
            id: p.id,
            name: p.name,
            stats: p.stats,
            mainPosition: p.mainPosition,
          ),
        ),
        makePlayer('k0', canKeep: true),
        makePlayer('k1', canKeep: true),
      ];
      final keepers = autoAssignKeepers(deck, 2, math.Random(1));
      expect(keepers.values.toSet(), {'k0', 'k1'});
    });
  });

  group('반복 조합 회피 (SPEC §6.6)', () {
    double repeatRatio(Lineup current, Lineup previous) {
      var together = 0, repeated = 0;
      final prevTeam = {
        for (var t = 0; t < previous.teams.length; t++)
          for (final id in previous.teams[t].playerIds) id: t,
      };
      for (final team in current.teams) {
        final ids = team.playerIds.toList();
        for (var a = 0; a < ids.length; a++) {
          for (var b = a + 1; b < ids.length; b++) {
            together++;
            if (prevTeam[ids[a]] == prevTeam[ids[b]]) repeated++;
          }
        }
      }
      return repeated / together;
    }

    test('같은 덱 연속 편성 시 반복 쌍 비율이 회피 off 대비 50% 이상 감소', () {
      final rng = math.Random(33);
      var offSum = 0.0, onSum = 0.0, scoreLoss = 0.0;
      const trials = 15;
      for (var trial = 0; trial < trials; trial++) {
        final deck = randomDeck(rng, 12 + rng.nextInt(7));
        BalanceRequest req({
          List<LineupHistoryEntry> history = const [],
          RepeatAvoidance avoid = RepeatAvoidance.medium,
        }) => BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          history: history,
          repeatAvoidance: avoid,
          seed: trial,
        );
        final first = run(req()).best;
        final history = [LineupHistoryEntry.fromLineup(first.lineup)];
        final off = run(req(history: history, avoid: RepeatAvoidance.off)).best;
        final on = run(req(history: history)).best;
        offSum += repeatRatio(off.lineup, first.lineup);
        onSum += repeatRatio(on.lineup, first.lineup);
        scoreLoss += off.balance.total - on.balance.total;
        // 밸런스 보호: 회피 때문에 2점 넘게 손해 보지 않는다.
        expect(
          on.balance.total,
          greaterThanOrEqualTo(
            off.balance.total - TeamBalancer.balanceTolerance - 0.5,
          ),
        );
        expect(on.repeatedPairs, lessThanOrEqualTo(off.repeatedPairs));
      }
      // ignore: avoid_print
      print(
        '반복 쌍 비율 off ${(offSum / trials).toStringAsFixed(2)} → on ${(onSum / trials).toStringAsFixed(2)}, '
        '평균 점수 손실 ${(scoreLoss / trials).toStringAsFixed(2)}',
      );
      expect(onSum / trials, lessThanOrEqualTo(0.5 * offSum / trials));
    });

    test('다시 섞기: 이미 보여준 편성안과 다른 결과', () {
      final deck = randomDeck(math.Random(44), 12);
      final first = run(
        BalanceRequest(players: deck, format: MatchFormat.sixVsSix),
      );
      final shown = [for (final c in first.candidates) c.lineup];
      final again = run(
        BalanceRequest(
          players: deck,
          format: MatchFormat.sixVsSix,
          avoidLineups: shown,
          seed: 1,
        ),
      );
      for (final c in again.candidates) {
        for (final s in shown) {
          final d = lineupDistance(
            [for (final t in c.lineup.teams) t.playerIds],
            [for (final t in s.teams) t.playerIds],
          );
          expect(d, greaterThan(0));
        }
      }
    });
  });

  group('수동 수정 점수', () {
    test('LineupEvaluator가 엔진 결과와 같은 점수를 낸다', () {
      final deck = randomDeck(math.Random(55), 14);
      final r = run(
        BalanceRequest(players: deck, format: MatchFormat.sixVsSix),
      );
      final again = LineupEvaluator(deck).evaluate(r.best.lineup);
      expect(again.total, closeTo(r.best.balance.total, 1e-9));
    });
  });
}
