/// 멤버 구분 (SPEC §4.1). 출전 덱 화면에서 주멤버가 먼저 표시된다.
enum MemberType {
  core('주멤버'),
  regular('일반멤버');

  const MemberType(this.label);

  final String label;
}
