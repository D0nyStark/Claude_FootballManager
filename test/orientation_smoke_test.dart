import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

const portraitPhone = Size(360, 780);

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
];

void check(WidgetTester tester, String where) {
  final e = tester.takeException();
  expect(e, isNull, reason: '$where: $e');
}

/// 모든 주요 화면을 한 번씩 지나간다. 화면이 넘치면(overflow) 테스트가 실패한다.
Future<void> walkAllScreens(WidgetTester tester, Size size) async {
  final db = await pumpApp(tester, size: size);
  final id = await io(
    tester,
    () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
  );
  final repo = PlayerRepository(db, 'x');
  await io(tester, () => repo.addPlayersByName(id, names));
  final players = await io(tester, () => repo.players(id));
  for (var i = 0; i < players.length; i++) {
    await io(
      tester,
      () => repo.savePlayer(
        id,
        players[i].copyWith(
          memberType: i < 6 ? MemberType.core : MemberType.regular,
          mainPosition: Position.values[i % 3],
          stats: PlayerStats.uniform(1 + i % 5),
          canKeep: i % 4 == 0,
        ),
      ),
    );
  }
  await settle(tester);

  // [A] 모임 목록 → [B] 마법사 1단계 둘러보고 돌아오기
  await tapAndSettle(tester, find.text('새 모임 만들기'));
  expect(find.text('모임 정보'), findsWidgets);
  check(tester, '[B] 마법사');
  await tester.pageBack();
  await settle(tester);

  // [C] 홈
  await tapAndSettle(tester, find.text('⚽ 수요풋살'));
  expect(find.text("Today's Match"), findsOneWidget);
  check(tester, '[C] 홈');

  // [C2] 선수 관리 → 선수 선택(편집 폼)
  await tapAndSettle(tester, find.byTooltip('선수'));
  expect(find.text('선수 관리'), findsOneWidget);
  await tapAndSettle(tester, find.text('김철수').first);
  expect(find.byKey(const Key('playerName')), findsOneWidget);
  check(tester, '[C2] 편집 폼');
  // 같은 팀/다른 팀 탭
  await tester.pageBack();
  await settle(tester);
  if (find.text('같은 팀/다른 팀').evaluate().isEmpty) {
    await tapAndSettle(tester, find.byTooltip('선수'));
  }
  await tapAndSettle(tester, find.text('같은 팀/다른 팀'));
  await tapAndSettle(tester, find.text('제약 추가'));
  check(tester, '[C2] 제약 창');
  await tapAndSettle(tester, find.text('취소'));
  await tester.pageBack();
  await settle(tester);

  // [C3] Settings (끝까지 스크롤)
  await tapAndSettle(tester, find.byTooltip('설정'));
  expect(find.text('Settings'), findsOneWidget);
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
  await settle(tester);
  check(tester, '[C3] Settings');
  await tester.pageBack();
  await settle(tester);

  // [D] 출전 덱 → 게스트 창
  await startFutsal(tester);
  final selectAll = find.text('전체 선택');
  if (selectAll.evaluate().isNotEmpty) {
    await tapAndSettle(tester, selectAll.first);
  }
  final search = find.widgetWithText(TextField, '선수 검색');
  for (final n in names.skip(6).take(5)) {
    await tester.enterText(search, n);
    await settle(tester);
    await tapAndSettle(tester, find.widgetWithText(CheckboxListTile, n));
  }
  await tester.enterText(search, '');
  await settle(tester);
  await tapAndSettle(tester, find.text('게스트'));
  check(tester, '[D] 덱+게스트 창');
  await tester.enterText(find.byKey(const Key('guestName')), '용병');
  await tapAndSettle(tester, find.widgetWithText(FilledButton, '추가'));

  // [E] 팀 설정 → [F] 구장
  await tapAndSettle(tester, find.text('다음 →'));
  check(tester, '[E] 팀 설정');
  await tapAndSettle(tester, find.byKey(const Key('makeTeams')));
  check(tester, '[F] 구장(편성 전)');
  await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
  await tester.pump(const Duration(seconds: 3));
  await settle(tester);
  expect(find.textContaining('/ 100'), findsWidgets);
  check(tester, '[F] 구장(편성 후)');

  // 확정 → 공유 시트
  await tapAndSettle(tester, find.byKey(const Key('confirm')));
  expect(find.byKey(const Key('copyText')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

/// 생성 마법사 4단계를 끝까지 지나간다.
Future<void> walkWizard(WidgetTester tester, Size size) async {
  await pumpApp(tester, size: size);
  await tapAndSettle(tester, find.text('새 모임 만들기'));
  await tester.enterText(find.byType(TextField).first, '주말리그');
  await setFormat(tester, 6);
  check(tester, '마법사 ①');
  await tapAndSettle(tester, find.text('다음 →'));
  await tester.enterText(
    find.byKey(const Key('rosterPaste')),
    names.join('\n'),
  );
  await tapAndSettle(tester, find.text('이름 나누기'));
  check(tester, '마법사 ②');
  await tapAndSettle(tester, find.text('다음 →'));
  await tapAndSettle(tester, find.text('주').first);
  await tapAndSettle(tester, find.byKey(const ValueKey('score-5')).first);
  check(tester, '마법사 ③');
  await tapAndSettle(tester, find.text('다음 →'));
  expect(find.text('멤버 초대'), findsOneWidget);
  check(tester, '마법사 ④');
  await tapAndSettle(tester, find.text('완료'));
  expect(find.text("Today's Match"), findsOneWidget);
  check(tester, '마법사 → 홈');
}

/// 팀 설정에서 인원을 7vs7, 4vs4로 바꿔 구장을 그려 본다.
Future<void> walkFormats(WidgetTester tester, Size size) async {
  final db = await pumpApp(tester, size: size);
  final id = await io(
    tester,
    () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
  );
  final repo = PlayerRepository(db, 'x');
  await io(tester, () => repo.addPlayersByName(id, names));
  await settle(tester);
  await tapAndSettle(tester, find.text('⚽ 수요풋살'));
  // 축구는 준비 중 안내만
  await tapAndSettle(tester, find.byKey(const Key('modeSoccer')));
  expect(find.textContaining('준비 중'), findsWidgets);
  await startFutsal(tester);
  final search = find.widgetWithText(TextField, '선수 검색');
  for (final n in names.take(14)) {
    await tester.enterText(search, n);
    await settle(tester);
    await tapAndSettle(tester, find.widgetWithText(CheckboxListTile, n));
  }
  await tester.enterText(search, '');
  await settle(tester);
  await tapAndSettle(tester, find.text('다음 →'));
  for (final n in [7, 4]) {
    await setFormat(tester, n);
    expect(find.text('$n vs $n'), findsWidgets);
    check(tester, '팀 설정 $n vs $n');
    await tapAndSettle(tester, find.byKey(const Key('makeTeams')));
    await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(find.textContaining('/ 100'), findsWidgets);
    check(tester, '구장 $n vs $n');
    await tapAndSettle(tester, find.byTooltip('뒤로'));
  }
}

void main() {
  testWidgets('세로: 4vs4·7vs7 구장도 넘치지 않는다 (+ 축구 준비 중)', (tester) async {
    await walkFormats(tester, portraitPhone);
  });

  testWidgets('가로: 4vs4·7vs7 구장도 넘치지 않는다', (tester) async {
    await walkFormats(tester, landscapePhone);
  });

  testWidgets('세로 마법사: 4단계가 넘치지 않는다', (tester) async {
    await walkWizard(tester, portraitPhone);
  });

  testWidgets('가로 마법사: 4단계가 넘치지 않는다', (tester) async {
    await walkWizard(tester, landscapePhone);
  });

  testWidgets('세로 (360×780): 모든 화면이 넘치지 않는다', (tester) async {
    await walkAllScreens(tester, portraitPhone);
  });

  testWidgets('가로 (800×360): 모든 화면이 넘치지 않는다', (tester) async {
    await walkAllScreens(tester, landscapePhone);
  });
}
