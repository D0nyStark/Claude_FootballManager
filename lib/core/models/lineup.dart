import 'formation.dart';
import 'team_constraint.dart';

/// 편성된 팀 하나: 포지션 원 배치 + 후보.
class TeamLineup {
  TeamLineup({
    required Map<Slot, String> slots,
    List<String> bench = const [],
    this.fixedKeeperId,
  }) : slots = Map.unmodifiable(slots),
       bench = List.unmodifiable(bench);

  /// 채워진 슬롯 → 선수 id. 빈 슬롯은 키가 없다 (부족 팀의 "+1 빌려오기" 자리).
  final Map<Slot, String> slots;

  /// 교체 대기 인원.
  final List<String> bench;

  /// 키퍼 고정 모드에서 이 팀의 고정 키퍼 (항상 [Slot.gk]에 위치).
  final String? fixedKeeperId;

  Iterable<String> get starterIds => slots.values;

  Set<String> get playerIds => {...slots.values, ...bench};

  int get size => slots.length + bench.length;

  TeamLineup copyWith({Map<Slot, String>? slots, List<String>? bench}) =>
      TeamLineup(
        slots: slots ?? this.slots,
        bench: bench ?? this.bench,
        fixedKeeperId: fixedKeeperId,
      );
}

/// 전체 편성 결과.
class Lineup {
  Lineup({
    required this.format,
    required this.keeperMode,
    required List<TeamLineup> teams,
  }) : teams = List.unmodifiable(teams);

  final MatchFormat format;
  final KeeperMode keeperMode;
  final List<TeamLineup> teams;

  Set<String> get playerIds => {for (final t in teams) ...t.playerIds};

  /// 선수가 속한 팀 번호, 없으면 -1.
  int teamOf(String playerId) =>
      teams.indexWhere((t) => t.playerIds.contains(playerId));
}

/// 확정 편성 이력 한 건 — 반복 조합 회피에 쓰는 최소 정보 (SPEC §7 LineupHistory).
class LineupHistoryEntry {
  LineupHistoryEntry({
    required List<Set<String>> teams,
    Set<String> bench = const {},
  }) : teams = List.unmodifiable(teams.map(Set<String>.unmodifiable)),
       bench = Set.unmodifiable(bench);

  factory LineupHistoryEntry.fromLineup(Lineup lineup) => LineupHistoryEntry(
    teams: [for (final t in lineup.teams) t.playerIds],
    bench: {for (final t in lineup.teams) ...t.bench},
  );

  final List<Set<String>> teams;
  final Set<String> bench;
}
