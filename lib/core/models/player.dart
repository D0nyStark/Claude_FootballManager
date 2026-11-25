import 'member_type.dart';
import 'player_stats.dart';
import 'position.dart';

/// 모임에 등록된 선수 (SPEC §4, §7 Player).
class Player {
  Player({
    required this.id,
    required this.name,
    required this.stats,
    required this.mainPosition,
    Set<Position> subPositions = const {},
    this.nickname,
    this.memberType = MemberType.regular,
    this.canKeep = false,
    this.isGuest = false,
  }) : subPositions = Set.unmodifiable(subPositions.difference({mainPosition}));

  final String id;
  final String name;
  final String? nickname;
  final MemberType memberType;
  final PlayerStats stats;
  final Position mainPosition;

  /// 가능 포지션 (주 포지션 제외, 0~2개).
  final Set<Position> subPositions;

  /// 키퍼 가능 여부: 키퍼 고정 자동 배정·로테이션 시작 키퍼 우선 대상.
  final bool canKeep;
  final bool isGuest;

  /// 포지션 적합도: 주 포지션 2, 가능 포지션 1, 그 외 0 (SPEC §6.5).
  int fitFor(Position position) {
    if (position == mainPosition) return 2;
    if (subPositions.contains(position)) return 1;
    return 0;
  }

  /// 화면 표시 이름 (별명 우선).
  String get displayName => nickname?.isNotEmpty == true ? nickname! : name;

  @override
  String toString() => 'Player($id, $name, ${mainPosition.label})';
}
