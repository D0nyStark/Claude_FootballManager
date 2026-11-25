/// 생성 마법사 ②: 붙여넣은 명단에서 이름을 뽑는다 (SPEC F12).
///
/// 줄바꿈·쉼표·공백 등으로 나누고, 앞 번호(1. 2) 등)·기호(-, •)를 지우고, 중복을 뺀다.
/// [existing]에 이미 있는 이름도 뺀다.
List<String> parseRoster(String text, {Iterable<String> existing = const []}) {
  final seen = {for (final e in existing) e.trim()};
  final result = <String>[];
  for (var token in text.split(RegExp(r'[\n\r,;/·|\t ]+'))) {
    token = token
        .replaceAll(RegExp(r'^[\-•*·>]+'), '')
        .replaceAll(RegExp(r'^\d+[.)\]]?'), '')
        .replaceAll(RegExp(r'^[(\[]?\d+[)\]]'), '')
        .trim();
    if (token.isEmpty || RegExp(r'^\d+$').hasMatch(token)) continue;
    if (token.length > 20) token = token.substring(0, 20);
    if (seen.add(token)) result.add(token);
  }
  return result;
}
