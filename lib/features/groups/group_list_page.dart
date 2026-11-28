import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../common/glass.dart';

import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/common_widgets.dart';
import '../group/group_shell_page.dart';
import '../onboarding/onboarding_page.dart';
import '../tutorial/coach_marks.dart';
import '../tutorial/tutorial.dart';
import '../tutorial/tutorial_steps.dart';
import '../backup/backup_actions.dart';

import 'dart:async';

import '../invite/invite_actions.dart';

/// 첫 화면: 모임 목록 (SPEC F11, §8.2).
class GroupListPage extends ConsumerStatefulWidget {
  const GroupListPage({super.key, this.autoEnterSingleGroup = true});

  /// 모임이 1개뿐이면 앱 실행 시 바로 그 모임으로 들어간다 (F11.5).
  final bool autoEnterSingleGroup;

  @override
  ConsumerState<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends ConsumerState<GroupListPage> {
  StreamSubscription<String>? _links;
  bool _autoEnterChecked = false;
  bool _autoEntering = false;

  @override
  void initState() {
    super.initState();
    // 앱이 초대 링크로 열리면 바로 처리 (SPEC F13.2).
    _links = ref.read(incomingLinksProvider).listen((link) {
      if (mounted) handleIncoming(context, ref, link);
    });
    // 설치 직후 첫 실행: 안내 페이지에서 복사한 초대가 클립보드에 있으면 묻는다 (SPEC F13.3).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final text = await ref.read(clipboardTextProvider)();
      if (text != null && mounted) {
        await handleIncoming(context, ref, text, quiet: true);
      }
    });
  }

  @override
  void dispose() {
    _links?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);

    if (!_autoEnterChecked && groups.hasValue) {
      _autoEnterChecked = true;
      final list = groups.value!;
      if (widget.autoEnterSingleGroup && list.length == 1) {
        _autoEntering = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openGroup(list.single);
        });
      }
    }

    return TutorialHost(
      screen: TutorialScreen.groupList,
      // 바로 모임으로 들어가는 경우에는 돌아왔을 때 보여준다.
      ready: groups.hasValue && !_autoEntering,
      steps: () => TutorialSteps.groupList,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Football Team Maker',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              key: const Key('importBackupList'),
              tooltip: '백업 가져오기',
              icon: const Icon(Icons.file_open),
              onPressed: () => importGroupBackup(context, ref),
            ),
            CoachTarget(
              id: 'groups.join',
              // 세로(좁은 화면)는 아이콘만.
              child: isNarrow(context)
                  ? IconButton(
                      key: const Key('joinByLink'),
                      tooltip: '초대 링크로 참여',
                      onPressed: () => askAndJoin(context, ref),
                      icon: const Icon(Icons.link),
                    )
                  : TextButton.icon(
                      key: const Key('joinByLink'),
                      onPressed: () => askAndJoin(context, ref),
                      icon: const Icon(Icons.link),
                      label: const Text('초대 링크로 참여'),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: groups.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오지 못했어요: $e')),
          data: (list) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final (i, g) in list.indexed)
                  CoachTarget(
                    id: i == 0 ? 'groups.card' : 'groups.card$i',
                    child: _GroupCard(
                      group: g,
                      onTap: () => _openGroup(g),
                      onLongPress: () => _showGroupMenu(g),
                    ),
                  ),
                CoachTarget(
                  id: 'groups.create',
                  child: _CreateGroupCard(onTap: _createGroup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openGroup(GroupInfo g) async {
    await ref.read(groupRepositoryProvider).touch(g.id);
    if (!mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GroupShellPage(groupId: g.id)));
    if (_autoEntering && mounted) setState(() => _autoEntering = false);
  }

  void _createGroup() =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const OnboardingPage()));

  Future<void> _showGroupMenu(GroupInfo g) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('이름 변경'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('이 기기에서 모임 삭제'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    final repo = ref.read(groupRepositoryProvider);
    if (action == 'rename') {
      final name = await _askName(g.name);
      if (name != null && name.trim().isNotEmpty) {
        await repo.updateGroup(g.id, name: name);
      }
    } else if (action == 'delete') {
      final ok = await confirmDialog(
        context,
        title: '모임 삭제',
        message: '"${g.name}" 모임과 선수 ${g.playerCount}명이 이 기기에서 삭제돼요.',
      );
      if (ok) await repo.deleteGroup(g.id);
    }
  }

  Future<String?> _askName(String current) {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모임 이름'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onLongPress,
  });

  final GroupInfo group;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(group.color);
    final used = group.lastUsedAt;
    return SizedBox(
      width: 210,
      height: 140,
      child: Glass(
        radius: 20,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Container(width: 6, color: color.withValues(alpha: 0.85)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${group.icon} ${group.name}',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text('선수 ${group.playerCount}명'),
                        Text(
                          '${group.role.label} · ${used.month}/${used.day}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateGroupCard extends StatelessWidget {
  const _CreateGroupCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 210,
      height: 140,
      child: Glass(
        radius: 20,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  const Text('새 모임 만들기'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
