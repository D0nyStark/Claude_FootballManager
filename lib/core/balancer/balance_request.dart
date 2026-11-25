import '../models/formation.dart';
import '../models/lineup.dart';
import '../models/player.dart';
import '../models/team_constraint.dart';

/// 반복 조합 회피 강도 (SPEC F4.6, §6.6). [weight]는 밸런스 점수 환산 페널티.
enum RepeatAvoidance {
  off(0),
  weak(3),
  medium(6),
  strong(10);

  const RepeatAvoidance(this.weight);

  final double weight;
}

/// 자동 편성 입력 (SPEC §6.1).
class BalanceRequest {
  BalanceRequest({
    required this.players,
    required this.format,
    this.teamCount = 2,
    this.keeperMode = KeeperMode.rotation,
    this.fixedKeepers = const {},
    this.constraints = const [],
    this.pinnedTeams = const {},
    this.pinnedSlots = const {},
    this.history = const [],
    this.repeatAvoidance = RepeatAvoidance.medium,
    this.avoidLineups = const [],
    this.seed = 0,
    this.maxCandidates = 3,
    this.restarts = 10,
    this.iterations = 4000,
  });

  static const int minTeams = 2;
  static const int maxTeams = 4;

  /// 출전 덱.
  final List<Player> players;
  final MatchFormat format;
  final int teamCount;
  final KeeperMode keeperMode;

  /// 키퍼 고정 모드: 팀 번호 → 고정 키퍼 선수 id. 지정되지 않은 팀은 로테이션 취급.
  final Map<int, String> fixedKeepers;

  /// 상시 + 당일 제약. 출전 덱에 없는 선수는 무시된다.
  final List<TeamConstraint> constraints;

  /// 고정(Pin): 선수 id → 팀 번호. 고정된 선수는 후보가 되지 않는다.
  final Map<String, int> pinnedTeams;

  /// 자리까지 고정: 선수 id → 슬롯 ([pinnedTeams]에도 있어야 한다).
  final Map<String, Slot> pinnedSlots;

  /// 최근 확정 편성 (최신이 앞, 최대 3개 사용).
  final List<LineupHistoryEntry> history;
  final RepeatAvoidance repeatAvoidance;

  /// [다시 섞기] 시 이미 보여준 편성안 — 이와 충분히 다른 결과를 낸다.
  final List<Lineup> avoidLineups;

  /// 같은 입력 + 같은 시드 → 같은 결과.
  final int seed;
  final int maxCandidates;
  final int restarts;
  final int iterations;
}
