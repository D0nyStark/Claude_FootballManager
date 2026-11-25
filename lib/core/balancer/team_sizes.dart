/// n명을 K팀으로 나눌 때 팀별 인원 (차이 최대 1명, 큰 팀이 앞).
/// 예: 17명·3팀 → [6, 6, 5], 21명·3팀 → [7, 7, 7].
List<int> distributeTeamSizes(int playerCount, int teamCount) {
  if (teamCount <= 0) throw ArgumentError.value(teamCount, 'teamCount');
  final base = playerCount ~/ teamCount;
  final extra = playerCount % teamCount;
  return [for (var t = 0; t < teamCount; t++) base + (t < extra ? 1 : 0)];
}

/// 팀 구성 미리보기 문구 (SPEC F3.1). 예: "6 · 6 · 5".
String describeTeamSizes(int playerCount, int teamCount) =>
    distributeTeamSizes(playerCount, teamCount).join(' · ');
