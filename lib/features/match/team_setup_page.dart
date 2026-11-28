import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/balancer/balancer.dart';
import '../../core/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/session/match_session.dart';
import '../common/common_widgets.dart';
import '../common/glass.dart';
import '../players/constraints_view.dart';
import '../pitch/pitch_page.dart';
import 'match_session_controller.dart';
import 'team_colors.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';
import '../../data/repositories/settings_repository.dart';

/// 팀 설정 (SPEC F3, §8.5): 형식 · 팀 수 [− n +] · 키퍼 모드 · 당일 제약.
class TeamSetupPage extends ConsumerWidget {
  const TeamSetupPage({
    super.key,
    required this.group,
    required this.controller,
  });

  final GroupInfo group;
  final MatchSessionController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final registered = ref.watch(playersProvider(group.id)).value ?? [];
        final groupConstraints =
            ref.watch(constraintsProvider(group.id)).value ?? [];
        // 반복 조합 회피: 최근 확정 편성 (SPEC §6.6), 모임 설정 (SPEC F10).
        final history = ref.watch(historyProvider(group.id)).value ?? [];
        final prefs =
            ref.watch(preferencesProvider(group.id)).value ??
            const GroupPreferences();
        final session = controller.session;
        final deck = session.deck(registered);
        return TutorialHost(
          screen: TutorialScreen.teamSetup,
          steps: () => TutorialSteps.teamSetup,
          child: Scaffold(
            appBar: AppBar(title: Text('팀 설정 · 출전 ${deck.length}명')),
            // 세로: 팀 옵션 위, 당일 조건 아래.
            body: GlassBody(
              child: Flex(
                direction: isNarrow(context) ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: _teamOptions(context, session, deck),
                  ),
                  isNarrow(context)
                      ? const Divider(height: 1)
                      : const VerticalDivider(width: 1),
                  Expanded(
                    flex: isNarrow(context) ? 2 : 3,
                    child: _constraints(
                      context,
                      session,
                      deck,
                      groupConstraints,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CoachTarget(
                      id: 'setup.make',
                      child: FilledButton.icon(
                        key: const Key('makeTeams'),
                        onPressed: deck.length < session.teamCount
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PitchPage(
                                    group: group,
                                    request: buildBalanceRequest(
                                      session: session,
                                      registered: registered,
                                      groupConstraints: groupConstraints,
                                      history: [
                                        for (final h in history)
                                          h.toHistoryEntry(),
                                      ],
                                      repeatAvoidance: prefs.repeatAvoidance,
                                      weights: prefs.weights,
                                    ),
                                  ),
                                ),
                              ),
                        icon: const Icon(Icons.bolt),
                        label: const Text('팀 짜기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _teamOptions(
    BuildContext context,
    MatchSession session,
    List<Player> deck,
  ) {
    final theme = Theme.of(context);
    final n = session.format.playersPerTeam;
    final sizes = distributeTeamSizes(deck.length, session.teamCount);
    final tooSmall = sizes.isNotEmpty && sizes.last < n - 1;
    final short = sizes.where((s) => s < n).length;
    final bench = sizes.fold(0, (sum, s) => sum + (s > n ? s - n : 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 팀 인원 4~7: 버튼 4개 대신 [−] 5 vs 5 [+] 한 줄 (팀 수와 같은 방식).
          CoachTarget(
            id: 'setup.format',
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text('인원', style: theme.textTheme.labelLarge),
                ),
                FormatStepper(
                  value: session.format,
                  onChanged: controller.setFormat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CoachTarget(
            id: 'setup.teamCount',
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text('팀 수', style: theme.textTheme.labelLarge),
                ),
                IconButton.outlined(
                  tooltip: '팀 줄이기',
                  onPressed: session.teamCount > MatchSession.minTeams
                      ? () => controller.setTeamCount(session.teamCount - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${session.teamCount}',
                    key: const Key('teamCount'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton.outlined(
                  tooltip: '팀 늘리기',
                  onPressed:
                      session.teamCount < MatchSession.maxTeams &&
                          deck.length > session.teamCount
                      ? () => controller.setTeamCount(session.teamCount + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${deck.length}명 → ${describeTeamSizes(deck.length, session.teamCount)}',
                  key: const Key('teamSizes'),
                  style: theme.textTheme.titleSmall,
                ),
                if (short > 0)
                  Text(
                    '인원이 부족한 팀 $short개는 평균 실력의 1명을 빌려 온 것으로 보정해요.',
                    style: theme.textTheme.bodySmall,
                  ),
                if (bench > 0)
                  Text('팀별 후보 총 $bench명', style: theme.textTheme.bodySmall),
                if (tooSmall)
                  Text(
                    '⚠ 팀당 인원이 ${session.format.label} 경기에 많이 부족해요.',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('골키퍼', style: theme.textTheme.labelLarge),
          CoachTarget(
            id: 'setup.keeper',
            child: RadioGroup<KeeperMode>(
              groupValue: session.keeperMode,
              onChanged: (m) => controller.setKeeperMode(m!),
              child: const Column(
                children: [
                  RadioListTile(
                    dense: true,
                    value: KeeperMode.rotation,
                    title: Text('로테이션 (돌아가며 키퍼)'),
                  ),
                  RadioListTile(
                    dense: true,
                    value: KeeperMode.fixed,
                    title: Text('키퍼 고정'),
                  ),
                ],
              ),
            ),
          ),
          if (session.keeperMode == KeeperMode.fixed)
            _keeperPickers(context, session, deck),
        ],
      ),
    );
  }

  Widget _keeperPickers(
    BuildContext context,
    MatchSession session,
    List<Player> deck,
  ) {
    final candidates = [...deck]
      ..sort((a, b) {
        if (a.canKeep != b.canKeep) return a.canKeep ? -1 : 1;
        return a.name.compareTo(b.name);
      });
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var t = 0; t < session.teamCount; t++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(width: 72, child: Text(teamNames[t])),
                  DropdownButton<String?>(
                    key: Key('keeper-$t'),
                    value: session.fixedKeepers[t],
                    hint: const Text('지정 안 함'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('지정 안 함'),
                      ),
                      for (final p in candidates)
                        DropdownMenuItem(
                          value: p.id,
                          child: Text(p.canKeep ? '🧤 ${p.name}' : p.name),
                        ),
                    ],
                    onChanged: (id) => controller.setKeeper(t, id),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: deck.any((p) => p.canKeep)
                ? () => controller.autoAssignKeepers(deck)
                : null,
            icon: const Icon(Icons.shuffle),
            label: const Text('자동 배정 (키퍼 가능 선수 중)'),
          ),
        ],
      ),
    );
  }

  Widget _constraints(
    BuildContext context,
    MatchSession session,
    List<Player> deck,
    List<TeamConstraint> groupConstraints,
  ) {
    final theme = Theme.of(context);
    final names = {for (final p in deck) p.id: p.name};
    final inDeck = names.keys.toSet();
    final applied = groupConstraints
        .where((c) => c.playerIds.where(inDeck.contains).length >= 2)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CoachTarget(
          id: 'setup.day',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text('오늘만 적용할 조건', style: theme.textTheme.labelLarge),
                ),
                TextButton.icon(
                  onPressed: deck.length < 2
                      ? null
                      : () async {
                          final result =
                              await showDialog<(ConstraintType, Set<String>)>(
                                context: context,
                                builder: (_) => ConstraintDialog(players: deck),
                              );
                          if (result != null) {
                            controller.addDayConstraint(result.$1, result.$2);
                          }
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('추가'),
                ),
              ],
            ),
          ),
        ),
        if (applied > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '모임의 상시 조건 $applied개도 함께 적용돼요.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: session.dayConstraints.isEmpty
              ? Center(
                  child: Text('없음 (선택 사항)', style: theme.textTheme.bodySmall),
                )
              : ListView(
                  children: [
                    for (final c in session.dayConstraints)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          c.type == ConstraintType.together
                              ? Icons.link
                              : Icons.link_off,
                        ),
                        title: Text(c.type.label),
                        subtitle: Text(
                          c.playerIds.map((id) => names[id] ?? '-').join(', '),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => controller.removeDayConstraint(c),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
