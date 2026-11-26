import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/balancer/balancer.dart';
import '../../core/models/models.dart';
import '../../core/scoring/balance_score.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/common_widgets.dart';
import 'team_colors.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';

/// 편성 결과 (임시 화면). M4에서 구장 평면도 GUI로 바뀐다.
///
/// 상단 밸런스 점수(100점) + 편성안 1~3 + 팀별 자리·후보 목록.
class LineupResultPage extends ConsumerStatefulWidget {
  const LineupResultPage({
    super.key,
    required this.group,
    required this.request,
  });

  final GroupInfo group;
  final BalanceRequest request;

  @override
  ConsumerState<LineupResultPage> createState() => _LineupResultPageState();
}

class _LineupResultPageState extends ConsumerState<LineupResultPage> {
  BalanceResult? _result;
  int _index = 0;
  int _seed = 0;
  final List<Lineup> _shown = [];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() => _result = null);
    final r = widget.request;
    final request = BalanceRequest(
      players: r.players,
      format: r.format,
      teamCount: r.teamCount,
      keeperMode: r.keeperMode,
      fixedKeepers: r.fixedKeepers,
      constraints: r.constraints,
      history: r.history,
      avoidLineups: [..._shown],
      seed: _seed,
    );
    final result = await ref.read(balancerRunnerProvider)(request);
    if (!mounted) return;
    setState(() {
      _result = result;
      _index = 0;
      if (result is BalanceSuccess) {
        _shown.addAll(result.candidates.map((c) => c.lineup));
      }
    });
  }

  /// 다시 섞기: 이미 보여준 편성안과 다른 결과 (SPEC F4.5).
  void _shuffle() {
    _seed++;
    _run();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return TutorialHost(
      screen: TutorialScreen.result,
      ready: result is BalanceSuccess,
      steps: () => TutorialSteps.result,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('편성 결과'),
          actions: [
            if (result is BalanceSuccess && result.candidates.length > 1)
              CoachTarget(
                id: 'result.candidates',
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (var i = 0; i < result.candidates.length; i++)
                      ButtonSegment(value: i, label: Text('편성안 ${i + 1}')),
                  ],
                  selected: {_index},
                  onSelectionChanged: (s) => setState(() => _index = s.first),
                ),
              ),
            const SizedBox(width: 8),
            CoachTarget(
              id: 'result.shuffle',
              child: FilledButton.tonalIcon(
                onPressed: result == null ? null : _shuffle,
                icon: const Icon(Icons.shuffle),
                label: const Text('다시 섞기'),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: switch (result) {
          null => const Center(child: CircularProgressIndicator()),
          BalanceFailure() => const Center(
            child: Text('출전 인원과 팀 수를 다시 확인해 주세요.'),
          ),
          BalanceSuccess(:final candidates) => _candidate(
            candidates[_index.clamp(0, candidates.length - 1)],
          ),
        },
      ),
    );
  }

  Widget _candidate(LineupCandidate c) {
    final theme = Theme.of(context);
    final players = {for (final p in widget.request.players) p.id: p};
    final canSeeStats = widget.group.role.canSeeStats;
    final b = c.balance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CoachTarget(
          id: 'result.score',
          child: Container(
            color: theme.colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '⚖️ 밸런스 ${b.rounded} / 100',
                  key: const Key('balanceScore'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Text(b.grade.label, style: theme.textTheme.titleSmall),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '전력 ${b.strength.round()} · 공격 ${b.attack.round()} · '
                    '수비 ${b.defense.round()} · 포지션 ${b.position.round()}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var t = 0; t < c.lineup.teams.length; t++)
                  CoachTarget(
                    id: t == 0 ? 'result.team' : 'result.team$t',
                    child: _teamCard(
                      theme,
                      t,
                      c.lineup.teams[t],
                      b.teams[t],
                      players,
                      canSeeStats,
                      c.lineup.format,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _teamCard(
    ThemeData theme,
    int t,
    TeamLineup team,
    TeamSummary summary,
    Map<String, Player> players,
    bool canSeeStats,
    MatchFormat format,
  ) {
    String name(String id) => players[id]?.name ?? '?';
    return SizedBox(
      width: 190,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: teamColors[t], width: 2),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(teamNames[t], style: theme.textTheme.titleSmall),
              if (canSeeStats)
                Text(
                  'OVR ${summary.ovr.toStringAsFixed(1)} · '
                  '공 ${summary.attack.toStringAsFixed(1)} · '
                  '수 ${summary.defense.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall,
                ),
              const Divider(),
              for (final slot in format.slots)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: slot.isKeeper
                            ? const Text('GK')
                            : PositionBadge(slot.position!),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          team.slots[slot] == null
                              ? '+1 빌려오기'
                              : '${slot.isKeeper ? (team.fixedKeeperId != null ? '🧤 ' : '🔄 ') : ''}'
                                    '${name(team.slots[slot]!)}',
                          style: team.slots[slot] == null
                              ? theme.textTheme.bodySmall
                              : null,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (team.bench.isNotEmpty) ...[
                const Divider(),
                Text('후보', style: theme.textTheme.labelMedium),
                for (final id in team.bench) Text(name(id)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
