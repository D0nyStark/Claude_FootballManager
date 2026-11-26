import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// 말풍선 하나: 화면의 [CoachTarget] id를 가리키며 설명한다.
class CoachStep {
  const CoachStep(this.targetId, this.title, this.body);

  final String targetId;
  final String title;
  final String body;
}

/// 말풍선이 끝난 방식.
enum CoachResult { finished, skippedAll }

/// 화면 안의 [CoachTarget]들을 모아 두는 범위. 튜토리얼 말풍선이 여기서 대상을 찾는다.
class CoachScope extends StatefulWidget {
  const CoachScope({super.key, required this.child});

  final Widget child;

  static CoachScopeState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CoachScopeData>()?.state;

  @override
  State<CoachScope> createState() => CoachScopeState();
}

class CoachScopeState extends State<CoachScope> {
  final Map<String, GlobalKey> _targets = {};

  void _register(String id, GlobalKey key) => _targets[id] = key;

  void _unregister(String id, GlobalKey key) {
    if (_targets[id] == key) _targets.remove(id);
  }

  /// 지금 화면에 붙어 있는 대상의 BuildContext.
  BuildContext? contextOf(String id) => _targets[id]?.currentContext;

  /// [steps] 중 화면에 있는 대상만 골라 말풍선을 차례로 보여준다.
  Future<CoachResult> show(List<CoachStep> steps) async {
    final visible = [
      for (final s in steps)
        if (contextOf(s.targetId) != null) s,
    ];
    if (visible.isEmpty) return CoachResult.finished;
    final result = await Navigator.of(context).push<CoachResult>(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (_, _, _) => _CoachOverlay(scope: this, steps: visible),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    return result ?? CoachResult.finished;
  }

  @override
  Widget build(BuildContext context) =>
      _CoachScopeData(state: this, child: widget.child);
}

class _CoachScopeData extends InheritedWidget {
  const _CoachScopeData({required this.state, required super.child});

  final CoachScopeState state;

  @override
  bool updateShouldNotify(_CoachScopeData old) => old.state != state;
}

/// 말풍선이 가리킬 수 있는 위젯 표시.
class CoachTarget extends StatefulWidget {
  const CoachTarget({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  State<CoachTarget> createState() => _CoachTargetState();
}

class _CoachTargetState extends State<CoachTarget> {
  final _key = GlobalKey();
  CoachScopeState? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = CoachScope.maybeOf(context);
    if (scope != _scope) {
      _scope?._unregister(widget.id, _key);
      _scope = scope?.._register(widget.id, _key);
    }
  }

  @override
  void didUpdateWidget(CoachTarget old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _scope?._unregister(old.id, _key);
      _scope?._register(widget.id, _key);
    }
  }

  @override
  void dispose() {
    _scope?._unregister(widget.id, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}

class _CoachOverlay extends StatefulWidget {
  const _CoachOverlay({required this.scope, required this.steps});

  final CoachScopeState scope;
  final List<CoachStep> steps;

  @override
  State<_CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<_CoachOverlay> {
  int _index = 0;
  Rect? _rect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  /// 대상이 화면 밖이면 스크롤해서 보이게 한 뒤 위치를 잰다.
  Future<void> _measure() async {
    final target = widget.scope.contextOf(widget.steps[_index].targetId);
    if (target == null || !target.mounted) {
      setState(() => _rect = null);
      return;
    }
    await Scrollable.ensureVisible(
      target,
      alignment: 0.5,
      duration: const Duration(milliseconds: 200),
    );
    if (!mounted || !target.mounted) return;
    final box = target.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final overlay = context.findRenderObject() as RenderBox?;
    final origin = overlay?.localToGlobal(Offset.zero) ?? Offset.zero;
    setState(
      () => _rect = (box.localToGlobal(Offset.zero) - origin) & box.size,
    );
  }

  void _go(int index) {
    if (index >= widget.steps.length) {
      Navigator.of(context).pop(CoachResult.finished);
      return;
    }
    setState(() {
      _index = index;
      _rect = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final last = _index == widget.steps.length - 1;
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final hole = _rect?.inflate(6);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _go(_index + 1),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _DimPainter(hole: hole)),
                ),
                if (hole != null)
                  _bubble(context, size, hole, step, last)
                else
                  Center(child: _card(context, step, last)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 대상 주변에서 공간이 가장 넓은 쪽(아래·위·오른쪽·왼쪽)에 말풍선을 둔다.
  Widget _bubble(
    BuildContext context,
    Size size,
    Rect hole,
    CoachStep step,
    bool last,
  ) {
    const margin = 12.0;
    final width = math.min(320.0, size.width - 2 * margin);
    final below = size.height - hole.bottom;
    final above = hole.top;
    final right = size.width - hole.right;
    final left = hole.left;
    final space = [below, above, right * 0.6, left * 0.6];
    final best = space.indexOf(space.reduce(math.max));
    final card = _card(context, step, last);
    // 말풍선이 들어갈 영역을 정하고, 그 안에서 대상 쪽으로 붙인다 (화면 밖으로 나가지 않음).
    final ay = ((hole.center.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    final ax = ((hole.center.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    Widget region(Rect area, Alignment alignment) => Positioned.fromRect(
      rect: area,
      child: Align(
        alignment: alignment,
        child: SizedBox(width: math.min(width, area.width), child: card),
      ),
    );
    return switch (best) {
      0 => region(
        Rect.fromLTRB(
          margin,
          hole.bottom + margin,
          size.width - margin,
          size.height - margin,
        ),
        Alignment(ax, -1),
      ),
      1 => region(
        Rect.fromLTRB(margin, margin, size.width - margin, hole.top - margin),
        Alignment(ax, 1),
      ),
      2 => region(
        Rect.fromLTRB(
          hole.right + margin,
          margin,
          size.width - margin,
          size.height - margin,
        ),
        Alignment(-1, ay),
      ),
      _ => region(
        Rect.fromLTRB(margin, margin, hole.left - margin, size.height - margin),
        Alignment(1, ay),
      ),
    };
  }

  Widget _card(BuildContext context, CoachStep step, bool last) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {}, // 말풍선 안을 눌러도 넘어가지 않게.
      child: Card(
        key: const Key('coachBubble'),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(step.title, style: theme.textTheme.titleMedium),
                  ),
                  Text(
                    '${_index + 1}/${widget.steps.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(step.body, style: theme.textTheme.bodyMedium),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(CoachResult.skippedAll),
                    child: const Text('모두 건너뛰기'),
                  ),
                  const Spacer(),
                  if (_index > 0)
                    TextButton(
                      onPressed: () => _go(_index - 1),
                      child: const Text('이전'),
                    ),
                  FilledButton(
                    onPressed: () => _go(_index + 1),
                    child: Text(last ? '완료' : '다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 화면을 어둡게 하고 [hole]만 밝게 비운다.
class _DimPainter extends CustomPainter {
  _DimPainter({required this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final full = Path()..addRect(Offset.zero & size);
    if (hole == null) {
      canvas.drawPath(full, dim);
      return;
    }
    final rrect = RRect.fromRectAndRadius(hole!, const Radius.circular(12));
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, Path()..addRRect(rrect)),
      dim,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.hole != hole;
}
