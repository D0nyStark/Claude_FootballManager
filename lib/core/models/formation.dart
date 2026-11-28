import 'position.dart';

/// 구장 위 포지션 원(슬롯). [position]이 null이면 골키퍼 자리.
enum Slot {
  gk(null, 'GK'),
  fixo1(Position.fixo, '픽소'),
  fixo2(Position.fixo, '픽소'),
  alaLeft(Position.ala, '아라'),
  alaRight(Position.ala, '아라'),
  pivo(Position.pivo, '피보'),
  // 7vs7 두 번째 피보 (저장은 이름으로 하므로 맨 뒤에 추가해도 예전 데이터와 호환).
  pivo2(Position.pivo, '피보');

  const Slot(this.position, this.label);

  final Position? position;
  final String label;

  bool get isKeeper => position == null;
}

/// 매치 형식 (SPEC §3). [playersPerTeam]은 키퍼 포함 경기장 인원 N.
enum MatchFormat {
  fourVsFour(4, '4 vs 4'),
  fiveVsFive(5, '5 vs 5'),
  sixVsSix(6, '6 vs 6'),
  sevenVsSeven(7, '7 vs 7');

  const MatchFormat(this.playersPerTeam, this.label);

  final int playersPerTeam;
  final String label;

  /// 짧은 표기 (공유 텍스트 등): 5vs5.
  String get short => '${playersPerTeam}vs$playersPerTeam';

  /// 포메이션 슬롯.
  /// 4인: GK·픽소1·아라2 / 5인: GK·픽소1·아라2·피보1 /
  /// 6인: GK·픽소2·아라2·피보1 / 7인: GK·픽소2·아라2·피보2.
  List<Slot> get slots => switch (this) {
    MatchFormat.fourVsFour => const [
      Slot.gk,
      Slot.fixo1,
      Slot.alaLeft,
      Slot.alaRight,
    ],
    MatchFormat.fiveVsFive => const [
      Slot.gk,
      Slot.fixo1,
      Slot.alaLeft,
      Slot.alaRight,
      Slot.pivo,
    ],
    MatchFormat.sixVsSix => const [
      Slot.gk,
      Slot.fixo1,
      Slot.fixo2,
      Slot.alaLeft,
      Slot.alaRight,
      Slot.pivo,
    ],
    MatchFormat.sevenVsSeven => const [
      Slot.gk,
      Slot.fixo1,
      Slot.fixo2,
      Slot.alaLeft,
      Slot.alaRight,
      Slot.pivo,
      Slot.pivo2,
    ],
  };

  /// 골키퍼를 제외한 필드 슬롯.
  List<Slot> get fieldSlots => slots.where((s) => !s.isKeeper).toList();

  /// 포지션별 필드 슬롯 수.
  Map<Position, int> get positionDemand {
    final demand = {for (final p in Position.values) p: 0};
    for (final s in fieldSlots) {
      demand[s.position!] = demand[s.position!]! + 1;
    }
    return demand;
  }

  /// 반코트 위 원의 위치 (0~1, 아래쪽이 자기 골대) — SPEC §7.1.
  ///
  /// 원이 구장 밖으로 나가지 않도록 화면에서는 (구장 크기 − 원 지름) 범위에 매핑한다.
  /// 구장이 작아져도(4팀) 원끼리 겹치지 않게 위아래 간격을 넉넉히 둔다.
  ({double x, double y}) coordinateOf(Slot slot) => switch ((this, slot)) {
    (_, Slot.gk) => (x: 0.50, y: 1.00),
    // 4vs4: 뒤 픽소 1명 + 앞 양쪽 아라 2명 (삼각형).
    (MatchFormat.fourVsFour, Slot.fixo1) => (x: 0.50, y: 0.62),
    (MatchFormat.fourVsFour, Slot.alaLeft) => (x: 0.12, y: 0.16),
    (MatchFormat.fourVsFour, Slot.alaRight) => (x: 0.88, y: 0.16),
    (MatchFormat.fiveVsFive, Slot.fixo1) => (x: 0.50, y: 0.66),
    // 6vs6·7vs7: 픽소 2명을 아라와 같은 세로줄에 두어 육각형 구조로.
    (MatchFormat.sixVsSix || MatchFormat.sevenVsSeven, Slot.fixo1) => (
      x: 0.04,
      y: 0.68,
    ),
    (_, Slot.fixo2) => (x: 0.96, y: 0.68),
    (_, Slot.alaLeft) => (x: 0.04, y: 0.36),
    (_, Slot.alaRight) => (x: 0.96, y: 0.36),
    // 7vs7: 6vs6 육각형 + 피보 2명을 앞쪽 양옆으로.
    (MatchFormat.sevenVsSeven, Slot.pivo) => (x: 0.28, y: 0.04),
    (MatchFormat.sevenVsSeven, Slot.pivo2) => (x: 0.72, y: 0.04),
    (_, Slot.pivo) => (x: 0.50, y: 0.04),
    (_, Slot.pivo2) => (x: 0.72, y: 0.04),
  };
}
