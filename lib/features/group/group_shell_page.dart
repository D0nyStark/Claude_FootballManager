import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../players/players_view.dart';
import '../settings/group_settings_view.dart';
import 'group_home_view.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';

/// 모임 안 화면: 왼쪽 내비게이션 레일 + 내용 (SPEC §8.1, 가로 모드).
class GroupShellPage extends ConsumerStatefulWidget {
  const GroupShellPage({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupShellPage> createState() => _GroupShellPageState();
}

class _GroupShellPageState extends ConsumerState<GroupShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId));
    return TutorialHost(
      screen: TutorialScreen.groupHome,
      ready: group.hasValue && group.value != null,
      steps: () => TutorialSteps.groupHome,
      child: Scaffold(
        body: SafeArea(
          child: group.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('불러오지 못했어요: $e')),
            data: (g) {
              if (g == null) {
                return const Center(child: Text('모임이 삭제됐어요.'));
              }
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    labelType: NavigationRailLabelType.all,
                    leading: Tooltip(
                      message: '모임 목록',
                      child: CoachTarget(
                        id: 'shell.groups',
                        child: IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: () =>
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                        ),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('홈'),
                      ),
                      NavigationRailDestination(
                        icon: CoachTarget(
                          id: 'shell.players',
                          child: Icon(Icons.groups_outlined),
                        ),
                        selectedIcon: Icon(Icons.groups),
                        label: Text('선수'),
                      ),
                      NavigationRailDestination(
                        icon: CoachTarget(
                          id: 'shell.settings',
                          child: Icon(Icons.settings_outlined),
                        ),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('설정'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: switch (_index) {
                      0 => GroupHomeView(group: g),
                      1 => PlayersView(group: g),
                      _ => GroupSettingsView(group: g),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
