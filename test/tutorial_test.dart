import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/device_repository.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

final bubble = find.byKey(const Key('coachBubble'));

/// 튜토리얼은 화면 전환이 끝난 뒤(약 0.35초) 뜬다.
Future<void> waitForTutorial(WidgetTester tester) async {
  await settle(tester);
  await tester.pump(const Duration(milliseconds: 400));
  await settle(tester);
}

/// 모임 하나가 이미 있는 상태로 앱을 띄운다.
Future<AppDatabase> pumpWithGroup(WidgetTester tester) async {
  final db = AppDatabase(NativeDatabase.memory());
  await tester.runAsync(
    () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
  );
  return pumpApp(tester, db: db, tutorials: true);
}

void main() {
  testWidgets('처음 실행: 모임 목록 말풍선 → 다음 → 완료 → 다시 뜨지 않음', (tester) async {
    final db = await pumpApp(tester, tutorials: true);
    await waitForTutorial(tester);

    expect(bubble, findsOneWidget);
    expect(find.text('모임 만들기'), findsOneWidget);
    // 모임이 없으면 "모임 카드" 단계는 건너뛴다 → 2단계.
    expect(find.text('1/2'), findsOneWidget);

    await tapAndSettle(tester, find.text('다음'));
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('이전'), findsOneWidget);
    await tapAndSettle(tester, find.text('완료'));
    expect(bubble, findsNothing);

    final done = await io(
      tester,
      () => DeviceRepository(db).get('tutorial.groupList'),
    );
    expect(done, '1');
  });

  testWidgets('어두운 곳을 탭해도 다음 단계로 넘어간다', (tester) async {
    await pumpApp(tester, tutorials: true);
    await waitForTutorial(tester);
    expect(find.text('1/2'), findsOneWidget);
    await tester.tapAt(const Offset(780, 340));
    await settle(tester);
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('모두 건너뛰기 → 다른 화면에서도 뜨지 않음', (tester) async {
    await pumpWithGroup(tester);
    await waitForTutorial(tester);
    expect(find.text('1/3'), findsOneWidget); // 모임 카드 단계 포함

    await tapAndSettle(tester, find.text('모두 건너뛰기'));
    expect(bubble, findsNothing);

    await tapAndSettle(tester, find.text('⚽ 수요풋살'));
    await waitForTutorial(tester);
    expect(bubble, findsNothing);
  });

  testWidgets('모임 홈 튜토리얼 → 설정의 "사용법 다시 보기"로 다시 보기', (tester) async {
    final db = await pumpWithGroup(tester);
    await waitForTutorial(tester);
    await tapAndSettle(tester, find.text('모두 건너뛰기'));
    await io(tester, () => DeviceRepository(db).removePrefix('tutorial.'));

    await tapAndSettle(tester, find.text('⚽ 수요풋살'));
    await waitForTutorial(tester);
    expect(find.text('오늘 매치 시작'), findsOneWidget);
    // 마무리 배너가 없는 모임 → 홈 6단계 (형식·선수·설정·초대·변경 공유·모임 목록)
    expect(find.text('1/6'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tapAndSettle(tester, find.text('다음'));
    }
    await tapAndSettle(tester, find.text('완료'));

    // 설정 → 사용법 다시 보기
    await tapAndSettle(tester, find.byTooltip('설정'));
    await tapAndSettle(tester, find.text('사용법 다시 보기'));
    expect(
      await io(tester, () => DeviceRepository(db).get('tutorial.groupHome')),
      isNull,
    );
  });
}
