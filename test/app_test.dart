import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

void main() {
  testWidgets('첫 화면: 앱 이름 · 새 모임 만들기 · 초대 링크로 참여', (tester) async {
    await pumpApp(tester);
    expect(find.text('풋살 팀메이커'), findsOneWidget);
    expect(find.text('새 모임 만들기'), findsOneWidget);
    expect(find.text('초대 링크로 참여'), findsOneWidget);
  });

  testWidgets('생성 마법사 전체: 모임 정보 → 명단 붙여넣기 → 간단 스펙 → 초대 → 모임 홈', (tester) async {
    final db = await pumpApp(tester);
    await tapAndSettle(tester, find.text('새 모임 만들기'));

    // ① 모임 정보
    await tester.enterText(find.byType(TextField).first, '수요풋살');
    await tapAndSettle(tester, find.text('6 vs 6'));
    await tapAndSettle(tester, find.text('다음 →'));

    // ② 선수 명단
    await tester.enterText(
      find.byKey(const Key('rosterPaste')),
      '1. 김철수\n2. 이영희, 박민수',
    );
    await tapAndSettle(tester, find.text('이름 나누기'));
    expect(find.text('추가할 선수 3명'), findsOneWidget);
    await tapAndSettle(tester, find.text('다음 →'));

    // ③ 간단 스펙: 첫 선수 = 주멤버 · 픽소 · 5점
    expect(find.text('김철수'), findsOneWidget);
    await tapAndSettle(tester, find.text('주').first);
    await tapAndSettle(tester, find.text('픽소').first);
    await tapAndSettle(tester, find.byKey(const ValueKey('score-5')).first);
    await tapAndSettle(tester, find.text('다음 →'));

    // ④ 초대 → 완료
    expect(find.text('멤버 초대'), findsOneWidget);
    await tapAndSettle(tester, find.text('완료'));

    expect(find.text('⚽ 수요풋살'), findsOneWidget);
    expect(find.text('오늘 매치는?'), findsOneWidget);
    expect(find.textContaining('설정 마무리하기'), findsNothing);

    final group = (await io(
      tester,
      () => GroupRepository(db).watchGroups().first,
    )).single;
    expect(group.defaultFormat, MatchFormat.sixVsSix);
    expect(group.onboardingDone, isTrue);
    final players = await io(
      tester,
      () => PlayerRepository(db, 'x').players(group.id),
    );
    expect([for (final p in players) p.name], ['김철수', '이영희', '박민수']);
    final kim = players.first;
    expect(kim.memberType, MemberType.core);
    expect(kim.mainPosition, Position.fixo);
    expect(kim.stats, PlayerStats.uniform(5));
    expect(players[1].memberType, MemberType.regular);
  });

  testWidgets('나중에 하기 → 모임 홈에 "설정 마무리하기" 배너 → 이어서 하기', (tester) async {
    final db = await pumpApp(tester);
    await tapAndSettle(tester, find.text('새 모임 만들기'));
    await tester.enterText(find.byType(TextField).first, '주말리그');
    await tapAndSettle(tester, find.text('다음 →'));
    await tapAndSettle(tester, find.text('나중에 하기'));

    expect(find.text('⚽ 주말리그'), findsOneWidget);
    expect(find.text('설정 마무리하기 (1/4)'), findsOneWidget);

    await tapAndSettle(tester, find.text('설정 마무리하기 (1/4)'));
    expect(find.text('모임 설정 마무리'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('rosterSingle')), '홍길동');
    await tapAndSettle(tester, find.text('이름 나누기'));
    await tapAndSettle(tester, find.text('다음 →'));
    await tapAndSettle(tester, find.text('건너뛰기'));
    await tapAndSettle(tester, find.text('완료'));

    final group = (await io(
      tester,
      () => GroupRepository(db).watchGroups().first,
    )).single;
    expect(group.onboardingDone, isTrue);
    expect(group.playerCount, 1);
  });

  testWidgets('모임 목록 → 모임 들어가기 → 선수 탭에서 선수 추가·수정', (tester) async {
    final db = await pumpApp(tester);
    final groups = GroupRepository(db);
    final id = await io(
      tester,
      () => groups.createGroup(name: '수요풋살', onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(db, 'x').addPlayersByName(id, ['김철수']),
    );
    await settle(tester);

    await tapAndSettle(tester, find.text('⚽ 수요풋살'));
    await tapAndSettle(tester, find.text('선수'));
    expect(find.text('⭐ 주멤버 (0)'), findsOneWidget);
    expect(find.text('👤 일반멤버 (1)'), findsOneWidget);
    expect(find.text('간단'), findsOneWidget);

    // 새 선수 추가
    await tapAndSettle(tester, find.byTooltip('선수 추가'));
    await tester.enterText(find.byKey(const Key('playerName')), '이영희');
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.byType(SegmentedButton<MemberType>),
        matching: find.text('주멤버'),
      ),
    );
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.byType(SegmentedButton<Position>),
        matching: find.text('피보'),
      ),
    );
    await tapAndSettle(tester, find.text('추가'));
    expect(find.text('⭐ 주멤버 (1)'), findsOneWidget);

    // 세부 능력치 수정 → 간단 배지 사라짐
    await tapAndSettle(tester, find.text('김철수'));
    await tapAndSettle(
      tester,
      find.byKey(const ValueKey('score-5')).at(1),
    ); // 슈팅 5점
    await tapAndSettle(tester, find.text('저장'));

    final players = await io(
      tester,
      () => PlayerRepository(db, 'x').players(id),
    );
    final lee = players.firstWhere((p) => p.name == '이영희');
    expect(lee.memberType, MemberType.core);
    expect(lee.mainPosition, Position.pivo);
    final kim = players.firstWhere((p) => p.name == '김철수');
    expect(kim.stats[Stat.shooting], 5);
    expect(kim.statsSimple, isFalse);
  });

  testWidgets('멤버 역할에게는 능력치가 보이지 않는다', (tester) async {
    final db = await pumpApp(tester);
    final id = await io(
      tester,
      () => GroupRepository(
        db,
      ).createGroup(name: '초대받은 모임', role: GroupRole.member, onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(db, 'x').addPlayersByName(id, ['김철수']),
    );
    await settle(tester);

    await tapAndSettle(tester, find.text('⚽ 초대받은 모임'));
    await tapAndSettle(tester, find.text('선수'));
    expect(find.text('3.0'), findsNothing); // 목록 OVR
    await tapAndSettle(tester, find.text('김철수'));
    expect(find.text('능력치'), findsNothing);
    expect(find.text('키퍼 가능 🧤'), findsOneWidget);
  });

  testWidgets('상시 제약 추가', (tester) async {
    final db = await pumpApp(tester);
    final id = await io(
      tester,
      () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(db, 'x').addPlayersByName(id, ['김철수', '이영희']),
    );
    await settle(tester);

    await tapAndSettle(tester, find.text('⚽ 수요풋살'));
    await tapAndSettle(tester, find.text('선수'));
    await tapAndSettle(tester, find.text('같은 팀/다른 팀'));
    await tapAndSettle(tester, find.text('제약 추가'));
    await tapAndSettle(tester, find.text('항상 다른 팀'));
    await tapAndSettle(tester, find.widgetWithText(FilterChip, '김철수'));
    await tapAndSettle(tester, find.widgetWithText(FilterChip, '이영희'));
    await tapAndSettle(tester, find.text('추가'));

    expect(find.text('김철수, 이영희'), findsOneWidget);
    final list = await io(
      tester,
      () => PlayerRepository(db, 'x').watchConstraints(id).first,
    );
    expect(list.single.type, ConstraintType.apart);
  });
}
