import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/db/app_database.dart';
import 'data/providers.dart';
import 'data/repositories/device_repository.dart';
import 'features/invite/invite_actions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SPEC §8: 앱 전체 가로 모드 고정.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final db = AppDatabase.open();
  final deviceId = await DeviceRepository(db).deviceId();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceIdProvider.overrideWithValue(deviceId),
        // 앱이 초대 링크로 열릴 때 (안내 페이지의 [앱에서 열기]).
        incomingLinksProvider.overrideWithValue(
          AppLinks().uriLinkStream.map((uri) => uri.toString()),
        ),
      ],
      child: const FutsalTeamMakerApp(),
    ),
  );
}
