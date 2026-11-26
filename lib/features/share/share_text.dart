import '../../core/models/models.dart';

/// 카카오톡에 붙여넣을 편성 텍스트 (SPEC F8.2).
///
/// ```
/// ⚽ 11/25(화) 풋살 6vs6 — 12명 / 2팀 (밸런스 92)
/// 🔴 레드: 🔄김철수 | 픽소 이영희·박민수 | 아라 최지훈·정다은 | 피보 한상우 | 후보 오세진
/// ```
String buildShareText({
  required Lineup lineup,
  required List<String> teamNames,
  required String Function(String id) nameOf,
  required DateTime date,
  int? balanceScore,
  String? groupName,
  List<double>? teamOvr,
}) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final format = lineup.format == MatchFormat.fiveVsFive ? '5vs5' : '6vs6';
  final count = lineup.playerIds.length;
  final header =
      StringBuffer(
          '⚽ ${date.month}/${date.day}(${weekdays[date.weekday - 1]}) ',
        )
        ..write(groupName ?? '풋살')
        ..write(' $format — $count명 / ${lineup.teams.length}팀');
  if (balanceScore != null) header.write(' (밸런스 $balanceScore)');

  final lines = [header.toString()];
  for (var t = 0; t < lineup.teams.length; t++) {
    final team = lineup.teams[t];
    final parts = <String>[];
    final gk = team.slots[Slot.gk];
    if (gk != null) {
      parts.add('${team.fixedKeeperId != null ? '🧤' : '🔄'}${nameOf(gk)}');
    }
    for (final pos in Position.values) {
      final names = [
        for (final slot in lineup.format.fieldSlots)
          if (slot.position == pos && team.slots[slot] != null)
            nameOf(team.slots[slot]!),
      ];
      if (names.isNotEmpty) parts.add('${pos.label} ${names.join('·')}');
    }
    if (team.bench.isNotEmpty) {
      parts.add('후보 ${team.bench.map(nameOf).join('·')}');
    }
    final ovr = teamOvr == null
        ? ''
        : ' (OVR ${teamOvr[t].toStringAsFixed(1)})';
    lines.add('${teamNames[t]}$ovr: ${parts.join(' | ')}');
  }
  return lines.join('\n');
}
