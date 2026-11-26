import '../../core/models/models.dart';

/// 카카오톡에 붙여넣을 편성 텍스트 (SPEC F8.2).
///
/// 포지션 없이 팀별 이름만, 팀마다 한 열인 표로 세로 나열한다.
/// 능력치 노출을 켜면 팀 이름 아래에 팀 OVR 줄이 붙는다.
/// ```
/// ⚽ 11/25(화) 풋살 6vs6 — 12명 / 2팀 (밸런스 92)
///
/// 🔴 레드　│ 🔵 블루
/// ─────────────────
/// 김철수　│ 이영희
/// ...
/// ── 후보 ──
/// 오세진　│
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

  final teams = lineup.teams.length;
  // 선발: 키퍼 → 필드 슬롯 순서. 후보는 따로.
  final starters = [
    for (final team in lineup.teams)
      [
        for (final slot in lineup.format.slots)
          if (team.slots[slot] != null) nameOf(team.slots[slot]!),
      ],
  ];
  final bench = [
    for (final team in lineup.teams) team.bench.map(nameOf).toList(),
  ];
  final titles = teamNames.take(teams).toList();
  final ovrRow = teamOvr == null
      ? null
      : [for (final o in teamOvr.take(teams)) 'OVR ${o.toStringAsFixed(1)}'];
  // 칸 너비: 한글 1칸, 영문·숫자·공백 반 칸 정도로 어림한다 (카톡은 고정폭 글꼴이 아님).
  final width = [
    for (var t = 0; t < teams; t++)
      [
        titles[t],
        ...starters[t],
        ...bench[t],
      ].map(_textWidth).reduce((a, b) => a > b ? a : b),
  ];
  String row(List<String> cells) {
    // 오른쪽 빈 칸은 구분선까지 생략.
    var end = teams - 1;
    while (end > 0 && cells[end].isEmpty) {
      end--;
    }
    final b = StringBuffer();
    for (var t = 0; t <= end; t++) {
      b.write(t == end ? cells[t] : _pad(cells[t], width[t]));
      if (t != end) b.write(' │ ');
    }
    return b.toString();
  }

  List<String> rows(List<List<String>> columns) {
    final depth = columns.map((c) => c.length).fold(0, (a, b) => a > b ? a : b);
    return [
      for (var i = 0; i < depth; i++)
        row([for (final c in columns) i < c.length ? c[i] : '']),
    ];
  }

  final total =
      width.fold(0.0, (a, b) => a + b) + (teams - 1) * _textWidth(' │ ');
  final rule = '─' * total.ceil();
  return [
    header.toString(),
    '',
    row(titles),
    if (ovrRow != null) row(ovrRow),
    rule,
    ...rows(starters),
    if (bench.any((b) => b.isNotEmpty)) ...['── 후보 ──', ...rows(bench)],
  ].join('\n');
}

/// 글자 너비(em) 어림값. 카톡은 비례폭 글꼴이라 완벽하진 않다.
double _charWidth(int rune) {
  if (rune >= 0xAC00 && rune <= 0xD7A3) return 1; // 한글 음절
  if (rune >= 0x2500 && rune <= 0x257F) return 1; // 선 문자
  if (rune >= 0x3000 && rune <= 0x9FFF) return 1; // 한자·자모·전각 공백
  if (rune >= 0x1F000) return 1.2; // 이모지
  if (rune == 0xFE0F || rune == 0x200D) return 0; // 이모지 결합 문자
  if (rune == 0x2002) return 0.5;
  if (rune == 0x20 || rune == 0x2E || rune == 0x2C) return 0.3; // 공백 . ,
  return 0.6;
}

double _textWidth(String s) =>
    s.runes.fold(0.0, (sum, r) => sum + _charWidth(r));

/// 전각 공백(1em) → en 공백(0.5em) → 일반 공백(0.3em) 순으로 오른쪽을 채운다.
String _pad(String s, double width) {
  var gap = width - _textWidth(s);
  final b = StringBuffer(s);
  for (final (ch, w) in [('\u3000', 1.0), ('\u2002', 0.5), (' ', 0.3)]) {
    while (gap >= w - 0.12) {
      b.write(ch);
      gap -= w;
    }
  }
  return b.toString();
}
