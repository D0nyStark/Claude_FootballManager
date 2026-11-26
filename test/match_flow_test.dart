import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:futsalteammaker/data/repositories/session_repository.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

import 'package:futsalteammaker/features/pitch/half_court.dart';

const coreNames = ['김철수', '이영희', '박민수', '최지훈'];
const regularNames = [
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

/// 주멤버 4명 + 일반멤버 9명 모임을 만들고 들어간다.
Future<(AppDatabase, String)> enterGroup(WidgetTester tester) async {
  final db = await pumpApp(tester);
  final id = await io(
    tester,
    () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
  );
  final repo = PlayerRepository(db, 'x');
  final ids = await io(
    tester,
    () => repo.addPlayersByName(id, [...coreNames, ...regularNames]),
  );
  final players = await io(tester, () => repo.players(id));
  for (var i = 0; i < players.length; i++) {
    final p = players[i];
    await io(
      tester,
      () => repo.savePlayer(
        id,
        p.copyWith(
          memberType: i < coreNames.length
              ? MemberType.core
              : MemberType.regular,
          mainPosition: Position.values[i % 3],
          stats: PlayerStats.uniform(1 + i % 5),
          canKeep: i == 0 || i == 5,
        ),
      ),
    );
  }
  expect(ids, hasLength(13));
  await settle(tester);
  await tapAndSettle(tester, find.text('⚽ 수요풋살'));
  return (db, id);
}

/// 검색창에 이름을 넣어 찾은 뒤 체크 (목록 아래쪽 선수도 고를 수 있게).
/// 선수가 들어간 포지션 원 수.
int placedCircles() => find
    .byType(PositionCircle)
    .evaluate()
    .where((e) => (e.widget as PositionCircle).player != null)
    .length;

Future<void> tapPlayer(WidgetTester tester, String name) async {
  final search = find.widgetWithText(TextField, '선수 검색');
  await tester.enterText(search, name);
  await settle(tester);
  await tapAndSettle(tester, find.widgetWithText(CheckboxListTile, name));
  await tester.enterText(search, '');
  await settle(tester);
}

void main() {
  testWidgets('게스트 추가: 가로 화면 키보드가 올라와도 이름 칸과 추가 버튼이 보인다', (tester) async {
    await enterGroup(tester);
    await tapAndSettle(tester, find.text('5 vs 5'));
    await tapAndSettle(tester, find.text('게스트'));
    // 360dp 중 키보드가 200dp를 차지한 상태.
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pumpAndSettle();
    final visible = Offset.zero & const Size(800, 160);
    for (final f in [
      find.byKey(const Key('guestName')),
      find.widgetWithText(FilledButton, '추가'),
      find.widgetWithText(TextButton, '취소'),
    ]) {
      expect(visible.contains(tester.getCenter(f)), isTrue, reason: '$f');
    }
    await tester.enterText(find.byKey(const Key('guestName')), '용병');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, '추가'));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(find.text('용병 (게스트)'), findsOneWidget);
  });

  testWidgets('6vs6 → 주멤버 전체 선택 + 일반멤버 + 게스트 → 3팀 → 팀 짜기 결과', (tester) async {
    await enterGroup(tester);
    await tapAndSettle(tester, find.text('6 vs 6'));
    expect(find.text('출전 덱 · 6 vs 6'), findsOneWidget);

    await tapAndSettle(tester, find.text('전체 선택'));
    expect(find.text('출전 4명'), findsOneWidget);
    expect(find.text('전체 해제'), findsOneWidget);
    for (final name in regularNames.take(8)) {
      await tapPlayer(tester, name);
    }
    expect(find.text('출전 12명'), findsOneWidget);

    // 게스트 추가 (저장 안 함)
    await tapAndSettle(tester, find.text('게스트'));
    await tester.enterText(find.byKey(const Key('guestName')), '용병');
    await tapAndSettle(tester, find.byKey(const ValueKey('score-4')).last);
    await tapAndSettle(tester, find.text('추가'));
    expect(find.text('출전 13명'), findsOneWidget);
    expect(find.text('용병 (게스트)'), findsOneWidget);

    await tapAndSettle(tester, find.text('다음 →'));
    expect(find.text('팀 설정 · 출전 13명'), findsOneWidget);
    expect(find.text('13명 → 7 · 6'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('팀 늘리기'));
    expect(tester.widget<Text>(find.byKey(const Key('teamCount'))).data, '3');
    expect(find.text('13명 → 5 · 4 · 4'), findsOneWidget);
    expect(find.textContaining('많이 부족해요'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('팀 줄이기'));
    expect(find.text('13명 → 7 · 6'), findsOneWidget);
    expect(find.text('팀별 후보 총 1명'), findsOneWidget);
    expect(find.textContaining('부족한 팀'), findsNothing);

    await tapAndSettle(tester, find.byKey(const Key('makeTeams')));

    // 구장 화면: 배치 전에는 빈 포지션 원만 (2팀 × 6자리)
    expect(find.textContaining('자동 편성을 눌러'), findsOneWidget);
    expect(find.byKey(const Key('balanceScore')), findsNothing);
    expect(placedCircles(), 0);
    expect(find.byType(PositionCircle), findsNWidgets(12));

    await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
    expect(find.byKey(const Key('balanceScore')), findsOneWidget);
    expect(find.textContaining('🔴 레드'), findsOneWidget);
    expect(find.textContaining('🔵 블루'), findsOneWidget);
    expect(placedCircles(), 12); // 선발 6 + 6
    expect(find.byType(Chip), findsOneWidget); // 7명 팀의 후보 1명
    expect(find.text('+1'), findsNothing); // 6명 팀은 정원
    expect(find.text('🔄'), findsNWidgets(2)); // 팀별 시작 키퍼

    await tapAndSettle(tester, find.byKey(const Key('shuffle')));
    expect(find.byKey(const Key('balanceScore')), findsOneWidget);
    expect(placedCircles(), 12);
  });

  testWidgets('작성 중인 덱은 나갔다 와도 남아 있다 (형식은 새로 고른 것)', (tester) async {
    final (db, id) = await enterGroup(tester);
    await tapAndSettle(tester, find.text('6 vs 6'));
    await tapPlayer(tester, '김철수');
    await tapPlayer(tester, '정다은');
    expect(find.text('출전 2명'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Back'));

    await tapAndSettle(tester, find.text('5 vs 5'));
    expect(find.text('출전 덱 · 5 vs 5'), findsOneWidget);
    expect(find.text('출전 2명'), findsOneWidget);
    final saved = await io(tester, () => SessionRepository(db).load(id));
    expect(saved!.deckIds, hasLength(2));
    expect(saved.format, MatchFormat.fiveVsFive);
  });

  testWidgets('키퍼 고정: 자동 배정 → 결과에 고정 키퍼 표시', (tester) async {
    await enterGroup(tester);
    await tapAndSettle(tester, find.text('5 vs 5'));
    await tapAndSettle(tester, find.text('전체 선택'));
    for (final name in regularNames.take(6)) {
      await tapPlayer(tester, name);
    }
    await tapAndSettle(tester, find.text('다음 →'));
    await tapAndSettle(tester, find.text('키퍼 고정'));
    await tapAndSettle(tester, find.textContaining('자동 배정'));
    // 키퍼 가능 선수: 김철수(주멤버), 한상우(일반)
    expect(find.text('🧤 김철수'), findsWidgets);
    expect(find.text('🧤 한상우'), findsWidgets);

    await tapAndSettle(tester, find.byKey(const Key('makeTeams')));
    await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
    // 고정 키퍼가 각 팀 GK 원에 🧤 표시로 들어간다.
    expect(find.text('🧤'), findsNWidgets(2));
    final keepers = [
      for (final c in tester.widgetList<PositionCircle>(
        find.byType(PositionCircle),
      ))
        if (c.slot == Slot.gk) c.player?.name,
    ];
    expect(keepers.toSet(), {'김철수', '한상우'});
  });

  testWidgets('당일 조건 추가', (tester) async {
    await enterGroup(tester);
    await tapAndSettle(tester, find.text('5 vs 5'));
    await tapAndSettle(tester, find.text('전체 선택'));
    await tapPlayer(tester, '정다은');
    await tapAndSettle(tester, find.text('다음 →'));
    await tapAndSettle(tester, find.text('추가'));
    await tapAndSettle(tester, find.text('항상 다른 팀'));
    await tapAndSettle(tester, find.widgetWithText(FilterChip, '김철수'));
    await tapAndSettle(tester, find.widgetWithText(FilterChip, '이영희'));
    await tapAndSettle(tester, find.widgetWithText(FilledButton, '추가'));
    expect(find.text('김철수, 이영희'), findsOneWidget);
  });

  testWidgets('17명 · 6vs6 · 3팀: 부족 팀에 "+1" 자리, 4팀까지 한 화면', (tester) async {
    await enterGroup(tester);
    await tapAndSettle(tester, find.text('6 vs 6'));
    await tapAndSettle(tester, find.text('전체 선택'));
    for (final name in regularNames) {
      await tapPlayer(tester, name);
    }
    for (final guest in ['용병1', '용병2', '용병3', '용병4']) {
      await tapAndSettle(tester, find.text('게스트'));
      await tester.enterText(find.byKey(const Key('guestName')), guest);
      await tapAndSettle(tester, find.text('추가'));
    }
    expect(find.text('출전 17명'), findsOneWidget);
    await tapAndSettle(tester, find.text('다음 →'));
    await tapAndSettle(tester, find.byTooltip('팀 늘리기'));
    expect(find.text('17명 → 6 · 6 · 5'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('makeTeams')));
    expect(find.byType(PositionCircle), findsNWidgets(18));
    await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
    expect(placedCircles(), 17);
    expect(find.text('+1'), findsOneWidget);
  });
}
