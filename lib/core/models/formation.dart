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

  /// 반코트 좌표 (0~1, 아래쪽이 자기 골대) — SPEC §7.1.
  ({double x, double y}) coordinateOf(Slot slot) => switch ((this, slot)) {
    (_, Slot.gk) => (x: 0.50, y: 0.92),
    (MatchFormat.fiveVsFive, Slot.fixo1) => (x: 0.50, y: 0.70),
    (MatchFormat.sixVsSix, Slot.fixo1) => (x: 0.32, y: 0.70),
    (_, Slot.fixo2) => (x: 0.68, y: 0.70),
    (MatchFormat.fiveVsFive, Slot.alaLeft) => (x: 0.15, y: 0.48),
    (MatchFormat.sixVsSix, Slot.alaLeft) => (x: 0.15, y: 0.45),
    (MatchFormat.fiveVsFive, Slot.alaRight) => (x: 0.85, y: 0.48),
    (MatchFormat.sixVsSix, Slot.alaRight) => (x: 0.85, y: 0.45),
    (MatchFormat.fiveVsFive, Slot.pivo) => (x: 0.50, y: 0.22),
    (MatchFormat.sixVsSix, Slot.pivo) => (x: 0.50, y: 0.20),
  };
}
