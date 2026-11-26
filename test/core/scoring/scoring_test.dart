import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/core/scoring/scoring.dart';

import '../../helpers/deck_factory.dart';

void main() {
  group('지표', () {
    test('공격력·수비력 기본 가중치 (SPEC §4.4)', () {
      final s = PlayerStats(
        shooting: 5,
        dribbling: 4,
        speed: 3,
        passing: 2,
        physical: 1,
        creativity: 5,
        stamina: 4,
        teamwork: 2,
      );
      const w = IndexWeights.standard;
      expect(
        w.attackOf(s),
        closeTo(0.30 * 5 + 0.25 * 4 + 0.20 * 5 + 0.15 * 3 + 0.10 * 4, 1e-9),
      );
      expect(
        w.defenseOf(s),
        closeTo(0.30 * 1 + 0.30 * 2 + 0.15 * 4 + 0.15 * 3 + 0.10 * 2, 1e-9),
      );
    });

    test('spreadScore: 차이 0 → 100, 0.6 이상 → 0', () {
      expect(spreadScore([3.0, 3.0], 0.6), 100);
      expect(spreadScore([3.0, 3.3], 0.6), closeTo(50, 1e-9));
      expect(spreadScore([2.0, 3.0], 0.6), 0);
    });

    test('SPEC 예시: 전력 0.03·공격 0.06·수비 0.05·포지션 85% → 약 92점', () {
      const w = BalanceWeights.standard;
      final total = w.combine(
        strength: spreadScore([3.0, 3.03], 0.6),
        attack: spreadScore([3.0, 3.06], 0.6),
        defense: spreadScore([3.0, 3.05], 0.6),
        position: 85,
      );
      expect(total.round(), 92);
    });
  });

  group('슬롯 정규화 (SPEC §6.3)', () {
    test('정원 팀은 합계/F', () {
      expect(
        slotAverage(fieldSum: 18, fieldCount: 6, slots: 6, deckMean: 1),
        3,
      );
    });

    test('부족 팀은 빈 자리를 덱 평균 가상 선수로 채움', () {
      // 5명 합 15, 덱 평균 3.6 → (15 + 3.6) / 6
      expect(
        slotAverage(fieldSum: 15, fieldCount: 5, slots: 6, deckMean: 3.6),
        closeTo(18.6 / 6, 1e-9),
      );
    });

    test('17명·3팀: 균형 상태에서 "나머지 팀 평균" 방식과 같은 결과', () {
      const m = 3.0; // 덱 평균
      const fullTeamSum = 6 * m;
      const shortTeamSum = 5 * m;
      final shortAvg = slotAverage(
        fieldSum: shortTeamSum,
        fieldCount: 5,
        slots: 6,
        deckMean: m,
      );
      final othersMean = (fullTeamSum * 2) / 12;
      expect(shortAvg, closeTo((shortTeamSum + othersMean) / 6, 1e-9));
      expect(shortAvg, closeTo(fullTeamSum / 6, 1e-9));
    });

    test('초과 팀은 선발 70% + 팀 평균 30%', () {
      // 7명 합 21(평균 3), 선발 6명 합 19.2
      final v = slotAverage(
        fieldSum: 21,
        fieldCount: 7,
        slots: 6,
        deckMean: 0,
        starterSum: 19.2,
      );
      expect(v, closeTo((0.7 * 19.2 + 0.3 * 3 * 6) / 6, 1e-9));
    });
  });

  group('자리 배치', () {
    test('주 포지션대로 최적 배치', () {
      final players = [
        makePlayer('f', position: Position.fixo),
        makePlayer('a1', position: Position.ala),
        makePlayer('a2', position: Position.ala),
        makePlayer('p', position: Position.pivo),
      ];
      final r = bestFieldAssignment(players, MatchFormat.fiveVsFive.fieldSlots);
      expect(r.fit, 8);
      expect(r.slots[Slot.fixo1]!.id, 'f');
      expect(r.slots[Slot.pivo]!.id, 'p');
    });

    test('포지션이 쏠려도 가능 포지션을 활용', () {
      final players = [
        makePlayer('p1', position: Position.pivo),
        makePlayer('p2', position: Position.pivo, sub: {Position.fixo}),
        makePlayer('p3', position: Position.pivo, sub: {Position.ala}),
        makePlayer('p4', position: Position.pivo),
      ];
      final r = bestFieldAssignment(players, MatchFormat.fiveVsFive.fieldSlots);
      expect(r.fit, 2 + 1 + 1); // 피보 1명 + 가능 포지션 2명
      expect(r.slots.length, 4);
    });
  });

  group('LineupEvaluator', () {
    final players = [
      for (var i = 0; i < 10; i++)
        makePlayer('p$i', stat: 3, position: Position.values[i % 3]),
    ];
    final evaluator = LineupEvaluator(players);

    Lineup lineupOf(List<List<String>> ids) => Lineup(
      format: MatchFormat.fiveVsFive,
      keeperMode: KeeperMode.rotation,
      teams: [
        for (final t in ids)
          TeamLineup(
            slots: {
              for (var i = 0; i < t.length; i++)
                MatchFormat.fiveVsFive.slots[i]: t[i],
            },
          ),
      ],
    );

    test('실력이 같으면 전력·공격·수비 100점', () {
      final b = evaluator.evaluate(
        lineupOf([
          ['p0', 'p1', 'p2', 'p3', 'p4'],
          ['p5', 'p6', 'p7', 'p8', 'p9'],
        ]),
      );
      expect(b.strength, 100);
      expect(b.attack, 100);
      expect(b.defense, 100);
      expect(b.grade, isNot(BalanceGrade.poor));
    });

    test('실력 차이가 크면 점수가 낮다', () {
      final strong = [for (var i = 0; i < 5; i++) makePlayer('s$i', stat: 5)];
      final weak = [for (var i = 0; i < 5; i++) makePlayer('w$i', stat: 1)];
      final e = LineupEvaluator([...strong, ...weak]);
      final b = e.evaluate(
        lineupOf([
          [for (final p in strong) p.id],
          [for (final p in weak) p.id],
        ]),
      );
      expect(b.strength, 0);
      expect(b.grade, BalanceGrade.poor);
    });

    test('비선호 자리 판정', () {
      final fixo = makePlayer('x', position: Position.fixo);
      final e = LineupEvaluator([fixo]);
      expect(e.isOffPosition('x', Slot.pivo), isTrue);
      expect(e.isOffPosition('x', Slot.fixo1), isFalse);
      expect(e.isOffPosition('x', Slot.gk), isFalse);
    });

    test('고정 키퍼는 전력 계산에서 제외', () {
      final field = [for (var i = 0; i < 8; i++) makePlayer('f$i', stat: 3)];
      final keeperStrong = makePlayer('k1', stat: 5, canKeep: true);
      final keeperWeak = makePlayer('k2', stat: 1, canKeep: true);
      final e = LineupEvaluator([...field, keeperStrong, keeperWeak]);
      final fs = MatchFormat.fiveVsFive.fieldSlots;
      final b = e.evaluate(
        Lineup(
          format: MatchFormat.fiveVsFive,
          keeperMode: KeeperMode.fixed,
          teams: [
            TeamLineup(
              slots: {Slot.gk: 'k1', for (var i = 0; i < 4; i++) fs[i]: 'f$i'},
              fixedKeeperId: 'k1',
            ),
            TeamLineup(
              slots: {
                Slot.gk: 'k2',
                for (var i = 0; i < 4; i++) fs[i]: 'f${i + 4}',
              },
              fixedKeeperId: 'k2',
            ),
          ],
        ),
      );
      expect(b.strength, 100);
    });
  });
}
