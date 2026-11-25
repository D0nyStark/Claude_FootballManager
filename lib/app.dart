import 'package:material_ui/material_ui.dart';

import 'features/groups/group_list_page.dart';

/// 풋살 팀메이커 앱 루트.
class FutsalTeamMakerApp extends StatelessWidget {
  const FutsalTeamMakerApp({super.key, this.autoEnterSingleGroup = true});

  /// 모임이 1개뿐이면 바로 들어가기 (테스트에서는 끈다).
  final bool autoEnterSingleGroup;

  static const String title = '풋살 팀메이커';
  static const Color seedColor = Color(0xFF1B8A3C); // 잔디 초록

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: GroupListPage(autoEnterSingleGroup: autoEnterSingleGroup),
    );
  }
}
