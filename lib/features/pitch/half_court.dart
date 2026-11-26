import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/models/models.dart';
import '../common/common_widgets.dart';

/// 풋살 반쪽 구장 (세로, 아래쪽이 자기 골대 — SPEC §7.1, §8.4).
class HalfCourtPainter extends CustomPainter {
  const HalfCourtPainter({this.tint});

  /// 팀 색을 아주 옅게 섞는다.
  final Color? tint;

  static const grass = Color(0xFF2E7D45);
  static const grassDark = Color(0xFF29703E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final clip = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.save();
    canvas.clipRRect(clip);

    // 잔디 줄무늬
    canvas.drawRect(rect, Paint()..color = grass);
    final stripe = Paint()..color = grassDark;
    for (var i = 0; i < 6; i += 2) {
      canvas.drawRect(Rect.fromLTWH(0, h * i / 6, w, h / 6), stripe);
    }
    if (tint != null) {
      canvas.drawRect(rect, Paint()..color = tint!.withValues(alpha: 0.10));
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w / 120);
    final inset = w * 0.04;
    final field = Rect.fromLTRB(inset, inset, w - inset, h - inset);
    canvas.drawRect(field, line);

    // 센터라인(위쪽)의 센터서클 반원
    final r = field.width * 0.18;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(field.center.dx, field.top), radius: r),
      0,
      math.pi,
      false,
      line,
    );

    // 페널티 에어리어 (풋살: 골대 앞 D자 모양)
    final boxW = field.width * 0.62;
    final boxH = field.height * 0.24;
    final box = Path()
      ..moveTo(field.center.dx - boxW / 2, field.bottom)
      ..quadraticBezierTo(
        field.center.dx - boxW / 2,
        field.bottom - boxH,
        field.center.dx,
        field.bottom - boxH,
      )
      ..quadraticBezierTo(
        field.center.dx + boxW / 2,
        field.bottom - boxH,
        field.center.dx + boxW / 2,
        field.bottom,
      );
    canvas.drawPath(box, line);
    canvas.drawCircle(
      Offset(field.center.dx, field.bottom - boxH * 0.75),
      line.strokeWidth * 1.2,
      Paint()..color = line.color,
    );

    // 골대
    final goalW = field.width * 0.22;
    canvas.drawRect(
      Rect.fromLTWH(
        field.center.dx - goalW / 2,
        field.bottom,
        goalW,
        inset * 0.8,
      ),
      line,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(HalfCourtPainter old) => old.tint != tint;
}

/// 포지션 원 (SPEC §8.4). 선수가 없으면 점선 + 포지션 이름.
class PositionCircle extends StatelessWidget {
  const PositionCircle({
    super.key,
    required this.slot,
    required this.size,
    required this.teamColor,
    this.player,
    this.showOvr = true,
    this.offPosition = false,
    this.keeperMark,
    this.borrowed = false,
  });

  final Slot slot;
  final double size;
  final Color teamColor;
  final Player? player;
  final bool showOvr;
  final bool offPosition;

  /// GK 자리 표시: 🔄 시작 키퍼 / 🧤 고정 키퍼.
  final String? keeperMark;

  /// 부족 팀의 빈 자리 ("+1 빌려오기").
  final bool borrowed;

  static Color slotColor(Slot slot) =>
      slot.isKeeper ? const Color(0xFFE0B000) : positionColor(slot.position!);

  @override
  Widget build(BuildContext context) {
    final p = player;
    if (p == null) return _empty(context);
    final name = shortName(p.displayName);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: teamColor, width: size * 0.08),
              boxShadow: const [
                BoxShadow(color: Color(0x55000000), blurRadius: 4),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: size * 0.24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
                if (showOvr)
                  Text(
                    p.stats.ovr.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: size * 0.18,
                      color: Colors.black54,
                      height: 1.1,
                    ),
                  ),
              ],
            ),
          ),
          if (keeperMark != null)
            Positioned(
              left: -size * 0.12,
              top: -size * 0.12,
              child: Text(keeperMark!, style: TextStyle(fontSize: size * 0.3)),
            ),
          if (offPosition)
            Positioned(
              right: -size * 0.1,
              top: -size * 0.1,
              child: Tooltip(
                message: '선호 포지션이 아닌 자리',
                child: CircleAvatar(
                  radius: size * 0.16,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.swap_horiz,
                    size: size * 0.22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final color = slotColor(slot);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        child: Container(
          margin: EdgeInsets.all(size * 0.06),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: borrowed ? 0.25 : 0.45),
          ),
          alignment: Alignment.center,
          child: Text(
            borrowed ? '+1' : slot.label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * (borrowed ? 0.3 : 0.24),
            ),
          ),
        ),
      ),
    );
  }

  /// 원 안에 들어갈 이름: 최대 4글자 (SPEC §8.4).
  static String shortName(String name) =>
      name.characters.length <= 4 ? name : name.characters.take(4).toString();
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width / 28);
    final r = size.width / 2 - paint.strokeWidth;
    const dashes = 16;
    for (var i = 0; i < dashes; i++) {
      final start = 2 * math.pi * i / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: size.center(Offset.zero), radius: r),
        start,
        math.pi / dashes,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
