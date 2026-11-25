import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../../data/providers.dart';

/// 상시 제약 관리: "항상 같은 팀" / "항상 다른 팀" (SPEC F1.5).
class ConstraintsView extends ConsumerWidget {
  const ConstraintsView({
    super.key,
    required this.groupId,
    required this.players,
  });

  final String groupId;
  final List<Player> players;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constraints = ref.watch(constraintsProvider(groupId)).value ?? [];
    final names = {for (final p in players) p.id: p.name};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.tonalIcon(
            onPressed: players.length < 2 ? null : () => _add(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('제약 추가'),
          ),
        ),
        Expanded(
          child: constraints.isEmpty
              ? const Center(child: Text('설정한 제약이 없어요.'))
              : ListView(
                  children: [
                    for (final c in constraints)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          c.type == ConstraintType.together
                              ? Icons.link
                              : Icons.link_off,
                        ),
                        title: Text('항상 ${c.type.label}'),
                        subtitle: Text(
                          c.playerIds
                              .map((id) => names[id] ?? '(삭제된 선수)')
                              .join(', '),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref
                              .read(playerRepositoryProvider)
                              .deleteConstraint(c.id!),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(ConstraintType, Set<String>)>(
      context: context,
      builder: (_) => ConstraintDialog(players: players),
    );
    if (result == null) return;
    await ref
        .read(playerRepositoryProvider)
        .addConstraint(groupId, result.$1, result.$2);
  }
}

/// 제약 추가 창: 종류 + 선수 2명 이상 (상시 제약·당일 제약 공용).
class ConstraintDialog extends StatefulWidget {
  const ConstraintDialog({super.key, required this.players});

  final List<Player> players;

  @override
  State<ConstraintDialog> createState() => _ConstraintDialogState();
}

class _ConstraintDialogState extends State<ConstraintDialog> {
  ConstraintType _type = ConstraintType.together;
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.players]
      ..sort((a, b) => a.name.compareTo(b.name));
    return AlertDialog(
      title: const Text('제약 추가'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<ConstraintType>(
              segments: [
                for (final t in ConstraintType.values)
                  ButtonSegment(value: t, label: Text('항상 ${t.label}')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            const Text('선수를 2명 이상 고르세요.'),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in sorted)
                      FilterChip(
                        label: Text(p.name),
                        selected: _selected.contains(p.id),
                        onSelected: (on) => setState(
                          () =>
                              on ? _selected.add(p.id) : _selected.remove(p.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _selected.length < 2
              ? null
              : () => Navigator.pop(context, (_type, {..._selected})),
          child: const Text('추가'),
        ),
      ],
    );
  }
}
