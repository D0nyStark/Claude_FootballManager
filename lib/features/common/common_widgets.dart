import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/models/formation.dart';
import '../../core/models/player_stats.dart';
import '../../core/models/position.dart';

/// 폭이 좁으면(세로로 든 폰, 600dp 미만) 세로 배치를 쓴다.
bool isNarrow(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

/// 포지션 색 (SPEC §4.3): 픽소 파랑 · 아라 초록 · 피보 빨강.
Color positionColor(Position p) => switch (p) {
  Position.fixo => const Color(0xFF2F6FD6),
  Position.ala => const Color(0xFF2E9D52),
  Position.pivo => const Color(0xFFD64545),
};

class PositionBadge extends StatelessWidget {
  const PositionBadge(this.position, {super.key, this.outlined = false});

  final Position position;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final color = positionColor(position);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: outlined ? null : color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        position.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 작은 상태 배지 (예: `간단`).
class TagBadge extends StatelessWidget {
  const TagBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: scheme.onTertiaryContainer),
      ),
    );
  }
}

/// 1~5점을 한 번 탭으로 고르는 선택기 (SPEC §4.2).
class ScorePicker extends StatelessWidget {
  const ScorePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 34,
  });

  final int? value;
  final ValueChanged<int>? onChanged;
  final double size;

  static const guide = {
    1: '초보 — 아직 익숙하지 않음',
    2: '미숙 — 가끔 해냄',
    3: '보통 — 모임 평균 수준',
    4: '능숙 — 확실한 강점',
    5: '에이스 — 모임 최상위',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var v = PlayerStats.minValue; v <= PlayerStats.maxValue; v++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: '$v점: ${guide[v]}',
              child: Semantics(
                button: true,
                selected: value == v,
                label: '$v점',
                child: InkWell(
                  key: ValueKey('score-$v'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: onChanged == null ? null : () => onChanged!(v),
                  child: Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == v ? scheme.primary : null,
                      border: Border.all(
                        color: value == v ? scheme.primary : scheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$v',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: value == v ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 능력치 레이더 차트 (8각형, SPEC F1.3).
class StatRadarChart extends StatelessWidget {
  const StatRadarChart({super.key, required this.stats, this.size = 180});

  final PlayerStats stats;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RadarPainter(
          stats: stats,
          grid: scheme.outlineVariant,
          fill: scheme.primary.withValues(alpha: 0.25),
          stroke: scheme.primary,
          text: Theme.of(context).textTheme.labelSmall!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.stats,
    required this.grid,
    required this.fill,
    required this.stroke,
    required this.text,
  });

  final PlayerStats stats;
  final Color grid;
  final Color fill;
  final Color stroke;
  final TextStyle text;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 22;
    final count = Stat.values.length;
    Offset point(int i, double r) {
      final angle = -math.pi / 2 + 2 * math.pi * i / count;
      return center + Offset(math.cos(angle), math.sin(angle)) * r;
    }

    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke;
    for (var level = 1; level <= 5; level++) {
      final path = Path();
      for (var i = 0; i < count; i++) {
        final p = point(i, radius * level / 5);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), gridPaint);
    }

    final shape = Path();
    for (var i = 0; i < count; i++) {
      final p = point(i, radius * stats[Stat.values[i]] / 5);
      i == 0 ? shape.moveTo(p.dx, p.dy) : shape.lineTo(p.dx, p.dy);
    }
    shape.close();
    canvas.drawPath(shape, Paint()..color = fill);
    canvas.drawPath(
      shape,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < count; i++) {
      final tp = TextPainter(
        text: TextSpan(text: Stat.values[i].label, style: text),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = point(i, radius + 13);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.stats != stats || old.fill != fill || old.grid != grid;
}

/// 0~5 막대 (공격력·수비력).
class MetricBar extends StatelessWidget {
  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 5,
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(value.toStringAsFixed(1), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

/// 모임 아이콘·색 선택지.
const groupIcons = ['⚽', '🥅', '🏆', '🔥', '⭐', '🦁', '🐯', '🦅'];
const groupColors = [
  0xFF1B8A3C,
  0xFF2F6FD6,
  0xFFD64545,
  0xFFE08A00,
  0xFF7B4CC2,
  0xFF00897B,
];

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = '삭제',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;

/// 팀 인원(경기 형식) 선택: [−] 5 vs 5 [+] — 4vs4~7vs7을 버튼 4개 대신 한 줄로.
class FormatStepper extends StatelessWidget {
  const FormatStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MatchFormat value;
  final ValueChanged<MatchFormat>? onChanged;

  @override
  Widget build(BuildContext context) {
    const all = MatchFormat.values; // 인원 순서 (4 → 7)
    final i = all.indexOf(value);
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          key: const Key('formatDown'),
          tooltip: '인원 줄이기',
          onPressed: onChanged == null || i == 0
              ? null
              : () => onChanged!(all[i - 1]),
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 92,
          child: Text(
            value.label,
            key: const Key('formatValue'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton.outlined(
          key: const Key('formatUp'),
          tooltip: '인원 늘리기',
          onPressed: onChanged == null || i == all.length - 1
              ? null
              : () => onChanged!(all[i + 1]),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
