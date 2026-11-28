import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/data/repositories/device_repository.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/features/common/theme_mode.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

ThemeMode appMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

void main() {
  testWidgets('화면 모드: 기본 밝게 → Settings에서 어둡게 → 이 기기에 저장', (tester) async {
    final db = await pumpApp(tester);
    expect(appMode(tester), ThemeMode.light);
    await io(
      tester,
      () => GroupRepository(db).createGroup(name: 'G', onboardingStep: 4),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('⚽ G'));
    await tapAndSettle(tester, find.byTooltip('설정'));
    await tapAndSettle(tester, find.text('어둡게'));
    expect(appMode(tester), ThemeMode.dark);
    expect(
      await io(tester, () => DeviceRepository(db).get(themeModeKey)),
      'dark',
    );
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.text('밝게'));
    expect(appMode(tester), ThemeMode.light);
  });

  test('저장값 읽기: dark만 어둡게, 나머지는 밝게', () {
    expect(parseThemeMode('dark'), ThemeMode.dark);
    expect(parseThemeMode('light'), ThemeMode.light);
    expect(parseThemeMode(null), ThemeMode.light);
  });
}
