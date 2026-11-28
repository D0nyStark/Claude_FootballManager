import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/app.dart';
import 'package:futsalteammaker/core/balancer/balancer.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:futsalteammaker/features/tutorial/tutorial.dart';
import 'package:futsalteammaker/features/share/share_service.dart';
import 'package:futsalteammaker/features/invite/invite_actions.dart';

/// 공유 시트·클립보드 대신 기록만 한다.
class FakeShareService extends ShareService {
  final List<String> texts = [];
  final List<(String, List<int>)> files = [];
  int images = 0;

  @override
  Future<void> copyText(String text) async => texts.add(text);

  @override
  Future<void> shareText(String text) async => texts.add(text);

  @override
  Future<void> shareImage(List<int> png, {String? text}) async => images++;

  @override
  Future<void> shareFile(List<int> bytes, String fileName) async =>
      files.add((fileName, bytes));
}

/// 테스트마다 새로 만든다 ([pumpApp]이 초기화).
FakeShareService fakeShare = FakeShareService();

/// 앱 시작 때 읽히는 클립보드 내용 (설치 직후 초대 감지 테스트용).
String? fakeClipboard;

/// 다음 [pumpApp] 한 번에만 쓸 클립보드 내용.
String? fakeClipboardNext;

/// 가로 폰 (800×360dp).
const landscapePhone = Size(800, 360);

/// 메모리 DB로 앱을 띄운다. 테스트가 끝나면 DB를 닫는다.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  AppDatabase? db,
  Widget? home,
  Size size = landscapePhone,
  bool tutorials = false,
  List<Override> overrides = const [],
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  fakeShare = FakeShareService();
  fakeClipboard = fakeClipboardNext;
  fakeClipboardNext = null;
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final database = db ?? AppDatabase(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      // 한 테스트에서 앱을 다시 띄울 때(다른 기기 흉내) 새 범위를 쓴다.
      key: UniqueKey(),
      overrides: [
        databaseProvider.overrideWithValue(database),
        deviceIdProvider.overrideWithValue('test-device'),
        tutorialEnabledProvider.overrideWithValue(tutorials),
        shareServiceProvider.overrideWithValue(fakeShare),
        clipboardTextProvider.overrideWithValue(() async => fakeClipboard),
        ...overrides,
        // 테스트에서는 isolate 없이 바로 계산 (가짜 시간과 충돌 방지).
        balancerRunnerProvider.overrideWithValue(
          (request) async => const TeamBalancer().balance(request),
        ),
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

/// [finder]가 화면에 나올 때까지 실제 비동기 작업(DB·스트림)을 조금씩 흘려보내며 기다린다.
///
/// [settle]은 고정 횟수만 기다려서, DB 작업이 여러 단계 이어지는 곳(초대 → 공유 시각 저장 →
/// 변경 건수 다시 세기)에서는 테스트를 병렬로 돌려 바쁠 때 가끔 덜 끝난 화면을 확인했다.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  int rounds = 50,
}) async {
  for (var i = 0; i < rounds && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
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

/// 모임 홈에서 [풋살] 시작 (팀 인원은 이후 팀 설정에서 고른다).
Future<void> startFutsal(WidgetTester tester) =>
    tapAndSettle(tester, find.byKey(const Key('modeFutsal')));

/// 인원 스테퍼(−/+)를 눌러 [n] vs [n]으로 맞춘다 (팀 설정·마법사·모임 설정 공통).
Future<void> setFormat(WidgetTester tester, int n) async {
  for (var i = 0; i < 6; i++) {
    final now = tester.widget<Text>(find.byKey(const Key('formatValue'))).data!;
    final cur = int.parse(now.split(' ').first);
    if (cur == n) return;
    await tapAndSettle(
      tester,
      find.byKey(Key(cur < n ? 'formatUp' : 'formatDown')),
    );
  }
}
