import 'position.dart';

/// 구장 위 포지션 원(슬롯). [position]이 null이면 골키퍼 자리.
enum Slot {
  gk(null, 'GK'),
  fixo1(Position.fixo, '픽소'),
  fixo2(Position.fixo, '픽소'),
  alaLeft(Position.ala, '아라'),
  alaRight(Position.ala, '아라'),
  pivo(Position.pivo, '피보');

  const Slot(this.position, this.label);

  final Position? position;
  final String label;

  bool get isKeeper => position == null;
}

/// 매치 형식 (SPEC §3). [playersPerTeam]은 키퍼 포함 경기장 인원 N.
enum MatchFormat {
  fiveVsFive(5, '5 vs 5'),
  sixVsSix(6, '6 vs 6');

  const MatchFormat(this.playersPerTeam, this.label);

  final int playersPerTeam;
  final String label;

  /// 포메이션 슬롯. 5인: GK·픽소1·아라2·피보1 / 6인: GK·픽소2·아라2·피보1.
  List<Slot> get slots => switch (this) {
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
    (MatchFormat.fiveVsFive, Slot.fixo1) => (x: 0.50, y: 0.66),
    (MatchFormat.sixVsSix, Slot.fixo1) => (x: 0.25, y: 0.68),
    (_, Slot.fixo2) => (x: 0.75, y: 0.68),
    (_, Slot.alaLeft) => (x: 0.04, y: 0.36),
    (_, Slot.alaRight) => (x: 0.96, y: 0.36),
    (_, Slot.pivo) => (x: 0.50, y: 0.04),
  };
}
