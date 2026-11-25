/// 모임 안에서 이 기기 사용자의 역할 (SPEC F13.5).
enum GroupRole {
  owner('모임장'),
  manager('운영진'),
  member('멤버');

  const GroupRole(this.label);

  final String label;

  /// 능력치 보기·수정은 모임장·운영진만.
  bool get canSeeStats => this != GroupRole.member;
}
