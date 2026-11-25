import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../../core/scoring/metrics.dart';
import '../../data/providers.dart';
import '../../data/repositories/player_repository.dart';
import '../common/common_widgets.dart';

/// 선수 등록·수정 폼 (SPEC F1.1, F1.3, F1.4).
class PlayerEditor extends ConsumerStatefulWidget {
  const PlayerEditor({
    super.key,
    required this.groupId,
    required this.player,
    required this.canSeeStats,
    required this.onSaved,
    required this.onDeleted,
  });

  final String groupId;

  /// null이면 새 선수.
  final Player? player;

  /// 멤버 역할은 능력치를 보거나 고칠 수 없다 (SPEC F13.5).
  final bool canSeeStats;
  final ValueChanged<String> onSaved;
  final VoidCallback onDeleted;

  @override
  ConsumerState<PlayerEditor> createState() => _PlayerEditorState();
}

class _PlayerEditorState extends ConsumerState<PlayerEditor> {
  late final _name = TextEditingController(text: widget.player?.name);
  late final _nickname = TextEditingController(text: widget.player?.nickname);
  late final _memo = TextEditingController(text: widget.player?.memo);
  late MemberType _memberType = widget.player?.memberType ?? MemberType.regular;
  late Position _main = widget.player?.mainPosition ?? Position.ala;
  late final Set<Position> _subs = {...?widget.player?.subPositions};
  late bool _canKeep = widget.player?.canKeep ?? false;
  late PlayerStats _stats =
      widget.player?.stats ?? PlayerStats.uniform(PlayerStats.defaultValue);
  late bool _statsSimple = widget.player?.statsSimple ?? true;
  bool _dirty = false;

  bool get _isNew => widget.player == null;

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    _memo.dispose();
    super.dispose();
  }

  void _change(VoidCallback fn) => setState(() {
    fn();
    _dirty = true;
  });

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('이름을 입력해 주세요.')));
      return;
    }
    final player = Player(
      id: widget.player?.id ?? PlayerRepository.newId(),
      name: name,
      nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
      memberType: _memberType,
      stats: _stats,
      mainPosition: _main,
      subPositions: _subs,
      canKeep: _canKeep,
      memo: _memo.text.trim().isEmpty ? null : _memo.text.trim(),
      statsSimple: _statsSimple,
    );
    await ref.read(playerRepositoryProvider).savePlayer(widget.groupId, player);
    if (!mounted) return;
    // 저장 버튼 글자가 "저장됨"으로 바뀐다 (스낵바는 아래쪽 버튼을 가려서 쓰지 않음).
    setState(() => _dirty = false);
    widget.onSaved(player.id);
  }

  Future<void> _delete() async {
    final p = widget.player!;
    final ok = await confirmDialog(
      context,
      title: '선수 삭제',
      message: '${p.name} 선수를 삭제할까요?',
    );
    if (!ok) return;
    await ref.read(playerRepositoryProvider).deletePlayer(p.id);
    widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isNew ? '새 선수' : widget.player!.name,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('playerName'),
                        controller: _name,
                        decoration: const InputDecoration(labelText: '이름'),
                        onChanged: (_) => _dirty = true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nickname,
                        decoration: const InputDecoration(labelText: '별명 (선택)'),
                        onChanged: (_) => _dirty = true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label(theme, '멤버 구분'),
                SegmentedButton<MemberType>(
                  segments: [
                    for (final m in MemberType.values)
                      ButtonSegment(value: m, label: Text(m.label)),
                  ],
                  selected: {_memberType},
                  onSelectionChanged: (s) =>
                      _change(() => _memberType = s.first),
                ),
                const SizedBox(height: 12),
                _label(theme, '주 포지션'),
                SegmentedButton<Position>(
                  segments: [
                    for (final p in Position.values)
                      ButtonSegment(value: p, label: Text(p.label)),
                  ],
                  selected: {_main},
                  onSelectionChanged: (s) => _change(() {
                    _main = s.first;
                    _subs.remove(_main);
                  }),
                ),
                const SizedBox(height: 12),
                _label(theme, '가능 포지션 (선택)'),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final p in Position.values)
                      if (p != _main)
                        FilterChip(
                          label: Text(p.label),
                          selected: _subs.contains(p),
                          onSelected: (on) => _change(
                            () => on ? _subs.add(p) : _subs.remove(p),
                          ),
                        ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('키퍼 가능 🧤'),
                  subtitle: const Text('키퍼 고정 자동 배정·로테이션 시작 키퍼 우선 대상'),
                  value: _canKeep,
                  onChanged: (v) => _change(() => _canKeep = v),
                ),
                if (widget.canSeeStats) ...[
                  const Divider(),
                  _statsSection(theme),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: _memo,
                  decoration: const InputDecoration(labelText: '메모 (선택)'),
                  maxLines: 2,
                  onChanged: (_) => _dirty = true,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (!_isNew)
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('삭제'),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(_isNew ? '추가' : (_dirty ? '저장' : '저장됨')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: theme.textTheme.labelLarge),
  );

  Widget _statsSection(ThemeData theme) {
    final metrics = PlayerMetrics.of(
      Player(id: '', name: '', stats: _stats, mainPosition: _main),
    );
    final uniform = Stat.values.every((s) => _stats[s] == _stats[Stat.shooting])
        ? _stats[Stat.shooting]
        : null;
    final pickers = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('능력치', style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            if (_statsSimple) const TagBadge('간단'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 72, child: Text('빠른 입력')),
            ScorePicker(
              value: uniform,
              onChanged: (v) => _change(() {
                _stats = PlayerStats.uniform(v);
                _statsSimple = true;
              }),
            ),
          ],
        ),
        const Divider(),
        for (final s in Stat.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Tooltip(
                    message: s == Stat.teamwork ? '수비 가담 + 팀플레이' : '',
                    child: Text(s.label),
                  ),
                ),
                ScorePicker(
                  size: 30,
                  value: _stats[s],
                  onChanged: (v) => _change(() {
                    _stats = _stats.copyWith(s, v);
                    _statsSimple = false;
                  }),
                ),
              ],
            ),
          ),
      ],
    );
    final chart = SizedBox(
      width: 190,
      child: Column(
        children: [
          StatRadarChart(stats: _stats),
          const SizedBox(height: 6),
          Text(
            'OVR ${metrics.ovr.toStringAsFixed(1)}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          MetricBar(
            label: '공격력',
            value: metrics.attack,
            color: positionColor(Position.pivo),
          ),
          const SizedBox(height: 4),
          MetricBar(
            label: '수비력',
            value: metrics.defense,
            color: positionColor(Position.fixo),
          ),
        ],
      ),
    );
    // 넓으면 차트를 옆에, 좁은 가로 폰에서는 아래에 둔다.
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 460
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: pickers),
                const SizedBox(width: 12),
                chart,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pickers,
                const SizedBox(height: 12),
                Center(child: chart),
              ],
            ),
    );
  }
}
