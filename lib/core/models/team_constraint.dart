/// 골키퍼 모드 (SPEC F3.2).
enum KeeperMode {
  /// 돌아가며 키퍼 (기본). 모두 필드 선수로 균형을 맞춘다.
  rotation,

  /// 팀별 키퍼를 지정해 고정. 고정 키퍼는 전력 계산에서 제외.
  fixed,
}

enum ConstraintType {
  together('같은 팀'),
  apart('다른 팀');

  const ConstraintType(this.label);

  final String label;
}

/// "A와 B는 같은 팀" / "A와 B는 다른 팀" 제약.
class TeamConstraint {
  TeamConstraint({
    required this.type,
    required Set<String> playerIds,
    this.id,
    this.note,
  }) : playerIds = Set.unmodifiable(playerIds) {
    if (playerIds.length < 2) {
      throw ArgumentError('제약에는 2명 이상이 필요합니다');
    }
  }

  final String? id;
  final ConstraintType type;
  final Set<String> playerIds;
  final String? note;

  @override
  String toString() => 'TeamConstraint(${type.name}, $playerIds)';
}
