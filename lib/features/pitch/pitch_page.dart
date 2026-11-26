import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/balancer/balancer.dart';
import '../../core/models/models.dart';
import '../../core/scoring/scoring.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../match/team_colors.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';
import 'balance_header.dart';
import 'half_court.dart';

import 'package:flutter/services.dart';

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../data/history/confirmed_lineup.dart';
import '../../data/repositories/player_repository.dart';
import '../share/share_service.dart';
import '../share/share_sheet.dart';
import '../share/share_text.dart';

/// 구장 화면 (SPEC F4·F5·F7, §8.4): 반쪽 구장을 나란히 놓고 포지션 원에 선수를 배치한다.
///
/// [⚡ 자동 편성]을 누르면 왼쪽 출전 덱의 선수들이 포지션 원으로 날아 들어간다.
class PitchPage extends ConsumerStatefulWidget {
  const PitchPage({super.key, required this.group, required this.request});

  final GroupInfo group;

  /// 출전 덱·팀 수·키퍼·제약이 담긴 편성 요청 (시드·avoid는 이 화면에서 바꾼다).
  final BalanceRequest request;

  @override
  ConsumerState<PitchPage> createState() => _PitchPageState();
}

class _Flight {
  _Flight(this.player, this.from, this.to, this.color, this.order);

  final Player player;
  final Offset from;
  final Offset to;
  final Color color;
  final int order;
}

class _PitchPageState extends ConsumerState<PitchPage>
    with SingleTickerProviderStateMixin {
  late final Map<String, Player> _players = {
    for (final p in widget.request.players) p.id: p,
  };
  late final LineupEvaluator _evaluator = LineupEvaluator(
    widget.request.players,
    balanceWeights: widget.request.balanceWeights ?? BalanceWeights.standard,
  );

  /// 구장 이미지 공유용 캡처 영역 (점수 헤더 + 구장).
  final _captureKey = GlobalKey();

  /// 이번 화면에서 확정한 이력 id (다시 확정하면 같은 항목을 고친다).
  String? _confirmedId;

  List<LineupCandidate> _candidates = const [];
  int _index = 0;

  /// 화면에 보이는 편성 (자동 편성 결과 + 수동 수정). 배치 전에는 null.
  Lineup? _current;
  final List<Lineup> _undo = [];
  final List<Lineup> _redo = [];

  /// 📌 고정: 선수 id. [다시 섞기]·[자동 편성]을 해도 지금 팀·자리에 남는다.
  final Set<String> _pins = {};

  /// 팀 이름·조끼 색 (SPEC F6.5).
  final List<String> _names = [...teamNames];
  final List<Color> _colors = [...teamColors];
  int _seed = 0;
  final List<Lineup> _shown = [];
  bool _busy = false;
  bool _deckOpen = true;
  double? _previousScore;

  final _stackKey = GlobalKey();
  final Map<String, GlobalKey> _deckKeys = {};
  final Map<(int, Slot), GlobalKey> _slotKeys = {};
  final Map<int, GlobalKey> _benchKeys = {};

  late final AnimationController _fly = AnimationController(vsync: this);
  List<_Flight> _flights = const [];
  double _circleSize = 52;

  static const _flightTime = 0.35; // 초
  static const _stagger = 0.045;

  Lineup? get _lineup => _current;

  bool get _flying => _flights.isNotEmpty;

  bool get _canSeeStats => widget.group.role.canSeeStats;

  int get _teamCount => widget.request.teamCount;

  MatchFormat get _format => widget.request.format;

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  GlobalKey _slotKey(int team, Slot slot) =>
      _slotKeys.putIfAbsent((team, slot), GlobalKey.new);

  // ───────────────────────── 편성 실행 ─────────────────────────

  Future<void> _run({required bool fresh}) async {
    if (_busy) return;
    setState(() => _busy = true);
    if (fresh) {
      _seed = 0;
      _shown.clear();
    } else {
      _seed++;
    }
    final r = widget.request;
    final pinned = _pinned();
    final result = await ref.read(balancerRunnerProvider)(
      BalanceRequest(
        players: r.players,
        format: r.format,
        teamCount: r.teamCount,
        keeperMode: r.keeperMode,
        fixedKeepers: r.fixedKeepers,
        constraints: r.constraints,
        history: r.history,
        repeatAvoidance: r.repeatAvoidance,
        avoidLineups: [..._shown],
        seed: _seed,
        balanceWeights: r.balanceWeights,
        pinnedTeams: pinned.teams,
        pinnedSlots: pinned.slots,
      ),
    );
    if (!mounted) return;
    switch (result) {
      case BalanceSuccess(:final candidates):
        _shown.addAll(candidates.map((c) => c.lineup));
        _candidates = candidates;
        _index = 0;
        await _animateTo(candidates.first.lineup);
      case BalanceFailure():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출전 인원과 팀 수를 다시 확인해 주세요.')),
        );
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _select(int index) async {
    if (_busy || index == _index) return;
    setState(() => _busy = true);
    _index = index;
    await _animateTo(_candidates[index].lineup);
    if (mounted) setState(() => _busy = false);
  }

  /// 📌 고정된 선수의 지금 팀·자리 → 편성 엔진의 Pin.
  ({Map<String, int> teams, Map<String, Slot> slots}) _pinned() {
    final teams = <String, int>{};
    final slots = <String, Slot>{};
    final current = _current;
    if (current != null) {
      for (final id in _pins) {
        if (spotOf(current, id) case SlotSpot(:final team, :final slot)) {
          teams[id] = team;
          slots[id] = slot;
        }
      }
    }
    return (teams: teams, slots: slots);
  }

  // ───────────────────────── 수동 수정 (SPEC F6) ─────────────────────────

  double? _score(Lineup? l) => l == null ? null : _evaluator.evaluate(l).total;

  /// 끌어 놓기: 맞교환·이동. 바로 반영하고 되돌리기 목록에 쌓는다.
  void _move(Spot from, Spot to) {
    final current = _current;
    if (current == null) return;
    final next = moveInLineup(current, from, to);
    if (identical(next, current)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previousScore = _score(current);
      _undo.add(current);
      _redo.clear();
      _current = next;
    });
  }

  void _undoEdit() {
    if (_undo.isEmpty || _busy) return;
    setState(() {
      _previousScore = _score(_current);
      _redo.add(_current!);
      _current = _undo.removeLast();
    });
  }

  void _redoEdit() {
    if (_redo.isEmpty || _busy) return;
    setState(() {
      _previousScore = _score(_current);
      _undo.add(_current!);
      _current = _redo.removeLast();
    });
  }

  /// 자동 편성 결과로 초기화 (되돌리기 가능).
  void _resetEdits() {
    if (_candidates.isEmpty || _busy) return;
    final original = _candidates[_index].lineup;
    if (identical(original, _current)) return;
    setState(() {
      _previousScore = _score(_current);
      _undo.add(_current!);
      _redo.clear();
      _current = original;
    });
  }

  void _togglePin(String id) {
    HapticFeedback.mediumImpact();
    setState(() => _pins.contains(id) ? _pins.remove(id) : _pins.add(id));
  }

  Future<void> _editTeam(int t) async {
    final result = await showDialog<(String, Color)>(
      context: context,
      builder: (_) => _TeamStyleDialog(name: _names[t], color: _colors[t]),
    );
    if (result == null) return;
    setState(() {
      _names[t] = result.$1;
      _colors[t] = result.$2;
    });
  }

  /// 지금 자리에서 새 자리로 선수들이 날아가는 애니메이션 후 반영.
  /// 자동 편성·다시 섞기·편성안 바꾸기도 되돌리기로 돌아갈 수 있다.
  Future<void> _animateTo(Lineup next) async {
    final starts = <String, Offset>{};
    final current = _lineup;
    for (final id in _players.keys) {
      starts[id] = _currentCenter(current, id) ?? Offset.zero;
    }
    final flights = <_Flight>[];
    var order = 0;
    for (var t = 0; t < next.teams.length; t++) {
      final team = next.teams[t];
      for (final slot in _format.slots) {
        final id = team.slots[slot];
        if (id == null) continue;
        final to = _center(_slotKey(t, slot));
        if (to != null) {
          flights.add(
            _Flight(_players[id]!, starts[id]!, to, _colors[t], order++),
          );
        }
      }
      final bench = _center(_benchKeys[t]);
      for (final (i, id) in team.bench.indexed) {
        if (bench == null) continue;
        flights.add(
          _Flight(
            _players[id]!,
            starts[id]!,
            bench + Offset((i - (team.bench.length - 1) / 2) * 64, 0),
            _colors[t],
            order++,
          ),
        );
      }
    }

    final before = _current;
    _previousScore = _score(before);
    final seconds = _flightTime + _stagger * math.max(0, flights.length - 1);
    setState(() => _flights = flights);
    _fly.duration = Duration(milliseconds: (seconds * 1000).round());
    await _fly.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted) return;
    setState(() {
      if (before != null) {
        _undo.add(before);
        _redo.clear();
      }
      _current = next;
      _flights = const [];
      _deckOpen = false;
    });
  }

  Offset? _currentCenter(Lineup? lineup, String id) {
    if (lineup != null) {
      for (var t = 0; t < lineup.teams.length; t++) {
        final team = lineup.teams[t];
        for (final e in team.slots.entries) {
          if (e.value == id) return _center(_slotKey(t, e.key));
        }
        if (team.bench.contains(id)) return _center(_benchKeys[t]);
      }
    }
    return _center(_deckKeys[id]) ?? const Offset(70, 120);
  }

  Offset? _center(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero), ancestor: stack);
  }

  // ───────────────────────── 화면 ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final lineup = _flying ? null : _lineup;
    final balance = lineup == null ? null : _evaluator.evaluate(lineup);
    return TutorialHost(
      screen: TutorialScreen.pitch,
      steps: () => TutorialSteps.pitch,
      child: Scaffold(
        body: SafeArea(
          child: RepaintBoundary(
            key: _captureKey,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CoachTarget(
                    id: 'pitch.score',
                    child: BalanceHeader(
                      balance: balance,
                      previous: _previousScore,
                      candidateCount: _candidates.length,
                      selected: _index,
                      onSelect: _busy ? null : _select,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      key: _stackKey,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CoachTarget(
                              id: 'pitch.deck',
                              child: _deckPanel(lineup),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(child: _courts(lineup, balance)),
                            const VerticalDivider(width: 1),
                            _rail(),
                          ],
                        ),
                        if (_flying)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _fly,
                                builder: (context, _) => Stack(
                                  children: [
                                    for (final f in _flights) _flight(f),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 확정·공유 (SPEC F8) ─────────────────────────

  Future<void> _confirm() async {
    final lineup = _current;
    if (lineup == null || _busy) return;
    final entry = ConfirmedLineup(
      id: _confirmedId ??= PlayerRepository.newId(),
      confirmedAt: DateTime.now(),
      balanceScore: _evaluator.evaluate(lineup).total,
      lineup: lineup,
      teamNames: _names.take(_teamCount).toList(),
      teamColors: [for (final c in _colors.take(_teamCount)) c.toARGB32()],
      playerNames: {for (final p in _players.values) p.id: p.name},
    );
    await ref.read(historyRepositoryProvider).save(widget.group.id, entry);
    // 오늘 준비는 끝났으니 작성 중인 덱 임시 저장을 비운다.
    await ref.read(sessionRepositoryProvider).clear(widget.group.id);
    if (!mounted) return;
    setState(() {}); // [확정] → [다시 공유]
    await showShareSheet(
      context,
      service: ref.read(shareServiceProvider),
      title: '확정했어요 · 단톡방에 공유하세요',
      canIncludeStats: _canSeeStats,
      text: (withStats) => _shareText(lineup, withStats),
      image: () => _captureImage(),
    );
  }

  String _shareText(Lineup lineup, bool withStats) {
    final b = _evaluator.evaluate(lineup);
    return buildShareText(
      lineup: lineup,
      teamNames: _names,
      nameOf: (id) => _players[id]?.name ?? '?',
      date: DateTime.now(),
      balanceScore: b.rounded,
      groupName: widget.group.name,
      teamOvr: withStats ? [for (final t in b.teams) t.ovr] : null,
    );
  }

  Future<Uint8List?> _captureImage() async {
    final boundary =
        _captureKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Widget _flight(_Flight f) {
    final total = _fly.duration!.inMilliseconds / 1000;
    final start = _stagger * f.order;
    final t = ((_fly.value * total - start) / _flightTime).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(t);
    final pos = Offset.lerp(f.from, f.to, eased)!;
    // 날아가는 동안 살짝 위로 솟았다가 내려앉는다.
    final lift = math.sin(eased * math.pi) * 18;
    final size = _circleSize * (0.75 + 0.25 * eased);
    return Positioned(
      left: pos.dx - size / 2,
      top: pos.dy - size / 2 - lift,
      child: Opacity(
        opacity: t == 0 ? 0 : 1,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: f.color, width: size * 0.08),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 6),
            ],
          ),
          child: Text(
            PositionCircle.shortName(f.player.displayName),
            maxLines: 1,
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// 왼쪽 출전 덱 패널 (140dp, 배치 후 접힘).
  Widget _deckPanel(Lineup? lineup) {
    final theme = Theme.of(context);
    final players = widget.request.players;
    if (!_deckOpen) {
      return SizedBox(
        width: 40,
        child: InkWell(
          onTap: () => setState(() => _deckOpen = true),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chevron_right),
              RotatedBox(
                quarterTurns: 1,
                child: Text('출전 덱 ${players.length}명'),
              ),
            ],
          ),
        ),
      );
    }
    final teamOf = <String, int>{
      if (lineup != null)
        for (var t = 0; t < lineup.teams.length; t++)
          for (final id in lineup.teams[t].playerIds) id: t,
    };
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 2, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '출전 덱 ${players.length}명',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                if (lineup != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: '접기',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _deckOpen = false),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final p in players)
                    Opacity(
                      opacity: _flying ? 0 : 1,
                      child: Container(
                        key: _deckKeys.putIfAbsent(p.id, GlobalKey.new),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: teamOf[p.id] == null
                              ? null
                              : Border.all(
                                  color: _colors[teamOf[p.id]!],
                                  width: 2,
                                ),
                        ),
                        child: Text(
                          p.isGuest ? '${p.name}*' : p.name,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 오른쪽 버튼 줄 (72dp).
  Widget _rail() {
    final arranged = _lineup != null;
    return SizedBox(
      width: 84,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CoachTarget(
            id: 'pitch.auto',
            child: _RailButton(
              key: const Key('autoArrange'),
              icon: Icons.bolt,
              label: '자동 편성',
              filled: !arranged,
              onPressed: _busy ? null : () => _run(fresh: true),
            ),
          ),
          const SizedBox(height: 8),
          CoachTarget(
            id: 'pitch.shuffle',
            child: _RailButton(
              key: const Key('shuffle'),
              icon: Icons.shuffle,
              label: '다시 섞기',
              filled: false,
              onPressed: _busy || !arranged ? null : () => _run(fresh: false),
            ),
          ),
          const SizedBox(height: 4),
          CoachTarget(
            id: 'pitch.undo',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      key: const Key('undo'),
                      tooltip: '되돌리기',
                      visualDensity: VisualDensity.compact,
                      onPressed: _undo.isEmpty || _busy ? null : _undoEdit,
                      icon: const Icon(Icons.undo),
                    ),
                    IconButton(
                      key: const Key('redo'),
                      tooltip: '다시하기',
                      visualDensity: VisualDensity.compact,
                      onPressed: _redo.isEmpty || _busy ? null : _redoEdit,
                      icon: const Icon(Icons.redo),
                    ),
                  ],
                ),
                TextButton(
                  key: const Key('resetEdits'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 28),
                  ),
                  onPressed:
                      arranged &&
                          !_busy &&
                          !identical(_current, _candidates[_index].lineup)
                      ? _resetEdits
                      : null,
                  child: const Text('초기화', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          CoachTarget(
            id: 'pitch.confirm',
            child: _RailButton(
              key: const Key('confirm'),
              icon: Icons.check_circle,
              label: _confirmedId == null ? '확정' : '다시 공유',
              filled: arranged,
              onPressed: arranged && !_busy ? _confirm : null,
            ),
          ),
        ],
      ),
    );
  }

  /// 팀별 반쪽 구장 카드를 가로로 나란히 (2팀도 동일 — SPEC §8.4).
  Widget _courts(Lineup? lineup, BalanceBreakdown? balance) {
    final sizes = distributeTeamSizes(
      widget.request.players.length,
      _teamCount,
    );
    final hasBench = sizes.first > _format.playersPerTeam;
    return LayoutBuilder(
      builder: (context, constraints) {
        const summaryH = 24.0, benchH = 40.0, pad = 6.0;
        final maxByHeight =
            constraints.maxHeight -
            summaryH -
            (hasBench ? benchH : 0) -
            3 * pad;
        final maxByWidth = constraints.maxWidth / _teamCount - 2 * pad;
        // 원이 48dp보다 작아질 만큼 좁으면 가로 스크롤 (SPEC §8.4).
        final court = math.max(150.0, math.min(maxByHeight, maxByWidth));
        _circleSize = (court * 0.2).clamp(44.0, 56.0);
        final row = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var t = 0; t < _teamCount; t++)
              CoachTarget(
                id: t == 0 ? 'pitch.court' : 'pitch.court$t',
                child: _teamCard(
                  t,
                  lineup?.teams[t],
                  balance?.teams[t],
                  court,
                  hasBench,
                  summaryH,
                  benchH,
                  pad,
                ),
              ),
          ],
        );
        final needed = (court + 2 * pad) * _teamCount;
        return needed > constraints.maxWidth
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: row,
              )
            : row;
      },
    );
  }

  Widget _teamCard(
    int t,
    TeamLineup? team,
    TeamSummary? summary,
    double court,
    bool hasBench,
    double summaryH,
    double benchH,
    double pad,
  ) {
    final theme = Theme.of(context);
    final color = _colors[t];
    final c = _circleSize;
    String? stats;
    if (summary != null && _canSeeStats) {
      stats =
          'OVR ${summary.ovr.toStringAsFixed(1)} · 공 ${summary.attack.toStringAsFixed(1)}'
          ' · 수 ${summary.defense.toStringAsFixed(1)}';
    }
    return Padding(
      padding: EdgeInsets.all(pad),
      child: SizedBox(
        width: court,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _editTeam(t),
              child: SizedBox(
                height: summaryH,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _names[t],
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (stats != null)
                          TextSpan(
                            text: '  $stats',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox.square(
              dimension: court,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: HalfCourtPainter(tint: color)),
                  ),
                  for (final slot in _format.slots)
                    _positioned(t, slot, team, court, c),
                ],
              ),
            ),
            if (hasBench)
              SizedBox(
                key: _benchKeys.putIfAbsent(t, GlobalKey.new),
                height: benchH,
                child: _bench(t, team, color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _positioned(
    int t,
    Slot slot,
    TeamLineup? team,
    double court,
    double c,
  ) {
    final xy = _format.coordinateOf(slot);
    // 원이 구장 밖으로 나가지 않게 안쪽으로 맞춘다.
    final left = xy.x * (court - c);
    final top = xy.y * (court - c);
    final id = team?.slots[slot];
    final player = id == null ? null : _players[id];
    final spot = SlotSpot(t, slot);
    Widget circle({bool highlight = false, bool ghost = false}) =>
        PositionCircle(
          slot: slot,
          size: c,
          teamColor: _colors[t],
          player: ghost ? null : player,
          showOvr: _canSeeStats,
          offPosition:
              !ghost && id != null && _evaluator.isOffPosition(id, slot),
          keeperMark: !ghost && slot.isKeeper && id != null
              ? (team!.fixedKeeperId != null ? '🧤' : '🔄')
              : null,
          borrowed: team != null && (id == null || ghost),
          pinned: !ghost && id != null && _pins.contains(id),
          highlight: highlight,
        );
    return Positioned(
      left: left,
      top: top,
      child: KeyedSubtree(
        key: _slotKey(t, slot),
        child: team == null
            ? circle()
            : DragTarget<_DragData>(
                onWillAcceptWithDetails: (d) => d.data.from != spot,
                onAcceptWithDetails: (d) => _move(d.data.from, spot),
                builder: (context, candidates, _) {
                  final over = candidates.isNotEmpty;
                  if (id == null) return circle(highlight: over);
                  return GestureDetector(
                    onLongPress: () => _togglePin(id),
                    child: Draggable<_DragData>(
                      data: _DragData(id, spot),
                      feedback: _dragFeedback(id, t),
                      childWhenDragging: circle(ghost: true),
                      child: circle(highlight: over),
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// 끄는 동안 손가락을 따라다니는 원.
  Widget _dragFeedback(String id, int t) => Material(
    type: MaterialType.transparency,
    child: Transform.scale(
      scale: 1.15,
      child: PositionCircle(
        slot: Slot.pivo,
        size: _circleSize,
        teamColor: _colors[t],
        player: _players[id],
        showOvr: _canSeeStats,
      ),
    ),
  );

  /// 후보 영역: 원을 여기로 끌면 후보로 내리고, 후보 칩을 원으로 끌면 맞교환 (SPEC F7.3).
  Widget _bench(int t, TeamLineup? team, Color color) {
    final theme = Theme.of(context);
    final bench = team?.bench ?? const [];
    Widget chip(String id, {bool highlight = false}) => Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: highlight ? color.withValues(alpha: 0.25) : null,
      side: BorderSide(color: color, width: 1.5),
      label: Text(_players[id]!.name),
    );
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (d) =>
          team != null && d.data.from != BenchSpot(t, d.data.id),
      onAcceptWithDetails: (d) => _move(d.data.from, BenchSpot(t)),
      builder: (context, areaCandidates, _) => Container(
        decoration: BoxDecoration(
          color: areaCandidates.isNotEmpty
              ? color.withValues(alpha: 0.12)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('후보', style: theme.textTheme.labelSmall),
            const SizedBox(width: 6),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final id in bench)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: DragTarget<_DragData>(
                          onWillAcceptWithDetails: (d) => d.data.id != id,
                          onAcceptWithDetails: (d) =>
                              _move(d.data.from, BenchSpot(t, id)),
                          builder: (context, candidates, _) =>
                              Draggable<_DragData>(
                                data: _DragData(id, BenchSpot(t, id)),
                                feedback: _dragFeedback(id, t),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: chip(id),
                                ),
                                child: chip(
                                  id,
                                  highlight: candidates.isNotEmpty,
                                ),
                              ),
                        ),
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

class _RailButton extends StatelessWidget {
  const _RailButton({
    super.key,
    required this.icon,
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        filled
            ? IconButton.filled(
                iconSize: 28,
                onPressed: onPressed,
                icon: Icon(icon),
                tooltip: label,
              )
            : IconButton.filledTonal(
                iconSize: 24,
                onPressed: onPressed,
                icon: Icon(icon),
                tooltip: label,
              ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _DragData {
  const _DragData(this.id, this.from);

  final String id;
  final Spot from;
}

/// 팀 이름·조끼 색 바꾸기 (SPEC F6.5).
class _TeamStyleDialog extends StatefulWidget {
  const _TeamStyleDialog({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  State<_TeamStyleDialog> createState() => _TeamStyleDialogState();
}

class _TeamStyleDialogState extends State<_TeamStyleDialog> {
  late final _name = TextEditingController(text: widget.name);
  late Color _color = widget.color;

  static const palette = [
    ...teamColors,
    Color(0xFF7B4CC2),
    Color(0xFFF08C00),
    Color(0xFF00897B),
    Color(0xFF455A64),
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('팀 이름·조끼 색'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('teamName'),
          controller: _name,
          decoration: const InputDecoration(labelText: '팀 이름'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final c in palette)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _color = c),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: c,
                  child: _color == c
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, (
          _name.text.trim().isEmpty ? widget.name : _name.text.trim(),
          _color,
        )),
        child: const Text('저장'),
      ),
    ],
  );
}
