import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/formation.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../common/common_widgets.dart';
import '../tutorial/tutorial.dart';
import '../../core/balancer/balance_request.dart';
import '../../core/models/team_constraint.dart';
import '../../core/scoring/weights.dart';
import '../../data/repositories/settings_repository.dart';
import '../backup/backup_actions.dart';
import '../history/history_page.dart';

/// 모임 설정 (SPEC F10) · 편성 이력 · 백업/복원 (SPEC F9).
class GroupSettingsView extends ConsumerWidget {
  const GroupSettingsView({super.key, required this.group});

  final GroupInfo group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(groupRepositoryProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 16),
          ..._matchSettings(context, ref),
          const Divider(height: 32),
          Text('기록·백업', style: theme.textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: const Text('편성 이력 (최근 3개)'),
            subtitle: const Text('확정한 편성 다시 보기·공유·삭제'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HistoryPage(group: group)),
            ),
          ),
          ListTile(
            key: const Key('exportBackup'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.upload_file),
            title: const Text('백업 내보내기'),
            subtitle: const Text('선수·능력치·조건·이력·설정을 .mug 파일로 저장·전송'),
            onTap: () => exportGroupBackup(ref, group),
          ),
          ListTile(
            key: const Key('importBackup'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_open),
            title: const Text('백업 가져오기'),
            subtitle: const Text('덮어쓰기 또는 병합 (가져오기 전에 자동 백업)'),
            onTap: () => importGroupBackup(context, ref),
          ),
        ],
      ),
    );
  }

  /// 편성 관련 모임 설정: 기본 팀 수·키퍼 방식, 반복 회피, 밸런스 비중.
  List<Widget> _matchSettings(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs =
        ref.watch(preferencesProvider(group.id)).value ??
        const GroupPreferences();
    final settings = ref.read(settingsRepositoryProvider);
    Future<void> set(String key, String value) =>
        settings.set(group.id, key, value);
    Widget row(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Flexible(child: child),
        ],
      ),
    );
    return [
      row(
        '기본 팀 수',
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 2, label: Text('2팀')),
            ButtonSegment(value: 3, label: Text('3팀')),
            ButtonSegment(value: 4, label: Text('4팀')),
          ],
          selected: {prefs.defaultTeamCount},
          onSelectionChanged: (s) =>
              set(GroupPreferences.keyTeamCount, '${s.first}'),
        ),
      ),
      row(
        '기본 골키퍼',
        SegmentedButton<KeeperMode>(
          segments: const [
            ButtonSegment(value: KeeperMode.rotation, label: Text('로테이션')),
            ButtonSegment(value: KeeperMode.fixed, label: Text('키퍼 고정')),
          ],
          selected: {prefs.defaultKeeperMode},
          onSelectionChanged: (s) =>
              set(GroupPreferences.keyKeeper, s.first.name),
        ),
      ),
      row(
        '반복 조합 회피',
        SegmentedButton<RepeatAvoidance>(
          key: const Key('repeatAvoidance'),
          segments: [
            for (final r in RepeatAvoidance.values)
              ButtonSegment(value: r, label: Text(r.label)),
          ],
          selected: {prefs.repeatAvoidance},
          onSelectionChanged: (s) =>
              set(GroupPreferences.keyRepeat, s.first.name),
        ),
      ),
      _WeightSliders(
        key: ValueKey(prefs.weights),
        weights: prefs.weights,
        onSave: (w) async {
          await set(GroupPreferences.keyWStrength, '${w.strength}');
          await set(GroupPreferences.keyWAttack, '${w.attack}');
          await set(GroupPreferences.keyWDefense, '${w.defense}');
          await set(GroupPreferences.keyWPosition, '${w.position}');
        },
      ),
    ];
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

/// 밸런스 점수 비중 (SPEC §6.5): 전력·공격·수비·포지션.
class _WeightSliders extends StatefulWidget {
  const _WeightSliders({
    super.key,
    required this.weights,
    required this.onSave,
  });

  final BalanceWeights weights;
  final Future<void> Function(BalanceWeights) onSave;

  @override
  State<_WeightSliders> createState() => _WeightSlidersState();
}

class _WeightSlidersState extends State<_WeightSliders> {
  late var _w = widget.weights;

  BalanceWeights _with({double? s, double? a, double? d, double? p}) =>
      BalanceWeights(
        strength: s ?? _w.strength,
        attack: a ?? _w.attack,
        defense: d ?? _w.defense,
        position: p ?? _w.position,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _w.strength + _w.attack + _w.defense + _w.position;
    Widget slider(String label, double v, BalanceWeights Function(double) f) =>
        Row(
          children: [
            SizedBox(width: 60, child: Text(label)),
            Expanded(
              child: Slider(
                value: v,
                max: 1,
                divisions: 20,
                onChanged: (x) => setState(() => _w = f(x)),
                onChangeEnd: (_) => widget.onSave(_w),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                total == 0 ? '-' : '${(v / total * 100).round()}%',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('밸런스 점수 비중', style: theme.textTheme.labelLarge),
      subtitle: const Text('기본: 전력 30 · 공격 30 · 수비 30 · 포지션 10'),
      children: [
        slider('전력', _w.strength, (x) => _with(s: x)),
        slider('공격', _w.attack, (x) => _with(a: x)),
        slider('수비', _w.defense, (x) => _with(d: x)),
        slider('포지션', _w.position, (x) => _with(p: x)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() => _w = BalanceWeights.standard);
              widget.onSave(_w);
            },
            child: const Text('기본값으로'),
          ),
        ),
      ],
    );
  }
}
