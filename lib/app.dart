import 'package:material_ui/material_ui.dart';

import 'features/groups/group_list_page.dart';

/// 풋살 팀메이커 앱 루트.
class FutsalTeamMakerApp extends StatelessWidget {
  const FutsalTeamMakerApp({super.key});

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
      home: const GroupListPage(),
    );
  }
}
