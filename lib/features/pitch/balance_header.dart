import 'package:material_ui/material_ui.dart';

import '../common/common_widgets.dart';

import '../../core/scoring/balance_score.dart';

/// 구장 화면 최상단 고정 헤더: 실시간 밸런스 점수 (SPEC F5).
class BalanceHeader extends StatelessWidget {
  const BalanceHeader({
    super.key,
    required this.balance,
    required this.previous,
    required this.candidateCount,
    required this.selected,
    required this.onSelect,
    required this.onBack,
  });

  /// 아직 배치 전이면 null.
  final BalanceBreakdown? balance;

  /// 직전 점수 (▲▼ 표시용).
  final double? previous;
  final int candidateCount;
  final int selected;
  final ValueChanged<int>? onSelect;
  final VoidCallback onBack;

  static Color gradeColor(BalanceGrade g) => switch (g) {
    BalanceGrade.excellent => const Color(0xFF2E9D52),
    BalanceGrade.good => const Color(0xFF7CB342),
    BalanceGrade.fair => const Color(0xFFF08C00),
    BalanceGrade.poor => const Color(0xFFD64545),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = balance;
    if (b != null && isNarrow(context)) {
      // 세로: 윗줄 뒤로·점수, 아랫줄 세부 점수·편성안 선택.
      return Material(
        color: Colors.transparent,
        child: SizedBox(
          height: 88,
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '뒤로',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    ),
                    _score(theme, b),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Expanded(child: _breakdown(theme, b)),
                      if (candidateCount > 1) _candidates(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              tooltip: '뒤로',
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            if (b == null)
              Expanded(
                child: Text(
                  '⚖️ 밸런스 —   ⚡ 자동 편성을 눌러 팀을 짜 보세요',
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else ...[
              _score(theme, b),
              const SizedBox(width: 10),
              Expanded(child: _breakdown(theme, b)),
            ],
            if (candidateCount > 1) _candidates(),
          ],
        ),
      ),
    );
  }

  /// 편성안 1·2·3 선택.
  Widget _candidates() => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: SegmentedButton<int>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: [
        for (var i = 0; i < candidateCount; i++)
          ButtonSegment(value: i, label: Text('${i + 1}')),
      ],
      selected: {selected},
      onSelectionChanged: onSelect == null ? null : (s) => onSelect!(s.first),
    ),
  );

  Widget _score(ThemeData theme, BalanceBreakdown b) {
    final color = gradeColor(b.grade);
    final delta = previous == null ? 0 : b.rounded - previous!.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚖️ ', style: TextStyle(fontSize: 18)),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: previous ?? 0, end: b.total),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, v, _) => Text(
            '${v.round()}',
            key: const Key('balanceScore'),
            style: theme.textTheme.headlineSmall!.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(' / 100', style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            b.grade.label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
        if (delta != 0) ...[
          const SizedBox(width: 6),
          Text(
            delta > 0 ? '▲$delta' : '▼${-delta}',
            style: TextStyle(
              color: delta > 0
                  ? const Color(0xFF2E9D52)
                  : const Color(0xFFD64545),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _breakdown(ThemeData theme, BalanceBreakdown b) {
    final items = [
      ('전력', b.strength),
      ('공격', b.attack),
      ('수비', b.defense),
      ('포지션', b.position),
    ];
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (final (label, v) in items)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$label ', style: theme.textTheme.bodySmall),
                    TextSpan(
                      text: '${v.round()}',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
