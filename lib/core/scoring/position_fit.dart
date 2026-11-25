import '../models/formation.dart';
import '../models/player.dart';
import '../models/position.dart';

/// 팀 내 자리 배치 결과.
class SlotAssignment {
  const SlotAssignment(this.slots, this.fit);

  final Map<Slot, Player> slots;

  /// 적합도 합 (주 포지션 2, 가능 포지션 1).
  final int fit;
}

/// [players]를 [fieldSlots]에 배치해 적합도 합이 최대인 배치를 찾는다.
/// 팀당 필드 선수는 최대 5명이므로 완전 탐색(최대 5! = 120)으로 충분하다.
/// 선수 수가 슬롯 수보다 많으면 앞쪽 슬롯 수만큼만 배치한다.
SlotAssignment bestFieldAssignment(
  List<Player> players,
  List<Slot> fieldSlots,
) {
  final n = players.length < fieldSlots.length
      ? players.length
      : fieldSlots.length;
  final used = List<bool>.filled(fieldSlots.length, false);
  final current = List<int>.filled(n, -1);
  var best = -1;
  var bestChoice = List<int>.filled(n, -1);

  void dfs(int i, int score) {
    if (i == n) {
      if (score > best) {
        best = score;
        bestChoice = List.of(current);
      }
      return;
    }
    // 남은 선수가 모두 주 포지션(2점)을 받아도 최고 기록을 못 넘으면 가지치기.
    if (score + 2 * (n - i) <= best) return;
    for (var s = 0; s < fieldSlots.length; s++) {
      if (used[s]) continue;
      used[s] = true;
      current[i] = s;
      dfs(i + 1, score + players[i].fitFor(fieldSlots[s].position!));
      used[s] = false;
    }
  }

  dfs(0, 0);
  return SlotAssignment({
    for (var i = 0; i < n; i++) fieldSlots[bestChoice[i]]: players[i],
  }, best < 0 ? 0 : best);
}

/// 탐색 중 빠른 근사 적합도: 포지션 그룹 단위 매칭.
/// [fill]은 실제로 채워질 필드 슬롯 수. 반환값은 0~1 비율.
double estimateFitRatio(
  Iterable<Player> players,
  Map<Position, int> demand,
  int fill,
) {
  if (fill <= 0) return 1;
  final remaining = Map.of(demand);
  final surplus = <Player>[];
  var fit = 0;
  var filled = 0;
  for (final p in players) {
    final left = remaining[p.mainPosition] ?? 0;
    if (left > 0 && filled < fill) {
      remaining[p.mainPosition] = left - 1;
      fit += 2;
      filled++;
    } else {
      surplus.add(p);
    }
  }
  for (final p in surplus) {
    if (filled >= fill) break;
    for (final sub in p.subPositions) {
      final left = remaining[sub] ?? 0;
      if (left > 0) {
        remaining[sub] = left - 1;
        fit += 1;
        filled++;
        break;
      }
    }
  }
  return fit / (2 * fill);
}
