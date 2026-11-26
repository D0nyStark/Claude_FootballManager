import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';

import '../../helpers/deck_factory.dart';

void main() {
  group('PlayerStats', () {
    test('OVR은 8개 항목 평균 (체력 포함)', () {
      final s = PlayerStats(
        shooting: 5,
        dribbling: 4,
        speed: 3,
        passing: 2,
        physical: 1,
        creativity: 5,
        stamina: 3,
        teamwork: 1,
      );
      expect(s.ovr, closeTo(3.0, 1e-9));
      expect(s[Stat.teamwork], 1);
    });

    test('빠른 입력은 모든 항목을 같은 값으로', () {
      final s = PlayerStats.uniform(4);
      expect(Stat.values.every((st) => s[st] == 4), isTrue);
    });

    test('1~5 범위를 벗어나면 오류', () {
      expect(() => PlayerStats.uniform(0), throwsArgumentError);
      expect(() => PlayerStats.uniform(6), throwsArgumentError);
    });
  });

  group('Player', () {
    test('포지션 적합도: 주 2 / 가능 1 / 그 외 0', () {
      final p = makePlayer('a', position: Position.fixo, sub: {Position.ala});
      expect(p.fitFor(Position.fixo), 2);
      expect(p.fitFor(Position.ala), 1);
      expect(p.fitFor(Position.pivo), 0);
    });

    test('가능 포지션에서 주 포지션은 제외된다', () {
      final p = makePlayer(
        'a',
        position: Position.pivo,
        sub: {Position.pivo, Position.ala},
      );
      expect(p.subPositions, {Position.ala});
    });
  });

  group('MatchFormat', () {
    test('5vs5 포메이션: GK·픽소1·아라2·피보1', () {
      final f = MatchFormat.fiveVsFive;
      expect(f.slots.length, 5);
      expect(f.positionDemand, {
        Position.fixo: 1,
        Position.ala: 2,
        Position.pivo: 1,
      });
    });

    test('6vs6 포메이션: GK·픽소2·아라2·피보1', () {
      final f = MatchFormat.sixVsSix;
      expect(f.slots.length, 6);
      expect(f.positionDemand, {
        Position.fixo: 2,
        Position.ala: 2,
        Position.pivo: 1,
      });
    });

    test('모든 슬롯에 구장 좌표가 있다', () {
      for (final f in MatchFormat.values) {
        for (final s in f.slots) {
          final c = f.coordinateOf(s);
          expect(c.x, inInclusiveRange(0, 1));
          expect(c.y, inInclusiveRange(0, 1));
        }
      }
    });
  });
}
