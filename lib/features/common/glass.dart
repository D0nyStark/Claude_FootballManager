import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// 앱 색 (포인트 컬러: 시안 이미지의 평균색 #3B6A41).
abstract final class AppColors {
  static const point = Color(0xFF3B6A41);
  static const pointLight = Color(0xFF63A06E);
  static const pointDark = Color(0xFF1F3B22);
}

/// 유리(glassmorphism) 면: 뒤 배경을 흐리게(blur) 비추는 반투명 면 + 얇은 밝은 테두리.
/// [dark]면 사진 위(어두운 배경)용, 아니면 밝은 그라데이션 배경용.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 16,
    this.blur = 18,
    this.dark = false,
    this.tint,
    this.padding,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final double blur;
  final bool dark;

  /// 면에 섞을 색 (선택된 버튼 등).
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final base = tint ?? Colors.white;
    final fillTop = base.withValues(
      alpha: tint != null ? 0.62 : (dark ? 0.22 : 0.66),
    );
    final fillBottom = base.withValues(
      alpha: tint != null ? 0.42 : (dark ? 0.08 : 0.34),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.22 : 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fillTop, fillBottom],
              ),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.42)
                    : AppColors.point.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: padding == null
                ? child
                : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}

/// 유리 버튼 (홈 등 사진 위). Material 규칙대로 최소 48dp, 모서리는 완전 둥근 stadium.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.big = false,
    this.caption,
    this.dimmed = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool big;

  /// 큰 버튼 아래 작은 글씨 (예: "준비 중").
  final String? caption;

  /// 아직 쓸 수 없는 기능: 흐리게.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final h = big ? 96.0 : 48.0;
    final button = Glass(
      radius: h / 2,
      dark: true,
      tint: primary ? AppColors.point : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(h / 2),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: h, minWidth: big ? 200 : 0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: big ? 24 : 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: big ? 26 : 15,
                          fontWeight: big ? FontWeight.w800 : FontWeight.w600,
                          shadows: const [
                            Shadow(blurRadius: 6, color: Colors.black38),
                          ],
                        ),
                      ),
                      if (caption != null)
                        Text(
                          caption!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return dimmed ? Opacity(opacity: 0.6, child: button) : button;
  }
}

/// 홈을 뺀 화면의 배경: 라이트 모드는 순백(white), 다크 모드는 어두운 포인트 그라데이션.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return ColoredBox(color: Colors.white, child: child);
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102014), Color(0xFF1B3322), Color(0xFF0F1A12)],
        ),
      ),
      child: child,
    );
  }
}
