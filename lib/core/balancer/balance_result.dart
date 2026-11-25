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
  });

  final Lineup lineup;
  final BalanceBreakdown balance;

  /// 이전 편성과 겹치는 정도 (0이면 겹침 없음).
  final double repetitionPenalty;

  /// 직전 편성에서도 같은 팀이었던 선수 쌍 수 ("지난 편성과 겹침: N쌍").
  final int repeatedPairs;
}

/// 편성할 수 없는 이유.
class BalanceIssue {
  const BalanceIssue(this.message, {this.constraint});

  final String message;
  final TeamConstraint? constraint;

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
