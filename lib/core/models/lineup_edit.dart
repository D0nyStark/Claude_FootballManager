import 'formation.dart';
import 'lineup.dart';
import 'team_constraint.dart';

/// 구장 위의 위치: 포지션 원 또는 후보 영역.
sealed class Spot {
  const Spot(this.team);

  final int team;
}

/// 팀 [team]의 포지션 원 [slot] (비어 있을 수도 있음).
class SlotSpot extends Spot {
  const SlotSpot(super.team, this.slot);

  final Slot slot;

  @override
  bool operator ==(Object other) =>
      other is SlotSpot && other.team == team && other.slot == slot;

  @override
  int get hashCode => Object.hash(team, slot);

  @override
  String toString() => 'SlotSpot($team, ${slot.name})';
}

/// 팀 [team]의 후보 영역. [playerId]가 있으면 그 후보 칩, 없으면 영역 자체.
class BenchSpot extends Spot {
  const BenchSpot(super.team, [this.playerId]);

  final String? playerId;

  @override
  bool operator ==(Object other) =>
      other is BenchSpot && other.team == team && other.playerId == playerId;

  @override
  int get hashCode => Object.hash(team, playerId);

  @override
  String toString() => 'BenchSpot($team, $playerId)';
}

/// 수동 수정 (SPEC F6): [from]에 있는 선수를 [to]로 옮긴다.
///
/// - 원 → 원: 맞교환 (빈 원이면 이동). 같은 팀·다른 팀 모두 가능.
/// - 원 → 후보 칩: 맞교환 / 원 → 후보 영역: 후보로 내림 (원은 빈 자리가 된다)
/// - 후보 → 원: 맞교환 (원의 선수는 그 후보 자리로) / 빈 원이면 이동
/// - 후보 → 다른 팀 후보: 맞교환 또는 이동
///
/// 키퍼 고정 모드에서는 GK 원에 있는 선수가 그 팀의 고정 키퍼가 된다.
/// 바뀐 것이 없으면 [lineup]을 그대로 돌려준다.
Lineup moveInLineup(Lineup lineup, Spot from, Spot to) {
  if (from == to) return lineup;
  final slots = [for (final t in lineup.teams) Map.of(t.slots)];
  final benches = [for (final t in lineup.teams) List.of(t.bench)];

  String? occupant(Spot s) => switch (s) {
    SlotSpot(:final team, :final slot) => slots[team][slot],
    BenchSpot(:final playerId) => playerId,
  };

  final moving = occupant(from);
  if (moving == null) return lineup;
  final displaced = occupant(to);
  if (displaced == moving) return lineup;

  // 1) 출발지를 비우고, 밀려난 선수를 그 자리에 넣는다.
  switch (from) {
    case SlotSpot(:final team, :final slot):
      if (displaced == null) {
        slots[team].remove(slot);
      } else {
        slots[team][slot] = displaced;
      }
    case BenchSpot(:final team):
      final i = benches[team].indexOf(moving);
      if (displaced == null) {
        benches[team].removeAt(i);
      } else {
        benches[team][i] = displaced;
      }
  }
  // 2) 도착지에 옮기는 선수를 넣는다.
  switch (to) {
    case SlotSpot(:final team, :final slot):
      slots[team][slot] = moving;
    case BenchSpot(:final team, :final playerId):
      if (playerId == null) {
        benches[team].add(moving);
      } else {
        benches[team][benches[team].indexOf(playerId)] = moving;
      }
  }

  final fixed = lineup.keeperMode == KeeperMode.fixed;
  return Lineup(
    format: lineup.format,
    keeperMode: lineup.keeperMode,
    teams: [
      for (var t = 0; t < lineup.teams.length; t++)
        TeamLineup(
          slots: slots[t],
          bench: benches[t],
          fixedKeeperId: fixed && lineup.teams[t].fixedKeeperId != null
              ? slots[t][Slot.gk]
              : lineup.teams[t].fixedKeeperId,
        ),
    ],
  );
}

/// 선수가 지금 있는 위치.
Spot? spotOf(Lineup lineup, String playerId) {
  for (var t = 0; t < lineup.teams.length; t++) {
    final team = lineup.teams[t];
    for (final e in team.slots.entries) {
      if (e.value == playerId) return SlotSpot(t, e.key);
    }
    if (team.bench.contains(playerId)) return BenchSpot(t, playerId);
  }
  return null;
}
