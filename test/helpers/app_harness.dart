import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/app.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/providers.dart';
import 'package:material_ui/material_ui.dart';

/// 가로 폰 (800×360dp).
const landscapePhone = Size(800, 360);

/// 메모리 DB로 앱을 띄운다. 테스트가 끝나면 DB를 닫는다.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  AppDatabase? db,
  Widget? home,
  Size size = landscapePhone,
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final database = db ?? AppDatabase(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        deviceIdProvider.overrideWithValue('test-device'),
      ],
      child: home == null
          ? const FutsalTeamMakerApp(autoEnterSingleGroup: false)
          : MaterialApp(home: home),
    ),
  );
  await settle(tester);
  addTearDown(() async {
    // 스트림 구독을 먼저 정리한 뒤 DB를 닫는다.
    // 테스트의 가짜 시간 안에서 close()를 기다리면 멈추므로 기다리지 않는다.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    unawaited(database.close());
  });
  return database;
}

/// DB 비동기 작업과 애니메이션이 끝날 때까지 기다린다.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  // 입력창 포커스가 남아 있으면 스크롤이 입력창 쪽으로 되돌아간다.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await settle(tester);
}

/// 테스트 본문에서 DB를 직접 읽고 쓸 때 사용 (가짜 시간 밖에서 실행).
Future<T> io<T>(WidgetTester tester, Future<T> Function() action) async =>
    (await tester.runAsync(action)) as T;
