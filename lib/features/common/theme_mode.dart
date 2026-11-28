import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/providers.dart';
import '../../data/repositories/device_repository.dart';

/// 화면 모드(밝게/어둡게) 선택이 가능한지 (SPEC §8.8).
/// - 앱(안드로이드): 사용자가 고른다. 처음 값은 밝은 모드.
/// - 웹앱: 밝은 모드로 고정. 화면 확인용 빌드만 `--dart-define=PREVIEW_DARK=true`로 연다.
const bool themeChoiceAvailable =
    !kIsWeb || bool.fromEnvironment('PREVIEW_DARK');

/// 기기 설정 키 (공유되지 않음).
const themeModeKey = 'ui.themeMode';

ThemeMode parseThemeMode(String? value) =>
    value == 'dark' ? ThemeMode.dark : ThemeMode.light;

/// 앱 시작 때 기기에서 읽은 값 (main에서 덮어쓴다). 기본은 밝은 모드.
final initialThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.light);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => themeChoiceAvailable
      ? ref.read(initialThemeModeProvider)
      : ThemeMode.light;

  /// 바꾸고 이 기기에 저장한다.
  Future<void> select(ThemeMode mode) async {
    if (!themeChoiceAvailable) return;
    state = mode;
    await DeviceRepository(ref.read(databaseProvider))
        .set(themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
