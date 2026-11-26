import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../../data/history/confirmed_lineup.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/common_widgets.dart';
import '../share/share_service.dart';
import '../share/share_sheet.dart';
import '../share/share_text.dart';

/// 편성 이력 (최근 3개, SPEC F8.3~F8.4): 다시 보기 · 다시 공유 · 삭제.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key, required this.group});

  final GroupInfo group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider(group.id));
    return Scaffold(
      appBar: AppBar(title: const Text('편성 이력 (최근 3개)')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('아직 확정한 편성이 없어요.'))
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final h in list) _HistoryCard(group: group, entry: h),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '확정한 편성은 다음 팀 짜기 때 같은 조합을 피하는 데 쓰여요. '
                      '잘못 확정했다면 삭제하세요.',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.group, required this.entry});

  final GroupInfo group;
  final ConfirmedLineup entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final d = entry.confirmedAt;
    final lineup = entry.lineup;
    String text(bool _) => buildShareText(
      lineup: lineup,
      teamNames: entry.teamNames,
      nameOf: entry.nameOf,
      date: d,
      balanceScore: entry.balanceScore.round(),
      groupName: group.name,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:'
                  '${d.minute.toString().padLeft(2, '0')} · '
                  '${lineup.format.label} · ${lineup.teams.length}팀',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                Text('밸런스 ${entry.balanceScore.round()}'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showShareSheet(
                    context,
                    service: ref.read(shareServiceProvider),
                    canIncludeStats: false,
                    text: text,
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('다시 공유'),
                ),
                IconButton(
                  tooltip: '삭제',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await confirmDialog(
                      context,
                      title: '이력 삭제',
                      message: '이 편성을 이력에서 지울까요? 반복 조합 회피에서도 빠져요.',
                    );
                    if (ok) {
                      await ref
                          .read(historyRepositoryProvider)
                          .delete(entry.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (var t = 0; t < lineup.teams.length; t++)
                  _teamColumn(theme, t, lineup.teams[t], lineup.format),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamColumn(
    ThemeData theme,
    int t,
    TeamLineup team,
    MatchFormat format,
  ) => SizedBox(
    width: 170,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.teamNames[t],
          style: theme.textTheme.labelLarge!.copyWith(color: entry.colorOf(t)),
        ),
        for (final slot in format.slots)
          if (team.slots[slot] != null)
            Text(
              '${slot.label}  ${entry.nameOf(team.slots[slot]!)}',
              style: theme.textTheme.bodySmall,
            ),
        if (team.bench.isNotEmpty)
          Text(
            '후보  ${team.bench.map(entry.nameOf).join(', ')}',
            style: theme.textTheme.bodySmall,
          ),
      ],
    ),
  );
}
