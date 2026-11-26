import 'package:material_ui/material_ui.dart' show Color;

import '../../core/models/models.dart';

/// 확정한 편성 한 건 (SPEC F8.3). 팀 이름·색과 당시 선수 이름까지 담아 그대로 다시 보여준다.
class ConfirmedLineup {
  ConfirmedLineup({
    required this.id,
    required this.confirmedAt,
    required this.balanceScore,
    required this.lineup,
    required List<String> teamNames,
    required List<int> teamColors,
    required Map<String, String> playerNames,
  }) : teamNames = List.unmodifiable(teamNames),
       teamColors = List.unmodifiable(teamColors),
       playerNames = Map.unmodifiable(playerNames);

  final String id;
  final DateTime confirmedAt;
  final double balanceScore;
  final Lineup lineup;
  final List<String> teamNames;
  final List<int> teamColors;

  /// 선수 id → 이름 (게스트·삭제된 선수도 이름이 보이도록).
  final Map<String, String> playerNames;

  Color colorOf(int team) => Color(teamColors[team]);

  String nameOf(String id) => playerNames[id] ?? '?';

  LineupHistoryEntry toHistoryEntry() => LineupHistoryEntry.fromLineup(lineup);

  Map<String, Object?> toJson() => {
    'v': 1,
    'format': lineup.format.name,
    'keeperMode': lineup.keeperMode.name,
    'names': playerNames,
    'teams': [
      for (var t = 0; t < lineup.teams.length; t++)
        {
          'name': teamNames[t],
          'color': teamColors[t],
          'slots': {
            for (final e in lineup.teams[t].slots.entries) e.key.name: e.value,
          },
          'bench': lineup.teams[t].bench,
          'keeper': lineup.teams[t].fixedKeeperId,
        },
    ],
  };

  static ConfirmedLineup fromJson(
    Map<String, Object?> json, {
    required String id,
    required DateTime confirmedAt,
    required double balanceScore,
  }) {
    final teams = (json['teams'] as List).cast<Map>();
    return ConfirmedLineup(
      id: id,
      confirmedAt: confirmedAt,
      balanceScore: balanceScore,
      lineup: Lineup(
        format: MatchFormat.values.byName(json['format'] as String),
        keeperMode: KeeperMode.values.byName(json['keeperMode'] as String),
        teams: [
          for (final t in teams)
            TeamLineup(
              slots: {
                for (final e in (t['slots'] as Map).entries)
                  Slot.values.byName(e.key as String): e.value as String,
              },
              bench: (t['bench'] as List).cast<String>(),
              fixedKeeperId: t['keeper'] as String?,
            ),
        ],
      ),
      teamNames: [for (final t in teams) t['name'] as String],
      teamColors: [for (final t in teams) t['color'] as int],
      playerNames: (json['names'] as Map).cast<String, String>(),
    );
  }
}
