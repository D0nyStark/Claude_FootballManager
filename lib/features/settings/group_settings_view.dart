import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/formation.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/common_widgets.dart';
import '../tutorial/tutorial.dart';

/// 모임 설정 (SPEC F10 중 M2 범위: 이름·아이콘·색·기본 형식·내 이름).
class GroupSettingsView extends ConsumerWidget {
  const GroupSettingsView({super.key, required this.group});

  final GroupInfo group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(groupRepositoryProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('모임 설정', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('모임 이름'),
          subtitle: Text(group.name),
          trailing: const Icon(Icons.edit),
          onTap: () async {
            final name = await _ask(context, '모임 이름', group.name);
            if (name != null && name.trim().isNotEmpty) {
              await repo.updateGroup(group.id, name: name);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('내 표시 이름'),
          subtitle: Text(group.myDisplayName ?? '없음'),
          trailing: const Icon(Icons.edit),
          onTap: () async {
            final name = await _ask(
              context,
              '내 표시 이름',
              group.myDisplayName ?? '',
            );
            if (name != null) {
              await repo.updateGroup(group.id, myDisplayName: () => name);
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('내 역할'),
          subtitle: Text(group.role.label),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.school_outlined),
          title: const Text('사용법 다시 보기'),
          subtitle: const Text('각 화면에 처음 들어갈 때처럼 설명 말풍선을 다시 보여줘요.'),
          onTap: () async {
            await ref.read(tutorialServiceProvider).reset();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('이제 각 화면에서 사용법이 다시 보여요.')),
              );
          },
        ),
        const SizedBox(height: 8),
        Text('아이콘', style: theme.textTheme.labelLarge),
        Wrap(
          spacing: 6,
          children: [
            for (final icon in groupIcons)
              ChoiceChip(
                label: Text(icon, style: const TextStyle(fontSize: 18)),
                selected: group.icon == icon,
                onSelected: (_) => repo.updateGroup(group.id, icon: icon),
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
                onTap: () => repo.updateGroup(group.id, color: c),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(c),
                  child: group.color == c
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('기본 경기 방식', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<MatchFormat>(
            segments: [
              for (final f in MatchFormat.values)
                ButtonSegment(value: f, label: Text(f.label)),
            ],
            selected: {group.defaultFormat},
            onSelectionChanged: (s) =>
                repo.updateGroup(group.id, defaultFormat: s.first),
          ),
        ),
      ],
    );
  }

  Future<String?> _ask(BuildContext context, String title, String current) {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
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
