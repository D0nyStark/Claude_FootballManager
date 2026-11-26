import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/session/match_session.dart';
import '../common/common_widgets.dart';
import 'match_session_controller.dart';
import 'team_setup_page.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';

/// 출전 덱 구성 (SPEC F2, §8.3): 주멤버 | 일반멤버 | 출전 덱 3단.
class DeckPage extends ConsumerStatefulWidget {
  const DeckPage({super.key, required this.group, required this.format});

  final GroupInfo group;
  final MatchFormat format;

  @override
  ConsumerState<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends ConsumerState<DeckPage> {
  MatchSessionController? _controller;
  String _query = '';

  bool get _canSeeStats => widget.group.role.canSeeStats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 작성 중이던 덱이 있으면 이어서 (형식은 방금 고른 것으로).
  Future<void> _load() async {
    final repo = ref.read(sessionRepositoryProvider);
    final saved = await repo.load(widget.group.id);
    // 새로 시작하면 모임 설정의 기본 팀 수·키퍼 방식으로 (SPEC F10).
    final prefs = await ref
        .read(settingsRepositoryProvider)
        .load(widget.group.id);
    final initial =
        (saved ??
                MatchSession(
                  format: widget.format,
                  teamCount: prefs.defaultTeamCount,
                  keeperMode: prefs.defaultKeeperMode,
                ))
            .copyWith(format: widget.format);
    if (!mounted) return;
    setState(
      () => _controller = MatchSessionController(
        groupId: widget.group.id,
        repository: repo,
        initial: initial,
      )..addListener(_rebuild),
    );
    await repo.save(widget.group.id, initial);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller?.removeListener(_rebuild);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider(widget.group.id));
    final controller = _controller;
    return TutorialHost(
      screen: TutorialScreen.deck,
      ready: controller != null && players.hasValue,
      steps: () => TutorialSteps.deck,
      child: Scaffold(
        appBar: AppBar(
          title: Text('출전 덱 · ${widget.format.label}'),
          actions: [
            SizedBox(
              width: 220,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: '선수 검색',
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: controller == null || !players.hasValue
            ? const Center(child: CircularProgressIndicator())
            : _body(controller, players.value!),
      ),
    );
  }

  Widget _body(MatchSessionController c, List<Player> registered) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) c.sync(registered);
    });
    final visible = [
      for (final p in registered)
        if (_query.isEmpty ||
            p.name.contains(_query) ||
            (p.nickname?.contains(_query) ?? false))
          p,
    ]..sort((a, b) => a.name.compareTo(b.name));
    final split = splitByMemberType(visible);
    final allCoreIds = [
      for (final p in registered)
        if (p.memberType == MemberType.core) p.id,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _column(
            c,
            title: '⭐ 주멤버',
            players: split.core,
            action: allCoreIds.isEmpty
                ? null
                : CoachTarget(
                    id: 'deck.selectAll',
                    child: TextButton(
                      onPressed: () => c.toggleAll(allCoreIds),
                      child: Text(
                        allCoreIds.every(c.inDeck) ? '전체 해제' : '전체 선택',
                      ),
                    ),
                  ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: CoachTarget(
            id: 'deck.regular',
            child: _column(c, title: '👤 일반멤버', players: split.regular),
          ),
        ),
        const VerticalDivider(width: 1),
        CoachTarget(
          id: 'deck.panel',
          child: SizedBox(width: 250, child: _deckPanel(c, registered)),
        ),
      ],
    );
  }

  Widget _column(
    MatchSessionController c, {
    required String title,
    required List<Player> players,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$title (${players.length})',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              ?action,
            ],
          ),
        ),
        Expanded(
          child: players.isEmpty
              ? Center(
                  child: Text(
                    _query.isEmpty ? '선수가 없어요' : '검색 결과가 없어요',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView(
                  children: [
                    for (final p in players)
                      CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: c.inDeck(p.id),
                        onChanged: (_) => c.toggle(p.id),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            PositionBadge(p.mainPosition),
                            if (p.canKeep) const Text(' 🧤'),
                          ],
                        ),
                        secondary: _canSeeStats
                            ? Text(p.stats.ovr.toStringAsFixed(1))
                            : null,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _deckPanel(MatchSessionController c, List<Player> registered) {
    final theme = Theme.of(context);
    final session = c.session;
    final deck = session.deck(registered);
    final counts = {
      for (final pos in Position.values)
        pos: deck.where((p) => p.mainPosition == pos).length,
    };
    final summary = Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('출전 ${deck.length}명', style: theme.textTheme.titleMedium),
          Text(
            [for (final pos in Position.values) '${pos.label} ${counts[pos]}']
                .join(' · '),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
    final chips = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final p in deck)
            InputChip(
              visualDensity: VisualDensity.compact,
              label: Text(p.isGuest ? '${p.name} (게스트)' : p.name),
              onDeleted: () => p.isGuest ? c.removeGuest(p.id) : c.toggle(p.id),
            ),
        ],
      ),
    );
    final actions = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CoachTarget(
            id: 'deck.guest',
            child: OutlinedButton.icon(
              onPressed: () => _addGuest(c, registered),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('게스트'),
            ),
          ),
          const Spacer(),
          CoachTarget(
            id: 'deck.next',
            child: FilledButton(
              onPressed: deck.length < MatchSession.minTeams
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TeamSetupPage(group: widget.group, controller: c),
                      ),
                    ),
              child: const Text('다음 →'),
            ),
          ),
        ],
      ),
    );
    // 키보드(검색·게스트 입력)가 올라와 높이가 모자라면 칩 목록은 숨긴다.
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight < 200
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [summary, actions],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                Expanded(child: chips),
                actions,
              ],
            ),
    );
  }

  Future<void> _addGuest(
    MatchSessionController c,
    List<Player> registered,
  ) async {
    final result = await showDialog<({Player player, bool save})>(
      context: context,
      builder: (_) => const _GuestDialog(),
    );
    if (result == null) return;
    if (result.save) {
      // 일반멤버로 등록하고 덱에 올린다.
      await ref
          .read(playerRepositoryProvider)
          .savePlayer(widget.group.id, result.player);
      c.toggle(result.player.id);
    } else {
      c.addGuest(result.player);
    }
  }
}

/// 게스트 추가 (SPEC F2.3): 이름 + 종합 점수 + 주 포지션.
class _GuestDialog extends StatefulWidget {
  const _GuestDialog();

  @override
  State<_GuestDialog> createState() => _GuestDialogState();
}

class _GuestDialogState extends State<_GuestDialog> {
  final _name = TextEditingController();
  int _score = PlayerStats.defaultValue;
  Position _position = Position.ala;
  bool _save = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (
      player: Player(
        id: _save
            ? PlayerRepository.newId()
            : 'guest-${PlayerRepository.newId()}',
        name: name,
        stats: PlayerStats.uniform(_score),
        mainPosition: _position,
        isGuest: !_save,
        statsSimple: true,
      ),
      save: _save,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 가로 폰에서 키보드가 올라오면 남는 높이가 아주 적다:
    // 버튼은 제목 줄에 두고, 입력 항목은 두 줄로 압축하고, 나머지는 스크롤.
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('게스트 추가', style: theme.textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(onPressed: _submit, child: const Text('추가')),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('guestName'),
                            controller: _name,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: '이름',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SegmentedButton<Position>(
                          showSelectedIcon: false,
                          segments: [
                            for (final p in Position.values)
                              ButtonSegment(value: p, label: Text(p.label)),
                          ],
                          selected: {_position},
                          onSelectionChanged: (s) =>
                              setState(() => _position = s.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text('종합 점수'),
                        ScorePicker(
                          size: 30,
                          value: _score,
                          onChanged: (v) => setState(() => _score = v),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => setState(() => _save = !_save),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _save,
                                onChanged: (v) =>
                                    setState(() => _save = v ?? false),
                              ),
                              const Text('선수로 저장 (일반멤버)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
