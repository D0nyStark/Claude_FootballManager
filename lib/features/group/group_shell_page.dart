import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/glass.dart';
import '../players/players_view.dart';
import '../settings/group_settings_view.dart';
import 'group_home_view.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';

/// 모임 안 화면 = 모임 홈. 왼쪽 메뉴 없이 위쪽 바로 이동한다.
/// - 왼쪽 위 아이콘: 홈(앱 첫 화면 = 모임 목록, 모임 바꾸기·새 모임 만들기)
/// - 오른쪽 위 아이콘: 선수, 설정 (각각 전체 화면으로 열리고 ← 로 돌아옴)
class GroupShellPage extends ConsumerWidget {
  const GroupShellPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final g = group.value;
    return TutorialHost(
      screen: TutorialScreen.groupHome,
      ready: g != null,
      steps: () => TutorialSteps.groupHome,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            shadows: const [Shadow(blurRadius: 8, color: Colors.black45)],
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CoachTarget(
              id: 'shell.groups',
              child: IconButton(
                key: const Key('toGroupList'),
                tooltip: '홈',
                icon: const Icon(Icons.home),
                style: _glassIcon,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          ),
          title: g == null ? null : Text('${g.icon} ${g.name}'),
          actions: [
            CoachTarget(
              id: 'shell.players',
              child: IconButton(
                key: const Key('toPlayers'),
                tooltip: '선수',
                icon: const Icon(Icons.groups),
                style: _glassIcon,
                onPressed: g == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _GroupSubPage(
                            groupId: groupId,
                            title: '선수 관리',
                            builder: (g) => PlayersView(group: g),
                          ),
                        ),
                      ),
              ),
            ),
            CoachTarget(
              id: 'shell.settings',
              child: IconButton(
                key: const Key('toSettings'),
                tooltip: '설정',
                icon: const Icon(Icons.settings),
                style: _glassIcon,
                onPressed: g == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _GroupSubPage(
                            groupId: groupId,
                            title: 'Settings',
                            builder: (g) => GroupSettingsView(group: g),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 홈 배경 사진 (assets/home_bg.jpg — 나중에 바꿀 수 있음) + 글자가 읽히도록 어두운 막
            Image.asset('assets/home_bg.jpg', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99102014),
                    Color(0x55102014),
                    Color(0x88102014),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.zero,
                child: group.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('불러오지 못했어요: $e')),
                  data: (g) => g == null
                      ? const Center(child: Text('모임이 삭제됐어요.'))
                      : GroupHomeView(group: g),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final ButtonStyle _glassIcon = IconButton.styleFrom(
  fixedSize: const Size(44, 44),
  foregroundColor: Colors.white,
  backgroundColor: Colors.white.withValues(alpha: 0.18),
  side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
);

/// 선수·설정처럼 모임 홈에서 열리는 전체 화면. 모임이 지워지면 홈으로 돌아간다.
class _GroupSubPage extends ConsumerWidget {
  const _GroupSubPage({
    required this.groupId,
    required this.title,
    required this.builder,
  });

  final String groupId;
  final String title;
  final Widget Function(GroupInfo group) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    // 가로 화면에서 키보드가 올라오면 남는 높이가 적다 → 상단 바를 낮추고 여백을 없앤다.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      appBar: AppBar(title: Text(title), toolbarHeight: keyboard ? 44 : null),
      body: SafeArea(
        child: group.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오지 못했어요: $e')),
          data: (g) => g == null
              ? const SizedBox.shrink()
              : GlassBody(child: builder(g)),
        ),
      ),
    );
  }
}
