/// 밸런스 등급 (SPEC F5.4).
enum BalanceGrade {
  excellent('매우 좋음', 90),
  good('좋음', 75),
  fair('보통', 60),
  poor('불균형', 0);

  const BalanceGrade(this.label, this.minScore);

  final String label;
  final int minScore;

  static BalanceGrade of(double score) =>
      values.firstWhere((g) => score.round() >= g.minScore);
}

/// 팀 하나의 요약 (화면 상단 팀별 요약 줄).
class TeamSummary {
  const TeamSummary({
    required this.ovr,
    required this.attack,
    required this.defense,
    required this.size,
    required this.fieldSlots,
    required this.fieldCount,
    required this.benchCount,
  });

  /// 슬롯 정규화된 팀 평균 (1~5).
  final double ovr;
  final double attack;
  final double defense;

  /// 팀 전체 인원 (키퍼·후보 포함).
  final int size;

  /// 비교 기준 필드 슬롯 수 F.
  final int fieldSlots;

  /// 필드 선수 수 (고정 키퍼 제외).
  final int fieldCount;
  final int benchCount;

  /// 부족 팀 여부 — 빈 자리를 덱 평균 가상 선수로 보정했다.
  bool get isShort => fieldCount < fieldSlots;
}

/// 밸런스 점수 (0~100)와 세부 지표.
class BalanceBreakdown {
  const BalanceBreakdown({
    required this.total,
    required this.strength,
    required this.attack,
    required this.defense,
    required this.position,
    required this.teams,
  });

  final double total;
  final double strength;
  final double attack;
  final double defense;
  final double position;
  final List<TeamSummary> teams;

  int get rounded => total.round();

  BalanceGrade get grade => BalanceGrade.of(total);

  @override
  String toString() =>
      'Balance(${total.toStringAsFixed(1)}: 전력 ${strength.toStringAsFixed(0)}'
      ' 공격 ${attack.toStringAsFixed(0)} 수비 ${defense.toStringAsFixed(0)}'
      ' 포지션 ${position.toStringAsFixed(0)})';
}
