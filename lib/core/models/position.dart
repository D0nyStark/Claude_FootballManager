/// 풋살 필드 포지션 (SPEC §4.3). 골키퍼는 로테이션이 기본이라 선수 속성이 아니다.
enum Position {
  fixo('픽소'),
  ala('아라'),
  pivo('피보');

  const Position(this.label);

  /// 화면 표시용 한글 이름.
  final String label;
}
