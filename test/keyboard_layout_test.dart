import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

/// 가로 폰에서 키보드가 화면 아래 200dp(약 56%)를 덮은 상태.
const keyboardDp = 200.0;

void showKeyboard(WidgetTester tester) {
  tester.view.viewInsets = const FakeViewPadding(bottom: keyboardDp * 2);
  addTearDown(tester.view.resetViewInsets);
}

/// 키보드 위 남은 영역 안에 [finder]가 보이는지.
void expectAboveKeyboard(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  expect(
    rect.bottom,
    lessThanOrEqualTo(landscapePhone.height - keyboardDp + 1),
  );
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.height, greaterThan(10));
}

void main() {
  testWidgets('모임 만들기 ①: 키보드가 올라와도 이름 입력창과 [다음]이 보인다', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('새 모임 만들기'));
    showKeyboard(tester);
    await tester.pumpAndSettle();
    final name = find.byType(TextField).first;
    await tester.enterText(name, '수요풋살');
    await tester.pumpAndSettle();
    expectAboveKeyboard(tester, name);
    expectAboveKeyboard(tester, find.text('다음 →'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('선수 명단 ②: 한 명씩 입력하고 완료를 누르면 계속 입력할 수 있다', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('새 모임 만들기'));
    await tester.enterText(find.byType(TextField).first, '수요풋살');
    await tapAndSettle(tester, find.text('다음 →'));

    showKeyboard(tester);
    final single = find.byKey(const Key('rosterSingle'));
    await tester.showKeyboard(single);
    await tester.pumpAndSettle();
    expectAboveKeyboard(tester, single);
    expectAboveKeyboard(tester, find.text('다음 →'));

    for (final n in ['김철수', '이영희', '박민수']) {
      await tester.enterText(single, n);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);
    }
    debugPrint(
      'DBG chips=${find.byType(InputChip).evaluate().length} texts=${find.textContaining('추가할').evaluate().map((e) => (e.widget as Text).data).toList()}',
    );
    expect(find.text('추가할 선수 3명'), findsOneWidget);
    // 포커스가 유지되어 키보드가 닫히지 않는다.
    expect(tester.widget<TextField>(single).focusNode!.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('선수 편집: 키보드가 올라와도 이름 입력창과 [저장]이 보인다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, db: db);
    final id = await io(
      tester,
      () => GroupRepository(db).createGroup(name: 'G', onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(db, 'x').addPlayersByName(id, ['가']),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('⚽ G'));
    await tapAndSettle(tester, find.byTooltip('선수'));
    await tapAndSettle(tester, find.text('가'));

    showKeyboard(tester);
    final name = find.byKey(const Key('playerName'));
    await tester.showKeyboard(name);
    await tester.pumpAndSettle();
    expectAboveKeyboard(tester, name);
    expectAboveKeyboard(tester, find.text('저장됨'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('명단 입력창을 누른 뒤 키보드가 올라와도 포커스가 유지된다', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.text('새 모임 만들기'));
    await tester.enterText(find.byType(TextField).first, '수요풋살');
    await tapAndSettle(tester, find.text('다음 →'));

    // 실제 폰 순서: 입력창 탭(포커스) → 키보드가 올라옴(화면 높이 변화)
    final single = find.byKey(const Key('rosterSingle'));
    await tester.showKeyboard(single);
    await tester.pump();
    showKeyboard(tester);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(single).focusNode!.hasFocus, isTrue);
    await tester.enterText(single, '김철수');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('추가할 선수 1명'), findsOneWidget);
    expectAboveKeyboard(tester, single);

    // 붙여넣기 칸도 같은 순서로
    final paste = find.byKey(const Key('rosterPaste'));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.showKeyboard(paste);
    await tester.pump();
    showKeyboard(tester);
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(
      find.descendant(of: paste, matching: find.byType(EditableText)),
    );
    expect(editable.focusNode.hasFocus, isTrue);
    expectAboveKeyboard(tester, paste);
  });
}
