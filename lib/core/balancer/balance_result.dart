import '../models/lineup.dart';
import '../models/team_constraint.dart';
import '../scoring/balance_score.dart';

/// 편성안 하나.
class LineupCandidate {
  const LineupCandidate({
    required this.lineup,
    required this.balance,
    required this.repetitionPenalty,
    required this.repeatedPairs,
    this.unmetConstraints = const [],
  });

  final Lineup lineup;
  final BalanceBreakdown balance;

  /// 이전 편성과 겹치는 정도 (0이면 겹침 없음).
  final double repetitionPenalty;

  /// 직전 편성에서도 같은 팀이었던 선수 쌍 수 ("지난 편성과 겹침: N쌍").
  final int repeatedPairs;

  /// 서로 충돌해 지키지 못한 "다른 팀" 제약 (화면에는 표시하지 않는다).
  final List<TeamConstraint> unmetConstraints;
}

/// 잘못된 입력(팀 수 범위, 인원 부족, 중복 선수) — 화면에서 미리 막는 경우라 사용자에게 보이지 않는다.
/// 제약 조건 충돌은 실패가 아니라 최대한 지킨 편성으로 처리한다.
class BalanceIssue {
  const BalanceIssue(this.message);

  final String message;

  @override
  String toString() => message;
}

sealed class BalanceResult {
  const BalanceResult();
}

class BalanceSuccess extends BalanceResult {
  const BalanceSuccess(this.candidates);

  /// 최대 3개, 추천 순.
  final List<LineupCandidate> candidates;

  LineupCandidate get best => candidates.first;
}

class BalanceFailure extends BalanceResult {
  const BalanceFailure(this.issues);

  final List<BalanceIssue> issues;
}
