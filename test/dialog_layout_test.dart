import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

const names = [
  '김철수',
  '이영희',
  '박민수',
  '최지훈',
  '정다은',
  '한상우',
  '오세진',
  '윤하늘',
  '강민재',
  '서지우',
  '임도현',
  '조은비',
  '백승호',
  '심용보',
  '안수길',
];

Future<void> openConstraintDialog(WidgetTester tester) async {
  final db = AppDatabase(NativeDatabase.memory());
  await pumpApp(tester, db: db);
  final id = await io(
    tester,
    () => GroupRepository(db).createGroup(name: 'G', onboardingStep: 4),
  );
  await io(tester, () => PlayerRepository(db, 'x').addPlayersByName(id, names));
  await settle(tester);
  await tapAndSettle(tester, find.text('⚽ G'));
  await tapAndSettle(tester, find.text('선수'));
  await tapAndSettle(tester, find.text('같은 팀/다른 팀'));
  await tapAndSettle(tester, find.text('제약 추가'));
}

void main() {
  testWidgets('제약 추가 창: 가로 폰에서 선수 고르는 영역이 넉넉하다', (tester) async {
    await openConstraintDialog(tester);
    final chips = find.byType(FilterChip);
    final scroll = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(SingleChildScrollView),
    );
    final area = tester.getRect(scroll);
    // 화면 높이 360dp 중 선수 영역이 절반 이상
    expect(area.height, greaterThanOrEqualTo(180));
    // 15명 모두 스크롤 없이 한 번에 보인다
    for (final e in chips.evaluate()) {
      final r = tester.getRect(find.byWidget(e.widget));
      expect(area.top <= r.top && r.bottom <= area.bottom, isTrue);
    }
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.widgetWithText(FilterChip, '김철수'));
    await tapAndSettle(tester, find.widgetWithText(FilterChip, '이영희'));
    expect(find.text('2명 선택 · 2명 이상 고르세요.'), findsOneWidget);
    await tapAndSettle(tester, find.text('추가'));
    expect(find.text('김철수, 이영희'), findsOneWidget);
  });
}
