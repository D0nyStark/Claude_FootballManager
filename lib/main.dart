import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/db/app_database.dart';
import 'data/providers.dart';
import 'data/repositories/device_repository.dart';
import 'features/invite/invite_actions.dart';
import 'platform/web_env.dart';

Future<void> main() async {
  // 웹: 주소의 '#' 뒤를 라우팅에 쓰지 않는다 (초대 묶음이 거기 실려 온다).
  final webInvite = kIsWeb ? takeInitialInvite() : null;
  if (kIsWeb) usePathUrlStrategy();
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
        // 앱이 초대 링크로 열릴 때 (안내 페이지의 [앱에서 열기] / [웹앱에서 열기]).
        incomingLinksProvider.overrideWithValue(
          kIsWeb
              ? (webInvite == null
                    ? const Stream<String>.empty()
                    : Stream.value(webInvite))
              : AppLinks().uriLinkStream.map((uri) => uri.toString()),
        ),
      ],
      child: const FutsalTeamMakerApp(),
    ),
  );
}
