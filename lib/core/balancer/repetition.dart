import '../models/lineup.dart';

/// 이전 편성과의 반복 정도 계산 (SPEC §6.6).
class RepetitionModel {
  RepetitionModel(List<String> playerIds, List<LineupHistoryEntry> history)
    : _n = playerIds.length,
      _pairWeight = List.filled(playerIds.length * playerIds.length, 0.0),
      _latestPair = List.filled(playerIds.length * playerIds.length, false),
      _historyTeams = [] {
    final index = {for (var i = 0; i < playerIds.length; i++) playerIds[i]: i};
    final used = history.take(decay.length).toList();
    for (var h = 0; h < used.length; h++) {
      final teams = <List<int>>[];
      for (final team in used[h].teams) {
        final members = [
          for (final id in team)
            if (index.containsKey(id)) index[id]!,
        ];
        teams.add(members);
        for (var a = 0; a < members.length; a++) {
          for (var b = a + 1; b < members.length; b++) {
            final i = members[a], j = members[b];
            _pairWeight[i * _n + j] += decay[h];
            _pairWeight[j * _n + i] += decay[h];
            if (h == 0) {
              _latestPair[i * _n + j] = true;
              _latestPair[j * _n + i] = true;
            }
          }
        }
      }
      _historyTeams.add(teams);
    }
  }

  /// 직전 편성일수록 강하게.
  static const List<double> decay = [1.0, 0.5, 0.25];

  /// 팀 하나가 이전 팀과 이 비율 이상 같으면 추가 페널티.
  static const double sameTeamThreshold = 0.7;
  static const double sameTeamPenalty = 0.5;

  final int _n;
  final List<double> _pairWeight;
  final List<bool> _latestPair;
  final List<List<List<int>>> _historyTeams;

  bool get isEmpty => _historyTeams.isEmpty;

  /// 반복페널티 (0 ~ 약 2.6). [teams]는 팀별 선수 인덱스.
  double penalty(List<List<int>> teams) {
    if (isEmpty) return 0;
    var overlap = 0.0;
    var pairs = 0;
    for (final team in teams) {
      for (var a = 0; a < team.length; a++) {
        for (var b = a + 1; b < team.length; b++) {
          overlap += _pairWeight[team[a] * _n + team[b]];
          pairs++;
        }
      }
    }
    var result = pairs == 0 ? 0.0 : overlap / pairs;

    for (var h = 0; h < _historyTeams.length; h++) {
      for (final team in teams) {
        if (team.length < 2) continue;
        final members = team.toSet();
        for (final past in _historyTeams[h]) {
          final inter = past.where(members.contains).length;
          if (inter >= sameTeamThreshold * team.length) {
            result += sameTeamPenalty * decay[h];
            break;
          }
        }
      }
    }
    return result;
  }

  /// 직전 편성에서도 같은 팀이었던 선수 쌍 수.
  int repeatedPairsWithLatest(List<List<int>> teams) {
    var count = 0;
    for (final team in teams) {
      for (var a = 0; a < team.length; a++) {
        for (var b = a + 1; b < team.length; b++) {
          if (_latestPair[team[a] * _n + team[b]]) count++;
        }
      }
    }
    return count;
  }
}

/// 두 편성의 차이 (0~1): 1 − (팀끼리 최대로 짝지었을 때 겹치는 인원 / 전체 인원).
/// "서로 30% 이상 다른 편성안" 판정에 쓴다.
double lineupDistance(List<Set<String>> a, List<Set<String>> b) {
  final all = {...a.expand((e) => e), ...b.expand((e) => e)};
  if (all.isEmpty) return 0;
  final k = a.length > b.length ? a.length : b.length;
  final padA = [...a, for (var i = a.length; i < k; i++) <String>{}];
  final padB = [...b, for (var i = b.length; i < k; i++) <String>{}];

  var best = 0;
  final used = List.filled(k, false);
  void dfs(int i, int sum) {
    if (i == k) {
      if (sum > best) best = sum;
      return;
    }
    for (var j = 0; j < k; j++) {
      if (used[j]) continue;
      used[j] = true;
      dfs(i + 1, sum + padA[i].intersection(padB[j]).length);
      used[j] = false;
    }
  }

  dfs(0, 0);
  return 1 - best / all.length;
}
