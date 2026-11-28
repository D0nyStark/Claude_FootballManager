import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../../core/scoring/metrics.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../common/common_widgets.dart';
import 'constraints_view.dart';
import 'player_editor.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';

/// 선수 관리 (SPEC F1): 왼쪽 목록 | 오른쪽 상세·편집 2단 구성.
class PlayersView extends ConsumerStatefulWidget {
  const PlayersView({super.key, required this.group});

  final GroupInfo group;

  @override
  ConsumerState<PlayersView> createState() => _PlayersViewState();
}

enum _Tab { players, constraints }

class _PlayersViewState extends ConsumerState<PlayersView> {
  _Tab _tab = _Tab.players;
  String _query = '';
  PlayerSort _sort = PlayerSort.name;
  Position? _filter;

  /// 선택한 선수 id. [_newPlayer]가 true면 새 선수 입력 중.
  String? _selectedId;
  bool _newPlayer = false;

  bool get _canSeeStats => widget.group.role.canSeeStats;

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider(widget.group.id));
    final narrow = isNarrow(context);
    final showDetail =
        narrow && _tab == _Tab.players && (_newPlayer || _selectedId != null);
    return TutorialHost(
      screen: TutorialScreen.players,
      ready: players.hasValue,
      steps: () => TutorialSteps.players(canSeeStats: _canSeeStats),
      child: narrow
          // 세로: 목록 ↔ 편집 폼을 한 화면씩. 편집 중 ← 는 목록으로 돌아간다.
          ? PopScope(
              canPop: !showDetail,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) {
                  setState(() {
                    _selectedId = null;
                    _newPlayer = false;
                  });
                }
              },
              child: showDetail
                  ? _detail(players.value ?? const [])
                  : LayoutBuilder(
                      builder: (context, box) => _leftPanel(
                        players,
                        compact: box.maxHeight < _compactHeight,
                      ),
                    ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 320,
                  // 키보드가 올라오는 등 남는 높이가 적으면 탭·필터를 숨긴다 (가로 화면).
                  // Scaffold 안쪽에서는 키보드 높이가 0으로 전달되므로 실제 높이로 판단한다.
                  child: LayoutBuilder(
                    builder: (context, box) => _leftPanel(
                      players,
                      compact: box.maxHeight < _compactHeight,
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _detail(players.value ?? const [])),
              ],
            ),
    );
  }

  /// 이보다 낮으면 선수 목록을 간단히 (검색 + 목록만).
  static const double _compactHeight = 240;

  Widget _leftPanel(
    AsyncValue<List<Player>> players, {
    required bool compact,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!compact)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: CoachTarget(
            id: 'players.constraints',
            child: SegmentedButton<_Tab>(
              segments: const [
                ButtonSegment(value: _Tab.players, label: Text('선수')),
                ButtonSegment(
                  value: _Tab.constraints,
                  label: Text('같은 팀/다른 팀'),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
        ),
      Expanded(
        child: _tab == _Tab.players
            ? players.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (all) => _playerList(all, compact: compact),
              )
            : ConstraintsView(
                groupId: widget.group.id,
                players: players.value ?? const [],
              ),
      ),
    ],
  );

  Widget _playerList(List<Player> all, {bool compact = false}) {
    final theme = Theme.of(context);
    final q = _query.trim();
    final filtered = [
      for (final p in all)
        if ((q.isEmpty ||
                p.name.contains(q) ||
                (p.nickname?.contains(q) ?? false)) &&
            (_filter == null || p.mainPosition == _filter))
          p,
    ];
    final sorted = sortPlayers(
      filtered,
      _canSeeStats ? _sort : PlayerSort.name,
    );
    final split = splitByMemberType(sorted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: '검색',
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (_canSeeStats)
                PopupMenuButton<PlayerSort>(
                  tooltip: '정렬',
                  icon: const Icon(Icons.sort),
                  initialValue: _sort,
                  onSelected: (s) => setState(() => _sort = s),
                  itemBuilder: (_) => [
                    for (final s in PlayerSort.values)
                      PopupMenuItem(value: s, child: Text('${s.label} 순')),
                  ],
                ),
              CoachTarget(
                id: 'players.add',
                child: IconButton.filledTonal(
                  tooltip: '선수 추가',
                  icon: const Icon(Icons.person_add),
                  onPressed: () => setState(() {
                    _newPlayer = true;
                    _selectedId = null;
                  }),
                ),
              ),
            ],
          ),
        ),
        if (!compact)
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                for (final pos in [null, ...Position.values])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(pos?.label ?? '전체'),
                      selected: _filter == pos,
                      onSelected: (_) => setState(() => _filter = pos),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: all.isEmpty
              ? const Center(child: Text('선수를 추가해 주세요.'))
              : CoachTarget(
                  id: 'players.list',
                  child: ListView(
                    children: [
                      _section(theme, '⭐ 주멤버', split.core),
                      _section(theme, '👤 일반멤버', split.regular),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _section(ThemeData theme, String title, List<Player> players) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              '$title (${players.length})',
              style: theme.textTheme.labelLarge,
            ),
          ),
          for (final p in players)
            ListTile(
              dense: true,
              selected: p.id == _selectedId,
              title: Row(
                children: [
                  Flexible(
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  ),
                  if (p.nickname != null) ...[
                    const SizedBox(width: 4),
                    Text('(${p.nickname})', style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(width: 6),
                  PositionBadge(p.mainPosition),
                  if (p.canKeep) const Text(' 🧤'),
                  if (_canSeeStats && p.statsSimple) ...[
                    const SizedBox(width: 4),
                    const TagBadge('간단'),
                  ],
                ],
              ),
              trailing: _canSeeStats
                  ? Text(
                      p.stats.ovr.toStringAsFixed(1),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800, // 핵심 숫자
                      ),
                    )
                  : null,
              onTap: () => setState(() {
                _selectedId = p.id;
                _newPlayer = false;
              }),
            ),
        ],
      );

  Widget _detail(List<Player> all) {
    Player? selected;
    for (final p in all) {
      if (p.id == _selectedId) selected = p;
    }
    if (!_newPlayer && selected == null) {
      return const Center(child: Text('선수를 선택하거나 추가하세요.'));
    }
    return PlayerEditor(
      key: ValueKey(_newPlayer ? 'new' : selected!.id),
      groupId: widget.group.id,
      player: _newPlayer ? null : selected,
      canSeeStats: _canSeeStats,
      onSaved: (id) => setState(() {
        _selectedId = id;
        _newPlayer = false;
      }),
      onDeleted: () => setState(() {
        _selectedId = null;
        _newPlayer = false;
      }),
    );
  }
}

/// 목록 정렬: 이름(가나다) 또는 지표 높은 순.
List<Player> sortPlayers(List<Player> players, PlayerSort sort) {
  double metric(Player p) {
    final m = PlayerMetrics.of(p);
    return switch (sort) {
      PlayerSort.name => 0,
      PlayerSort.ovr => m.ovr,
      PlayerSort.attack => m.attack,
      PlayerSort.defense => m.defense,
    };
  }

  return [...players]..sort((a, b) {
    if (sort == PlayerSort.name) return a.name.compareTo(b.name);
    final c = metric(b).compareTo(metric(a));
    return c != 0 ? c : a.name.compareTo(b.name);
  });
}
