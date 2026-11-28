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
    // 세 가지 바탕: 사진 위([dark]) / 밝은 화면(흰 배경) / 어두운 화면(다크 모드).
    final darkTheme = Theme.of(context).brightness == Brightness.dark;
    final base = tint ?? Colors.white;
    final double topA, bottomA, edgeA, shadowA;
    if (tint != null) {
      (topA, bottomA, edgeA, shadowA) = (0.62, 0.42, 0.42, 0.22);
    } else if (dark) {
      (topA, bottomA, edgeA, shadowA) = (0.22, 0.08, 0.42, 0.22);
    } else if (darkTheme) {
      // 다크 모드: 흰색을 아주 옅게 — 글자(밝은색)가 잘 읽히게.
      (topA, bottomA, edgeA, shadowA) = (0.08, 0.03, 0.14, 0.35);
    } else {
      (topA, bottomA, edgeA, shadowA) = (0.66, 0.34, 0.85, 0.10);
    }
    final fillTop = base.withValues(alpha: topA);
    final fillBottom = base.withValues(alpha: bottomA);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowA),
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
                // 밝은 화면(흰 배경)만 포인트색 테두리, 나머지는 흰색.
                color: !dark && !darkTheme && tint == null
                    ? AppColors.point.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: edgeA),
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
                            fontWeight: FontWeight.w400,
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

/// 홈을 뺀 화면의 본문을 유리 패널 하나에 담는다 (SPEC §8.8).
/// 키보드가 올라오면(가로 화면에서 높이가 모자람) 여백·모서리·그림자를 없앤다.
/// Scaffold 본문 안에서는 MediaQuery의 키보드 높이가 0이라 화면(View)에서 직접 읽는다.
class GlassBody extends StatelessWidget {
  const GlassBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 12),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final keyboard = View.of(context).viewInsets.bottom > 0;
    return Padding(
      padding: keyboard ? EdgeInsets.zero : padding,
      child: Glass(radius: keyboard ? 0 : 20, shadow: !keyboard, child: child),
    );
  }
}
