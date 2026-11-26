import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/balancer/balancer.dart';
import '../../core/models/models.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/session/match_session.dart';
import '../../core/scoring/weights.dart';

/// 출전 덱·팀 설정 화면의 상태. 바뀔 때마다 기기에 저장한다 (SPEC F2.5).
class MatchSessionController extends ChangeNotifier {
  MatchSessionController({
    required this.groupId,
    required SessionRepository repository,
    required MatchSession initial,
  }) : _repo = repository,
       _session = initial;

  final String groupId;
  final SessionRepository _repo;
  MatchSession _session;

  MatchSession get session => _session;

  void _update(MatchSession next) {
    _session = next;
    notifyListeners();
    _repo.save(groupId, next);
  }

  bool inDeck(String id) => _session.deckIds.contains(id);

  void toggle(String id) {
    if (!inDeck(id)) {
      _update(_session.copyWith(deckIds: [..._session.deckIds, id]));
      return;
    }
    // 덱에서 빼면 그 선수를 쓰는 키퍼 지정도 함께 푼다.
    _update(
      _session.copyWith(
        deckIds: [
          for (final d in _session.deckIds)
            if (d != id) d,
        ],
        fixedKeepers: {
          for (final e in _session.fixedKeepers.entries)
            if (e.value != id) e.key: e.value,
        },
      ),
    );
  }

  /// 주멤버 전체 선택: 모두 올라가 있으면 모두 내린다.
  void toggleAll(List<String> ids) {
    final allIn = ids.every(inDeck);
    _update(
      _session.copyWith(
        deckIds: allIn
            ? [
                for (final d in _session.deckIds)
                  if (!ids.contains(d)) d,
              ]
            : [
                ..._session.deckIds,
                for (final id in ids)
                  if (!inDeck(id)) id,
              ],
      ),
    );
  }

  void addGuest(Player guest) => _update(
    _session.copyWith(
      guests: [..._session.guests, guest],
      deckIds: [..._session.deckIds, guest.id],
    ),
  );

  void removeGuest(String id) => _update(
    _session.copyWith(
      guests: [
        for (final g in _session.guests)
          if (g.id != id) g,
      ],
      deckIds: [
        for (final d in _session.deckIds)
          if (d != id) d,
      ],
    ),
  );

  void setFormat(MatchFormat format) =>
      _update(_session.copyWith(format: format));

  void setTeamCount(int count) => _update(
    _session.copyWith(
      teamCount: count.clamp(MatchSession.minTeams, MatchSession.maxTeams),
      fixedKeepers: {
        for (final e in _session.fixedKeepers.entries)
          if (e.key < count) e.key: e.value,
      },
    ),
  );

  void setKeeperMode(KeeperMode mode) =>
      _update(_session.copyWith(keeperMode: mode));

  /// 팀 [team]의 고정 키퍼 지정. 같은 선수가 다른 팀에 지정돼 있으면 옮긴다.
  void setKeeper(int team, String? playerId) {
    final keepers = {
      for (final e in _session.fixedKeepers.entries)
        if (e.value != playerId && e.key != team) e.key: e.value,
    };
    if (playerId != null) keepers[team] = playerId;
    _update(_session.copyWith(fixedKeepers: keepers));
  }

  void autoAssignKeepers(List<Player> deck, {math.Random? rng}) => _update(
    _session.copyWith(
      fixedKeepers: autoAssignKeepersFor(
        deck,
        _session.teamCount,
        rng ?? math.Random(),
      ),
    ),
  );

  void addDayConstraint(ConstraintType type, Set<String> ids) => _update(
    _session.copyWith(
      dayConstraints: [
        ..._session.dayConstraints,
        TeamConstraint(
          id: 'day-${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          playerIds: ids,
        ),
      ],
    ),
  );

  void removeDayConstraint(TeamConstraint c) => _update(
    _session.copyWith(
      dayConstraints: [
        for (final d in _session.dayConstraints)
          if (d != c) d,
      ],
    ),
  );

  /// 등록 선수가 바뀌었을 때(삭제 등) 정리.
  void sync(List<Player> registered) {
    final pruned = _session.prune(registered);
    if (pruned.deckIds.length != _session.deckIds.length ||
        pruned.fixedKeepers.length != _session.fixedKeepers.length ||
        pruned.dayConstraints.length != _session.dayConstraints.length) {
      _update(pruned);
    }
  }
}

/// 자동 편성 요청 만들기: 출전 덱 + 상시 제약 + 당일 제약 (SPEC §6.1).
BalanceRequest buildBalanceRequest({
  required MatchSession session,
  required List<Player> registered,
  required List<TeamConstraint> groupConstraints,
  int seed = 0,
  List<Lineup> avoid = const [],
  List<LineupHistoryEntry> history = const [],
  RepeatAvoidance repeatAvoidance = RepeatAvoidance.medium,
  BalanceWeights? weights,
}) => BalanceRequest(
  players: session.deck(registered),
  format: session.format,
  teamCount: session.teamCount,
  keeperMode: session.keeperMode,
  fixedKeepers: session.keeperMode == KeeperMode.fixed
      ? session.fixedKeepers
      : const {},
  constraints: [...groupConstraints, ...session.dayConstraints],
  history: history,
  repeatAvoidance: repeatAvoidance,
  balanceWeights: weights,
  avoidLineups: avoid,
  seed: seed,
);

/// 키퍼 고정 [자동 배정] (엔진의 autoAssignKeepers와 같음).
Map<int, String> autoAssignKeepersFor(
  List<Player> deck,
  int teamCount,
  math.Random rng,
) => autoAssignKeepers(deck, teamCount, rng);
