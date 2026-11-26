import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';

void main() {
  // 5vs5, 2팀. 레드: a~e + 후보 x / 블루: f~i (피보 빈 자리)
  Lineup base({KeeperMode mode = KeeperMode.rotation}) => Lineup(
    format: MatchFormat.fiveVsFive,
    keeperMode: mode,
    teams: [
      TeamLineup(
        slots: {
          Slot.gk: 'a',
          Slot.fixo1: 'b',
          Slot.alaLeft: 'c',
          Slot.alaRight: 'd',
          Slot.pivo: 'e',
        },
        bench: ['x'],
        fixedKeeperId: mode == KeeperMode.fixed ? 'a' : null,
      ),
      TeamLineup(
        slots: {
          Slot.gk: 'f',
          Slot.fixo1: 'g',
          Slot.alaLeft: 'h',
          Slot.alaRight: 'i',
        },
        fixedKeeperId: mode == KeeperMode.fixed ? 'f' : null,
      ),
    ],
  );

  test('같은 팀 원끼리 맞교환', () {
    final l = moveInLineup(
      base(),
      const SlotSpot(0, Slot.pivo),
      const SlotSpot(0, Slot.fixo1),
    );
    expect(l.teams[0].slots[Slot.pivo], 'b');
    expect(l.teams[0].slots[Slot.fixo1], 'e');
  });

  test('다른 팀 원끼리 맞교환', () {
    final l = moveInLineup(
      base(),
      const SlotSpot(0, Slot.alaLeft),
      const SlotSpot(1, Slot.alaLeft),
    );
    expect(l.teams[0].slots[Slot.alaLeft], 'h');
    expect(l.teams[1].slots[Slot.alaLeft], 'c');
  });

  test('빈 원으로 이동 (팀 인원이 바뀐다)', () {
    final l = moveInLineup(
      base(),
      const SlotSpot(0, Slot.pivo),
      const SlotSpot(1, Slot.pivo),
    );
    expect(l.teams[0].slots.containsKey(Slot.pivo), isFalse);
    expect(l.teams[1].slots[Slot.pivo], 'e');
    expect(l.teams[0].size, 5);
    expect(l.teams[1].size, 5);
  });

  test('후보 ↔ 원 맞교환', () {
    final l = moveInLineup(
      base(),
      const BenchSpot(0, 'x'),
      const SlotSpot(0, Slot.alaRight),
    );
    expect(l.teams[0].slots[Slot.alaRight], 'x');
    expect(l.teams[0].bench, ['d']);
  });

  test('원 → 후보 영역: 후보로 내림', () {
    final l = moveInLineup(
      base(),
      const SlotSpot(1, Slot.alaLeft),
      const BenchSpot(1),
    );
    expect(l.teams[1].slots.containsKey(Slot.alaLeft), isFalse);
    expect(l.teams[1].bench, ['h']);
  });

  test('후보 → 다른 팀 후보 영역: 이동', () {
    final l = moveInLineup(base(), const BenchSpot(0, 'x'), const BenchSpot(1));
    expect(l.teams[0].bench, isEmpty);
    expect(l.teams[1].bench, ['x']);
  });

  test('빈 자리에서 끌면 아무것도 바뀌지 않는다', () {
    final original = base();
    final l = moveInLineup(
      original,
      const SlotSpot(1, Slot.pivo),
      const SlotSpot(0, Slot.pivo),
    );
    expect(identical(l, original), isTrue);
  });

  test('키퍼 고정: GK 원에 들어간 선수가 고정 키퍼가 된다', () {
    final l = moveInLineup(
      base(mode: KeeperMode.fixed),
      const SlotSpot(0, Slot.gk),
      const SlotSpot(1, Slot.gk),
    );
    expect(l.teams[0].fixedKeeperId, 'f');
    expect(l.teams[1].fixedKeeperId, 'a');
  });

  test('spotOf: 선수 위치 찾기', () {
    expect(spotOf(base(), 'e'), const SlotSpot(0, Slot.pivo));
    expect(spotOf(base(), 'x'), const BenchSpot(0, 'x'));
    expect(spotOf(base(), 'zz'), isNull);
  });
}
