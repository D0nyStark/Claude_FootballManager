import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/common_widgets.dart';
import '../group/group_shell_page.dart';
import '../invite/invite_actions.dart';
import 'roster_parser.dart';

/// 모임 생성 마법사 (SPEC F12). 모든 단계에서 건너뛰기·나중에 하기 가능.
///
/// ① 모임 정보 → ② 선수 명단 → ③ 간단 스펙 → ④ 초대
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.groupId, this.initialStep = 0});

  /// 이어서 하기: 이미 만든 모임. null이면 새 모임.
  final String? groupId;
  final int initialStep;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const stepTitles = ['모임 정보', '선수 명단', '간단 스펙', '초대'];

  late int _step = widget.initialStep.clamp(0, 3);
  String? _groupId;
  bool _busy = false;

  // ① 모임 정보
  final _name = TextEditingController();
  final _myName = TextEditingController();
  String _icon = groupIcons.first;
  int _color = groupColors.first;
  MatchFormat _format = MatchFormat.fiveVsFive;

  // ② 선수 명단
  final _paste = TextEditingController();
  final _single = TextEditingController();
  late final _singleFocus = FocusNode()..addListener(_onFocus);

  void _onFocus() {
    if (mounted) setState(() {});
  }

  final List<String> _pending = [];

  // ③ 간단 스펙: 선수 id → 수정값
  final Map<String, Player> _edits = {};

  @override
  void initState() {
    super.initState();
    _groupId = widget.groupId;
    if (_groupId != null) _loadGroup();
  }

  Future<void> _loadGroup() async {
    final g = await ref
        .read(groupRepositoryProvider)
        .watchGroup(_groupId!)
        .first;
    if (g == null || !mounted) return;
    setState(() {
      _name.text = g.name;
      _myName.text = g.myDisplayName ?? '';
      _icon = g.icon;
      _color = g.color;
      _format = g.defaultFormat;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _myName.dispose();
    _paste.dispose();
    _single.dispose();
    _singleFocus.dispose();
    super.dispose();
  }

  // ───────────────────────── 이동 ─────────────────────────

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// [save]가 true면 현재 단계 입력을 저장하고 다음으로.
  Future<void> _next({required bool save}) => _run(() async {
    if (save || _step == 0) await _saveStep();
    if (_step >= 3) {
      await _finish(GroupInfo.onboardingSteps);
      return;
    }
    final next = _step + 1;
    await ref.read(groupRepositoryProvider).setOnboardingStep(_groupId!, next);
    if (mounted) setState(() => _step = next);
  });

  /// 나중에 하기: 지금 단계를 기억해 두고 모임 홈으로.
  /// 나중에 하기: 지금 단계에서 입력한 내용(모임 정보·명단·간단 스펙)은 저장하고 모임 홈으로.
  Future<void> _later() => _run(() async {
    await _saveStep();
    await _finish(_step);
  });

  Future<void> _finish(int step) async {
    await ref.read(groupRepositoryProvider).setOnboardingStep(_groupId!, step);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GroupShellPage(groupId: _groupId!)),
    );
  }

  Future<void> _saveStep() async {
    final groups = ref.read(groupRepositoryProvider);
    final players = ref.read(playerRepositoryProvider);
    switch (_step) {
      case 0:
        final name = _name.text.trim().isEmpty ? '새 모임' : _name.text.trim();
        if (_groupId == null) {
          _groupId = await groups.createGroup(
            name: name,
            icon: _icon,
            color: _color,
            defaultFormat: _format,
            myDisplayName: _myName.text,
          );
        } else {
          await groups.updateGroup(
            _groupId!,
            name: name,
            icon: _icon,
            color: _color,
            defaultFormat: _format,
            myDisplayName: () => _myName.text,
          );
        }
      case 1:
        _addPasted();
        if (_pending.isNotEmpty) {
          await players.addPlayersByName(_groupId!, _pending);
          _pending.clear();
        }
      case 2:
        for (final p in _edits.values) {
          await players.savePlayer(_groupId!, p);
        }
        _edits.clear();
    }
  }

  void _addPasted() {
    final existing = [
      ...?ref.read(playersProvider(_groupId!)).value?.map((p) => p.name),
      ..._pending,
    ];
    final names = parseRoster(
      '${_paste.text}\n${_single.text}',
      existing: existing,
    );
    if (names.isEmpty) return;
    setState(() {
      _pending.addAll(names);
      _paste.clear();
      _single.clear();
    });
  }

  // ───────────────────────── 화면 ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 가로 화면에서 키보드가 올라오면 남는 높이가 아주 적다 → 버튼을 제목줄로 올리고 제목줄도 낮춘다.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final narrow = isNarrow(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: keyboard ? 44 : null,
        title: Text(_groupId == null ? '새 모임 만들기' : '모임 설정 마무리'),
        actions: narrow
            ? null
            : [..._actionButtons(), const SizedBox(width: 12)],
      ),
      // 세로: 버튼은 아래쪽 줄(키보드 위)에 둔다.
      bottomNavigationBar: narrow
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                child: Row(
                  children: [
                    ..._actionButtons().take(_step > 0 ? 2 : 1),
                    const Spacer(),
                    _actionButtons().last,
                  ],
                ),
              ),
            )
          : null,
      body: narrow
          ? _narrowBody(theme, keyboard)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 130,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      for (var i = 0; i < stepTitles.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: i <= _step
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                child: i < _step
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: theme.colorScheme.onPrimary,
                                      )
                                    : Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: i == _step
                                              ? theme.colorScheme.onPrimary
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stepTitles[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: i == _step
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    color: i == _step
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, keyboard ? 4 : 16, 24, 8),
                    child: switch (_step) {
                      0 => _infoStep(theme),
                      1 => _rosterStep(theme, keyboard: keyboard),
                      2 => _specStep(theme),
                      _ => _inviteStep(theme),
                    },
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _actionButtons() => [
    TextButton(onPressed: _busy ? null : _later, child: const Text('나중에 하기')),
    if (_step > 0)
      TextButton(
        onPressed: _busy ? null : () => _next(save: false),
        child: const Text('건너뛰기'),
      ),
    FilledButton(
      onPressed: _busy ? null : () => _next(save: true),
      child: Text(_step >= 3 ? '완료' : '다음 →'),
    ),
  ];

  /// 세로: 단계 표시를 위쪽 가로줄로.
  Widget _narrowBody(ThemeData theme, bool keyboard) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!keyboard)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              for (var i = 0; i < stepTitles.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Divider(
                      color: i <= _step
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: i <= _step
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      child: i < _step
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: i == _step
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stepTitles[i],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: i == _step ? theme.colorScheme.primary : null,
                        fontWeight: i == _step ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, keyboard ? 4 : 0, 16, 8),
          child: switch (_step) {
            0 => _infoStep(theme),
            1 => _rosterStep(theme, keyboard: keyboard),
            2 => _specStep(theme),
            _ => _inviteStep(theme),
          },
        ),
      ),
    ],
  );

  Widget _infoStep(ThemeData theme) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _name,
          autofocus: _groupId == null,
          decoration: const InputDecoration(
            labelText: '모임 이름',
            hintText: '예: 수요풋살',
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Text('아이콘', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            for (final icon in groupIcons)
              ChoiceChip(
                label: Text(icon, style: const TextStyle(fontSize: 18)),
                selected: _icon == icon,
                onSelected: (_) => setState(() => _icon = icon),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text('색', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          children: [
            for (final c in groupColors)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _color = c),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(c),
                  child: _color == c
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('풋살 기본 인원', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        FormatStepper(
          value: _format,
          onChanged: (f) => setState(() => _format = f),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _myName,
          decoration: const InputDecoration(
            labelText: '내 표시 이름 (선택)',
            hintText: '초대할 때 보낸 사람으로 표시돼요',
          ),
        ),
      ],
    ),
  );

  Widget _rosterStep(ThemeData theme, {required bool keyboard}) {
    final existing = ref.watch(playersProvider(_groupId!)).value ?? const [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              // 키보드가 올라오면 숨긴다. 목록(ListView)에서 항목을 빼면 아래 입력창이
              // 새로 만들어져 키보드가 닫히므로, 빼지 않고 Visibility로 가리기만 한다.
              Visibility(
                visible: !keyboard,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '단톡방 멤버 목록 등을 복사해 붙여넣으면 이름을 자동으로 나눠요.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              // 한 명씩 입력 중이면 붙여넣기 칸을 가려 입력창이 키보드 위에 보이게 한다.
              Visibility(
                visible: !(keyboard && _singleFocus.hasFocus),
                maintainState: true,
                child: TextField(
                  key: const Key('rosterPaste'),
                  controller: _paste,
                  minLines: keyboard ? 2 : 4,
                  maxLines: keyboard ? 3 : 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '김철수\n이영희, 박민수 …',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('rosterSingle'),
                      controller: _single,
                      focusNode: _singleFocus,
                      decoration: const InputDecoration(
                        hintText: '한 명씩 추가 (입력 후 완료)',
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.done,
                      // 키보드를 닫지 않고 바로 다음 이름을 입력할 수 있게.
                      onSubmitted: (_) {
                        _addPasted();
                        _singleFocus.requestFocus();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _addPasted,
                    child: const Text('이름 나누기'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: ListView(
            children: [
              Text(
                '추가할 선수 ${_pending.length}명'
                '${existing.isEmpty ? '' : ' · 등록된 선수 ${existing.length}명'}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final name in _pending)
                    InputChip(
                      label: Text(name),
                      onDeleted: () => setState(() => _pending.remove(name)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static final _compact = SegmentedButton.styleFrom(
    visualDensity: VisualDensity.compact,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _specStep(ThemeData theme) {
    final players = ref.watch(playersProvider(_groupId!)).value ?? const [];
    if (players.isEmpty) {
      return const Center(child: Text('등록된 선수가 없어요. 건너뛰고 나중에 추가할 수 있어요.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '선수별 구분·주 포지션·종합 점수만 정해요. 세부 능력치는 나중에 입력할 수 있어요.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: players.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = _edits[players[i].id] ?? players[i];
              void update(Player next) => setState(() => _edits[p.id] = next);
              // 좁은 화면에서는 옆으로 밀어 볼 수 있게 한다.
              final controls = <Widget>[
                SizedBox(
                  width: 72,
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
                SegmentedButton<MemberType>(
                  showSelectedIcon: false,
                  style: _compact,
                  segments: const [
                    ButtonSegment(value: MemberType.core, label: Text('주')),
                    ButtonSegment(value: MemberType.regular, label: Text('일반')),
                  ],
                  selected: {p.memberType},
                  onSelectionChanged: (s) =>
                      update(p.copyWith(memberType: s.first)),
                ),
                const SizedBox(width: 8),
                SegmentedButton<Position>(
                  showSelectedIcon: false,
                  style: _compact,
                  segments: [
                    for (final pos in Position.values)
                      ButtonSegment(value: pos, label: Text(pos.label)),
                  ],
                  selected: {p.mainPosition},
                  onSelectionChanged: (s) =>
                      update(p.copyWith(mainPosition: s.first)),
                ),
                const SizedBox(width: 8),
                ScorePicker(
                  size: 30,
                  value: p.stats.ovr.round(),
                  onChanged: (v) => update(
                    p.copyWith(
                      stats: PlayerStats.uniform(v),
                      statsSimple: true,
                    ),
                  ),
                ),
              ];
              if (isNarrow(context)) {
                // 세로: 이름 한 줄 + 조작은 줄바꿈 배치.
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: controls,
                  ),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: controls),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _inviteStep(ThemeData theme) {
    final group = _groupId == null
        ? null
        : ref.watch(groupProvider(_groupId!)).value;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('멤버 초대', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              '카카오톡·메시지로 초대 링크를 보내면 받은 사람의 폰에 같은 모임이 생겨요.\n'
              '나중에 모임 설정에서도 보낼 수 있어요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              key: const Key('onboardingInvite'),
              onPressed: group == null
                  ? null
                  : () => sendInvite(context, ref, group),
              icon: const Icon(Icons.send),
              label: const Text('초대 링크 보내기'),
            ),
          ],
        ),
      ),
    );
  }
}
