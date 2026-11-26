import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/formation.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../match/deck_page.dart';
import '../onboarding/onboarding_page.dart';
import '../tutorial/coach_marks.dart';
import '../history/history_page.dart';

/// 모임 홈: 오늘 매치 형식 선택 (SPEC F0, §8.2-1).
class GroupHomeView extends ConsumerWidget {
  const GroupHomeView({super.key, required this.group});

  final GroupInfo group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playerCount = ref.watch(playersProvider(group.id)).value?.length;
    final last = ref.watch(historyProvider(group.id)).value?.firstOrNull;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${group.icon} ${group.name}',
            style: theme.textTheme.headlineSmall,
          ),
          if (playerCount != null)
            Text('선수 $playerCount명 · ${group.role.label}'),
          if (!group.onboardingDone) ...[
            const SizedBox(height: 12),
            CoachTarget(
              id: 'home.onboarding',
              child: Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.checklist),
                  title: Text(
                    '설정 마무리하기 (${group.onboardingStep}/${GroupInfo.onboardingSteps})',
                  ),
                  subtitle: const Text('선수 명단과 간단 스펙을 이어서 입력해요.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnboardingPage(
                        groupId: group.id,
                        initialStep: group.onboardingStep,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Center(child: Text('오늘 매치는?', style: theme.textTheme.titleLarge)),
          const SizedBox(height: 12),
          CoachTarget(
            id: 'home.format',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final f in MatchFormat.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 200,
                      height: 96,
                      child: f == group.defaultFormat
                          ? FilledButton(
                              onPressed: () => _startMatch(context, f),
                              child: Text(
                                f.label,
                                style: const TextStyle(fontSize: 26),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: () => _startMatch(context, f),
                              child: Text(
                                f.label,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (last != null) ...[
                OutlinedButton.icon(
                  key: const Key('lastLineup'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryPage(group: group),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: Text(
                    '마지막 편성 ${last.confirmedAt.month}/${last.confirmedAt.day}',
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // 초대·변경 공유는 M6.5에서 구현.
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.group_add),
                label: const Text('초대하기'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.upload),
                label: const Text('변경 공유'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startMatch(BuildContext context, MatchFormat format) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeckPage(group: group, format: format),
        ),
      );
}
