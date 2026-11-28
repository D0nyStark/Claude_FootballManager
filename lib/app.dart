import 'package:material_ui/material_ui.dart';

import 'features/common/glass.dart';
import 'features/common/web_frame.dart';
import 'features/groups/group_list_page.dart';

/// 풋살 팀메이커 앱 루트.
class FutsalTeamMakerApp extends StatelessWidget {
  const FutsalTeamMakerApp({super.key, this.autoEnterSingleGroup = true});

  /// 모임이 1개뿐이면 바로 들어가기 (테스트에서는 끈다).
  final bool autoEnterSingleGroup;

  static const String title = '풋살 팀메이커';
  static const Color seedColor = AppColors.point;

  /// Material 3 규칙(모서리·크기)을 따르되 면은 반투명 유리 느낌으로.
  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    var scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    scheme = dark
        ? scheme.copyWith(primary: AppColors.pointLight)
        : scheme.copyWith(primary: AppColors.point, onPrimary: Colors.white);
    // 흰 배경 위에서는 흰 유리가 안 보이므로, 밝은 모드의 유리는 포인트색을 살짝 섞는다.
    final glassFill = dark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.point.withValues(alpha: 0.06);
    final glassEdge = dark
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.point.withValues(alpha: 0.22);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Paperlogy',
      // 굵기 계층: 대제목·핵심 숫자 800 / 소제목·주요 버튼 600 / 본문 400 / 부가설명·캡션 300
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w800),
        displayMedium: TextStyle(fontWeight: FontWeight.w800),
        displaySmall: TextStyle(fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontWeight: FontWeight.w600),
        labelLarge: TextStyle(fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontWeight: FontWeight.w400),
        labelSmall: TextStyle(fontWeight: FontWeight.w400),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontWeight: FontWeight.w300),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      // M3: 카드 12~16dp
      cardTheme: CardThemeData(
        color: glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassEdge),
        ),
      ),
      // M3: 버튼은 stadium(완전 둥근), 최소 높이 48
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white.withValues(alpha: dark ? 0.06 : 0.35),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.55)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: const StadiumBorder()),
      ),
      // M3: 대화상자 28dp, 바닥 시트 위쪽 28dp
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: dark ? 0.16 : 0.86),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: glassEdge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white.withValues(alpha: dark ? 0.16 : 0.88),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      // M3: 칩 8dp
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: dark ? 0.08 : 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: glassEdge),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white.withValues(alpha: dark ? 0.08 : 0.5),
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (context, child) =>
          WebFrame(child: AppBackground(child: child!)),
      home: GroupListPage(autoEnterSingleGroup: autoEnterSingleGroup),
    );
  }
}
