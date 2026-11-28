import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/formation.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../match/deck_page.dart';
import '../onboarding/onboarding_page.dart';
import '../common/glass.dart';
import '../tutorial/coach_marks.dart';
import '../history/history_page.dart';
import '../invite/invite_actions.dart';

/// 모임 홈: 오늘 매치 형식 선택 (SPEC F0, §8.2-1).
class GroupHomeView extends ConsumerWidget {
  const GroupHomeView({super.key, required this.group});

  final GroupInfo group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playerCount = ref.watch(playersProvider(group.id)).value?.length;
    final last = ref.watch(historyProvider(group.id)).value?.firstOrNull;
    // 마지막 공유 이후 바뀐 항목 수 ("공유 안 된 변경 N건", SPEC F13.4).
    final unshared = ref.watch(unsharedChangesProvider(group.id)).value;
    const shadow = [Shadow(blurRadius: 8, color: Colors.black54)];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (playerCount != null)
            Text(
              '선수 $playerCount명 · ${group.role.label}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                shadows: shadow,
              ),
            ),
          if (!group.onboardingDone) ...[
            const SizedBox(height: 12),
            CoachTarget(
              id: 'home.onboarding',
              child: Glass(
                dark: true,
                child: ListTile(
                  textColor: Colors.white,
                  iconColor: Colors.white,
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
          Center(
            child: Text(
              "Today's Match",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                shadows: shadow,
              ),
            ),
          ),
          const SizedBox(height: 14),
          CoachTarget(
            id: 'home.format',
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 14,
              children: [
                // 풋살: 지금까지 만든 팀 짜기 흐름. 팀 인원(4~7)은 출전 덱 다음 단계에서 고른다.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GlassButton(
                    key: const Key('modeFutsal'),
                    big: true,
                    primary: true,
                    label: '풋살',
                    caption: '4 vs 4 ~ 7 vs 7',
                    onPressed: () => _startMatch(context, group.defaultFormat),
                  ),
                ),
                // 축구: 다음 업데이트에서 만든다.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GlassButton(
                    key: const Key('modeSoccer'),
                    big: true,
                    dimmed: true,
                    label: '축구',
                    caption: '준비 중',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('축구 모드는 준비 중이에요. 지금은 풋살로 팀을 짜 주세요.'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              if (last != null)
                GlassButton(
                  key: const Key('lastLineup'),
                  icon: Icons.history,
                  label:
                      '마지막 편성 ${last.confirmedAt.month}/${last.confirmedAt.day}',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryPage(group: group),
                    ),
                  ),
                ),
              CoachTarget(
                id: 'home.invite',
                child: GlassButton(
                  key: const Key('invite'),
                  icon: Icons.group_add,
                  label: '초대하기',
                  onPressed: () => sendInvite(context, ref, group),
                ),
              ),
              CoachTarget(
                id: 'home.shareChanges',
                child: Badge(
                  isLabelVisible: (unshared ?? 0) > 0,
                  label: Text('${unshared ?? 0}'),
                  child: GlassButton(
                    key: const Key('shareChanges'),
                    icon: Icons.upload,
                    label: (unshared ?? 0) > 0 ? '변경 공유 ($unshared건)' : '변경 공유',
                    onPressed: () => shareChanges(context, ref, group),
                  ),
                ),
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
