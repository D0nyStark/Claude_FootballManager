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
  );

  List<LineupCandidate> _candidates = const [];
  int _index = 0;
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

  Lineup? get _lineup =>
      _candidates.isEmpty ? null : _candidates[_index].lineup;

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
      ),
    );
    if (!mounted) return;
    switch (result) {
      case BalanceSuccess(:final candidates):
        _shown.addAll(candidates.map((c) => c.lineup));
        await _showCandidates(candidates, 0);
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
    await _showCandidates(_candidates, index);
    if (mounted) setState(() => _busy = false);
  }

  /// 지금 자리에서 새 자리로 선수들이 날아가는 애니메이션 후 반영.
  Future<void> _showCandidates(List<LineupCandidate> list, int index) async {
    final next = list[index].lineup;
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
            _Flight(_players[id]!, starts[id]!, to, teamColors[t], order++),
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
            teamColors[t],
            order++,
          ),
        );
      }
    }

    _previousScore = _candidates.isEmpty
        ? null
        : _evaluator.evaluate(_lineup!).total;
    final seconds = _flightTime + _stagger * math.max(0, flights.length - 1);
    setState(() => _flights = flights);
    _fly.duration = Duration(milliseconds: (seconds * 1000).round());
    await _fly.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted) return;
    setState(() {
      _candidates = list;
      _index = index;
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
                              children: [for (final f in _flights) _flight(f)],
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
    );
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
                                  color: teamColors[teamOf[p.id]!],
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
      width: 76,
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
          const SizedBox(height: 8),
          // 확정·공유는 M6에서 구현.
          const _RailButton(
            icon: Icons.check_circle_outline,
            label: '확정',
            filled: false,
            onPressed: null,
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
    final color = teamColors[t];
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
            SizedBox(
              height: summaryH,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: teamNames[t],
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
                child: _bench(team, color),
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
    return Positioned(
      left: left,
      top: top,
      child: KeyedSubtree(
        key: _slotKey(t, slot),
        child: PositionCircle(
          slot: slot,
          size: c,
          teamColor: teamColors[t],
          player: player,
          showOvr: _canSeeStats,
          offPosition: id != null && _evaluator.isOffPosition(id, slot),
          keeperMark: slot.isKeeper && id != null
              ? (team!.fixedKeeperId != null ? '🧤' : '🔄')
              : null,
          borrowed: team != null && id == null,
        ),
      ),
    );
  }

  Widget _bench(TeamLineup? team, Color color) {
    final theme = Theme.of(context);
    final bench = team?.bench ?? const [];
    return Row(
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
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(color: color, width: 1.5),
                      label: Text(_players[id]!.name),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
