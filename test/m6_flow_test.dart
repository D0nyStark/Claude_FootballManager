import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/balancer/balancer.dart';
import 'package:futsalteammaker/data/backup/group_bundle.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/history_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:futsalteammaker/data/repositories/session_repository.dart';
import 'package:futsalteammaker/data/repositories/settings_repository.dart';
import 'package:futsalteammaker/features/backup/backup_actions.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_harness.dart';
import 'pitch_edit_test.dart' as pitch;

void main() {
  testWidgets('확정 → 이력 저장·덱 비우기 → 공유 창에서 텍스트 복사 → 홈에 "마지막 편성"', (tester) async {
    await pitch.arrange(tester);
    await tapAndSettle(tester, find.byKey(const Key('confirm')));

    expect(find.text('확정했어요 · 단톡방에 공유하세요'), findsOneWidget);
    final preview = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('sharePreview')),
        matching: find.byType(Text),
      ),
    );
    expect(preview.data, contains('수요풋살 6vs6 — 13명 / 2팀 (밸런스'));
    // 머리말 · 빈 줄 · 팀 이름 · 구분선 · 선발 6줄 · 후보 구분 · 후보 1줄
    expect(preview.data!.split('\n'), hasLength(12));
    expect(preview.data, contains('🔴 레드'));
    expect(preview.data, isNot(contains('픽소')));
    expect(preview.data, isNot(contains('OVR')));

    // 팀별 OVR 포함 켜고 복사
    await tapAndSettle(tester, find.text('팀별 OVR 포함'));
    await tapAndSettle(tester, find.byKey(const Key('copyText')));
    expect(fakeShare.texts.single, contains('OVR '));
    expect(find.textContaining('복사했어요'), findsOneWidget);

    // 확정 버튼은 "다시 공유"로 바뀐다.
    expect(find.text('다시 공유'), findsOneWidget);
  });

  testWidgets('확정한 편성은 이력에 남고 다음 덱은 새로 시작한다', (tester) async {
    await pitch.arrange(tester);
    await tapAndSettle(tester, find.byKey(const Key('confirm')));
    await tapAndSettle(tester, find.byKey(const Key('shareText')));
    expect(fakeShare.texts, hasLength(1));

    // 뒤로 → 팀 설정 → 덱 → 모임 홈
    await tapAndSettle(tester, find.byTooltip('뒤로'));
    await tapAndSettle(tester, find.byTooltip('Back'));
    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byKey(const Key('lastLineup')), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const Key('lastLineup')));
    expect(find.text('편성 이력 (최근 3개)'), findsOneWidget);
    expect(find.textContaining('6 vs 6 · 2팀'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('삭제'));
    await tapAndSettle(tester, find.text('삭제'));
    expect(find.text('아직 확정한 편성이 없어요.'), findsOneWidget);
  });

  testWidgets('확정하면 작성 중인 덱 임시 저장이 비워진다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, db: db);
    final id = await io(
      tester,
      () => GroupRepository(db).createGroup(name: 'G', onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(
        db,
        'x',
      ).addPlayersByName(id, [for (var i = 0; i < 10; i++) '선수$i']),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('⚽ G'));
    await startFutsal(tester);
    for (var i = 0; i < 10; i++) {
      await tester.enterText(find.widgetWithText(TextField, '선수 검색'), '선수$i');
      await settle(tester);
      await tapAndSettle(tester, find.widgetWithText(CheckboxListTile, '선수$i'));
    }
    expect(await io(tester, () => SessionRepository(db).load(id)), isNotNull);
    await tapAndSettle(tester, find.text('다음 →'));
    await tapAndSettle(tester, find.byKey(const Key('makeTeams')));
    await tapAndSettle(tester, find.byKey(const Key('autoArrange')));
    await tapAndSettle(tester, find.byKey(const Key('confirm')));
    expect(await io(tester, () => SessionRepository(db).load(id)), isNull);
    expect(
      await io(tester, () => HistoryRepository(db, 'x').list(id)),
      hasLength(1),
    );
  });

  testWidgets('모임 설정: 반복 회피·기본 팀 수 → 새 덱에 반영', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, db: db);
    final id = await io(
      tester,
      () => GroupRepository(db).createGroup(name: 'G', onboardingStep: 4),
    );
    await io(
      tester,
      () =>
          PlayerRepository(db, 'x').addPlayersByName(id, ['가', '나', '다', '라']),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('⚽ G'));
    await tapAndSettle(tester, find.byTooltip('설정'));
    await tapAndSettle(tester, find.text('3팀'));
    await tapAndSettle(tester, find.text('강'));
    final prefs = await io(tester, () => SettingsRepository(db).load(id));
    expect(prefs.defaultTeamCount, 3);
    expect(prefs.repeatAvoidance, RepeatAvoidance.strong);

    await tester.pageBack();
    await settle(tester);
    await startFutsal(tester);
    final session = await io(tester, () => SessionRepository(db).load(id));
    expect(session!.teamCount, 3);
  });

  testWidgets('백업 내보내기 → 다른 기기에서 가져오기(새 모임)', (tester) async {
    // 기기 A: 내보내기
    final dbA = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, db: dbA);
    final id = await io(
      tester,
      () => GroupRepository(dbA).createGroup(name: '수요풋살', onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(dbA, 'x').addPlayersByName(id, ['김철수', '이영희']),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('⚽ 수요풋살'));
    await tapAndSettle(tester, find.byTooltip('설정'));
    await tapAndSettle(tester, find.byKey(const Key('exportBackup')));
    final (fileName, bytes) = fakeShare.files.single;
    expect(fileName, startsWith('수요풋살_'));
    expect(fileName, endsWith('.mug'));
    final text = utf8.decode(bytes);
    expect(GroupBundle.decode(text).playerCount, 2);

    // 기기 B: 모임 목록에서 가져오기
    final dbB = AppDatabase(NativeDatabase.memory());
    final tmp = await io(tester, () => Directory.systemTemp.createTemp('mug'));
    await pumpApp(
      tester,
      db: dbB,
      overrides: [
        pickBackupFileProvider.overrideWithValue(() async => text),
        autoBackupDirProvider.overrideWithValue(() async => tmp),
      ],
    );
    await tapAndSettle(tester, find.byKey(const Key('importBackupList')));
    expect(find.text('"수요풋살" 백업'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('importNew')));
    expect(find.text('⚽ 수요풋살'), findsOneWidget);
    expect(
      await io(tester, () => PlayerRepository(dbB, 'x').players(id)),
      hasLength(2),
    );
  });

  testWidgets('같은 모임 백업 가져오기: 병합 전 자동 백업', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final tmp = await tester.runAsync(
      () => Directory.systemTemp.createTemp('mug'),
    );
    late String text;
    await pumpApp(
      tester,
      db: db,
      overrides: [
        pickBackupFileProvider.overrideWithValue(() async => text),
        autoBackupDirProvider.overrideWithValue(() async => tmp!),
      ],
    );
    final id = await io(
      tester,
      () => GroupRepository(db).createGroup(name: '수요풋살', onboardingStep: 4),
    );
    await io(
      tester,
      () => PlayerRepository(db, 'x').addPlayersByName(id, ['김철수']),
    );
    text = (await io(tester, () => BundleService(db, 'x').export(id))).encode();
    await io(
      tester,
      () => PlayerRepository(db, 'x').addPlayersByName(id, ['나중']),
    );
    await settle(tester);

    await tapAndSettle(tester, find.byKey(const Key('importBackupList')));
    expect(find.textContaining('같은 모임이 있어요'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('importMerge')));
    expect(
      await io(tester, () => PlayerRepository(db, 'x').players(id)),
      hasLength(2),
    );
    final saved = await io(tester, () => tmp!.list().toList());
    expect(saved, hasLength(1));
  });
}
