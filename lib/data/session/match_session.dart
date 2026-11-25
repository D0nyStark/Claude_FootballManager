import '../../core/models/models.dart';

/// 진행 중인 매치 준비 상태 (SPEC §7 SessionDraft).
///
/// 출전 덱·게스트·팀 수·키퍼 모드·당일 제약을 담고, 앱이 꺼져도 이어서 할 수 있게
/// 모임별로 저장된다 (SPEC F2.5). 다른 기기와 공유되지 않는다.
class MatchSession {
  MatchSession({
    required this.format,
    List<String> deckIds = const [],
    List<Player> guests = const [],
    this.teamCount = 2,
    this.keeperMode = KeeperMode.rotation,
    Map<int, String> fixedKeepers = const {},
    List<TeamConstraint> dayConstraints = const [],
  }) : deckIds = List.unmodifiable(deckIds),
       guests = List.unmodifiable(guests),
       fixedKeepers = Map.unmodifiable(fixedKeepers),
       dayConstraints = List.unmodifiable(dayConstraints);

  final MatchFormat format;

  /// 출전 덱에 올린 등록 선수·게스트 id (올린 순서).
  final List<String> deckIds;

  /// 오늘만 참가하는 게스트 (선수로 저장하지 않은 사람).
  final List<Player> guests;
  final int teamCount;
  final KeeperMode keeperMode;
  final Map<int, String> fixedKeepers;
  final List<TeamConstraint> dayConstraints;

  static const int minTeams = 2;
  static const int maxTeams = 4;

  MatchSession copyWith({
    MatchFormat? format,
    List<String>? deckIds,
    List<Player>? guests,
    int? teamCount,
    KeeperMode? keeperMode,
    Map<int, String>? fixedKeepers,
    List<TeamConstraint>? dayConstraints,
  }) => MatchSession(
    format: format ?? this.format,
    deckIds: deckIds ?? this.deckIds,
    guests: guests ?? this.guests,
    teamCount: teamCount ?? this.teamCount,
    keeperMode: keeperMode ?? this.keeperMode,
    fixedKeepers: fixedKeepers ?? this.fixedKeepers,
    dayConstraints: dayConstraints ?? this.dayConstraints,
  );

  /// 출전 덱 선수 목록. [registered]는 모임에 등록된 선수 (삭제된 선수는 빠진다).
  List<Player> deck(Iterable<Player> registered) {
    final byId = {
      for (final p in registered) p.id: p,
      for (final g in guests) g.id: g,
    };
    return [
      for (final id in deckIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  /// 삭제된 선수·출전 덱에서 빠진 사람을 정리한다.
  MatchSession prune(Iterable<Player> registered) {
    final valid = {
      for (final p in registered) p.id,
      for (final g in guests) g.id,
    };
    final deck = [
      for (final id in deckIds)
        if (valid.contains(id)) id,
    ];
    final inDeck = deck.toSet();
    return copyWith(
      deckIds: deck,
      fixedKeepers: {
        for (final e in fixedKeepers.entries)
          if (inDeck.contains(e.value) && e.key < teamCount) e.key: e.value,
      },
      dayConstraints: [
        for (final c in dayConstraints)
          if (c.playerIds.where(inDeck.contains).length >= 2) c,
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'v': 1,
    'format': format.name,
    'deck': deckIds,
    'guests': [for (final g in guests) _playerToJson(g)],
    'teamCount': teamCount,
    'keeperMode': keeperMode.name,
    'keepers': {for (final e in fixedKeepers.entries) '${e.key}': e.value},
    'constraints': [
      for (final c in dayConstraints)
        {'type': c.type.name, 'ids': c.playerIds.toList(), 'id': c.id},
    ],
  };

  factory MatchSession.fromJson(Map<String, Object?> json) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return MatchSession(
      format: byName(
        MatchFormat.values,
        json['format'],
        MatchFormat.fiveVsFive,
      ),
      deckIds: [...?(json['deck'] as List?)?.cast<String>()],
      guests: [
        for (final g in (json['guests'] as List?) ?? const [])
          _playerFromJson((g as Map).cast<String, Object?>()),
      ],
      teamCount: ((json['teamCount'] as int?) ?? 2).clamp(minTeams, maxTeams),
      keeperMode: byName(
        KeeperMode.values,
        json['keeperMode'],
        KeeperMode.rotation,
      ),
      fixedKeepers: {
        for (final e in ((json['keepers'] as Map?) ?? const {}).entries)
          int.parse(e.key as String): e.value as String,
      },
      dayConstraints: [
        for (final c in (json['constraints'] as List?) ?? const [])
          if (((c as Map)['ids'] as List).length >= 2)
            TeamConstraint(
              id: c['id'] as String?,
              type: byName(
                ConstraintType.values,
                c['type'],
                ConstraintType.together,
              ),
              playerIds: (c['ids'] as List).cast<String>().toSet(),
            ),
      ],
    );
  }

  static Map<String, Object?> _playerToJson(Player p) => {
    'id': p.id,
    'name': p.name,
    'stats': [for (final s in Stat.values) p.stats[s]],
    'main': p.mainPosition.name,
  };

  static Player _playerFromJson(Map<String, Object?> j) {
    final stats = (j['stats'] as List).cast<int>();
    return Player(
      id: j['id'] as String,
      name: j['name'] as String,
      stats: PlayerStats.fromMap({
        for (var i = 0; i < Stat.values.length; i++) Stat.values[i]: stats[i],
      }),
      mainPosition: Position.values.byName(j['main'] as String),
      isGuest: true,
      statsSimple: true,
    );
  }
}
