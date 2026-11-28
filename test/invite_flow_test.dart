import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/config.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:futsalteammaker/features/invite/invite_actions.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';

/// 기기 A(모임장): 선수 3명 모임을 만들고 멤버 초대 메시지를 보낸다.
Future<(String message, String groupId)> inviteFromA(
  WidgetTester tester,
) async {
  final db = AppDatabase(NativeDatabase.memory());
  await pumpApp(tester, db: db);
  final id = await io(
    tester,
    () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
  );
  final repo = PlayerRepository(db, 'devA');
  await io(tester, () => repo.addPlayersByName(id, ['김철수', '이영희', '박민수']));
  final kim = (await io(tester, () => repo.players(id))).first;
  await io(
    tester,
    () => repo.savePlayer(id, kim.copyWith(stats: PlayerStats.uniform(5))),
  );
  await settle(tester);
  await tapAndSettle(tester, find.text('⚽ 수요풋살'));
  await tapAndSettle(tester, find.byKey(const Key('invite')));
  await tapAndSettle(tester, find.byKey(const Key('inviteMember')));
  return (fakeShare.texts.single, id);
}

void main() {
  testWidgets('초대 메시지: 안내 페이지 주소 + MUG2 링크, 보낸 뒤 변경 건수 0', (tester) async {
    final (message, _) = await inviteFromA(tester);
    expect(message, contains('[수요풋살] 모임에 초대합니다! (멤버)'));
    expect(message, contains('${AppConfig.inviteBaseUrl}#MUG2:'));
    await waitFor(tester, find.text('변경 공유'));
    expect(find.text('변경 공유'), findsOneWidget); // 공유 직후 → 변경 없음
  });

  testWidgets('기기 B: 링크 붙여넣기로 참여 → 멤버라 능력치가 안 보인다', (tester) async {
    final (message, id) = await inviteFromA(tester);

    final dbB = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, db: dbB);
    await tapAndSettle(tester, find.byKey(const Key('joinByLink')));
    await tester.enterText(find.byKey(const Key('invitePaste')), message);
    await tapAndSettle(tester, find.byKey(const Key('joinSubmit')));
    expect(find.text('"수요풋살" 모임에 참여할까요?\n선수 3명 · 멤버 권한'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('acceptInvite')));
    expect(find.textContaining('모임에 참여했어요'), findsOneWidget);

    final group = (await io(
      tester,
      () => GroupRepository(dbB).watchGroups().first,
    )).single;
    expect(group.role, GroupRole.member);
    // 능력치 데이터는 있다 (편성 계산용) — 화면에서만 숨긴다.
    final kim = (await io(
      tester,
      () => PlayerRepository(dbB, 'x').players(id),
    )).first;
    expect(kim.stats, PlayerStats.uniform(5));

    await tapAndSettle(tester, find.text('⚽ 수요풋살'));
    await tapAndSettle(tester, find.byTooltip('선수'));
    expect(find.text('5.0'), findsNothing);
  });

  testWidgets('설치 직후 첫 실행: 클립보드의 초대를 알아보고 묻는다', (tester) async {
    final (message, _) = await inviteFromA(tester);
    fakeClipboardNext = message;
    await pumpApp(tester, db: AppDatabase(NativeDatabase.memory()));
    expect(find.text('모임 초대'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('acceptInvite')));
    expect(find.text('⚽ 수요풋살'), findsOneWidget);
  });

  testWidgets('앱이 링크로 열리면(futsalteammaker://join?d=…) 바로 처리', (tester) async {
    final (message, _) = await inviteFromA(tester);
    final payload = message.substring(message.indexOf('MUG2:'));
    await pumpApp(
      tester,
      db: AppDatabase(NativeDatabase.memory()),
      overrides: [
        incomingLinksProvider.overrideWithValue(
          Stream.value(
            'futsalteammaker://join?d=${Uri.encodeComponent(payload)}',
          ),
        ),
      ],
    );
    expect(find.text('모임 초대'), findsOneWidget);
  });

  testWidgets('같은 모임 링크를 다시 받으면 변경 사항 미리보기 → 반영', (tester) async {
    final (message, _) = await inviteFromA(tester);
    final dbB = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, db: dbB);
    await tapAndSettle(tester, find.byKey(const Key('joinByLink')));
    await tester.enterText(find.byKey(const Key('invitePaste')), message);
    await tapAndSettle(tester, find.byKey(const Key('joinSubmit')));
    await tapAndSettle(tester, find.byKey(const Key('acceptInvite')));

    await tapAndSettle(tester, find.byKey(const Key('joinByLink')));
    await tester.enterText(find.byKey(const Key('invitePaste')), message);
    await tapAndSettle(tester, find.byKey(const Key('joinSubmit')));
    expect(find.text('"수요풋살" 변경 사항'), findsOneWidget);
    expect(find.text('새로운 변경이 없어요.'), findsOneWidget);
  });

  testWidgets('선수를 고치면 "변경 공유 (N건)" 배지', (tester) async {
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
    await io(tester, () => GroupRepository(db).markShared(id));
    await io(tester, () => Future<void>.delayed(const Duration(seconds: 1)));
    final p = (await io(
      tester,
      () => PlayerRepository(db, 'x').players(id),
    )).first;
    await io(
      tester,
      () => PlayerRepository(db, 'x').savePlayer(id, p.copyWith(name: '나')),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('⚽ G'));
    await waitFor(tester, find.text('변경 공유 (1건)'));
    expect(find.text('변경 공유 (1건)'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('shareChanges')));
    expect(fakeShare.texts.single, contains('모임 변경 사항'));
    await waitFor(tester, find.text('변경 공유'));
    expect(find.text('변경 공유'), findsOneWidget);
  });
}
