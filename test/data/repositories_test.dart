import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/device_repository.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late GroupRepository groups;
  late PlayerRepository players;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    groups = GroupRepository(db);
    players = PlayerRepository(db, 'device-1');
  });
  tearDown(() => db.close());

  test('기기 id는 한 번 만들면 유지된다', () async {
    final repo = DeviceRepository(db);
    final a = await repo.deviceId();
    final b = await repo.deviceId();
    expect(a, b);
    expect(a, isNotEmpty);
  });

  test('모임 생성 → 목록에 모임장으로 표시, 선수 수 포함', () async {
    final id = await groups.createGroup(
      name: ' 수요풋살 ',
      defaultFormat: MatchFormat.sixVsSix,
    );
    await players.addPlayersByName(id, ['김철수', '이영희']);
    final list = await groups.watchGroups().first;
    expect(list, hasLength(1));
    expect(list.first.name, '수요풋살');
    expect(list.first.role, GroupRole.owner);
    expect(list.first.defaultFormat, MatchFormat.sixVsSix);
    expect(list.first.playerCount, 2);
    expect(list.first.onboardingDone, isFalse);
  });

  test('최근 사용한 모임이 먼저', () async {
    var t = DateTime(2026, 1, 1);
    final g = GroupRepository(
      db,
      clock: () => t = t.add(const Duration(minutes: 1)),
    );
    final a = await g.createGroup(name: 'A');
    await g.createGroup(name: 'B');
    expect((await g.watchGroups().first).first.name, 'B');
    await g.touch(a);
    expect((await g.watchGroups().first).first.name, 'A');
  });

  test('이름으로 추가한 선수: 일반멤버 · 아라 · 3점 · 간단 입력, 입력 순서 유지', () async {
    final id = await groups.createGroup(name: 'G');
    await players.addPlayersByName(id, ['가', '나', '다']);
    final list = await players.players(id);
    expect([for (final p in list) p.name], ['가', '나', '다']);
    final p = list.first;
    expect(p.memberType, MemberType.regular);
    expect(p.mainPosition, Position.ala);
    expect(p.stats, PlayerStats.uniform(3));
    expect(p.statsSimple, isTrue);
  });

  test('선수 수정·삭제 (삭제는 목록에서 사라짐)', () async {
    final id = await groups.createGroup(name: 'G');
    final [pid] = await players.addPlayersByName(id, ['가']);
    final p = (await players.players(id)).single;
    await players.savePlayer(
      id,
      p.copyWith(
        memberType: MemberType.core,
        mainPosition: Position.fixo,
        subPositions: {Position.ala},
        stats: p.stats.copyWith(Stat.shooting, 5),
        canKeep: true,
        statsSimple: false,
        memo: () => '왼발',
      ),
    );
    final updated = (await players.players(id)).single;
    expect(updated.id, pid);
    expect(updated.memberType, MemberType.core);
    expect(updated.mainPosition, Position.fixo);
    expect(updated.subPositions, {Position.ala});
    expect(updated.stats[Stat.shooting], 5);
    expect(updated.canKeep, isTrue);
    expect(updated.memo, '왼발');

    await players.deletePlayer(pid);
    expect(await players.players(id), isEmpty);
  });

  test('상시 제약 추가·삭제', () async {
    final id = await groups.createGroup(name: 'G');
    final ids = await players.addPlayersByName(id, ['가', '나']);
    final cid = await players.addConstraint(
      id,
      ConstraintType.apart,
      ids.toSet(),
    );
    final list = await players.watchConstraints(id).first;
    expect(list.single.type, ConstraintType.apart);
    expect(list.single.playerIds, ids.toSet());
    await players.deleteConstraint(cid);
    expect(await players.watchConstraints(id).first, isEmpty);
  });

  test('모임 삭제 시 선수도 함께 삭제', () async {
    final id = await groups.createGroup(name: 'G');
    await players.addPlayersByName(id, ['가']);
    await groups.deleteGroup(id);
    expect(await groups.watchGroups().first, isEmpty);
    expect(await players.players(id), isEmpty);
  });

  test('생성 마법사 단계 저장', () async {
    final id = await groups.createGroup(name: 'G');
    await groups.setOnboardingStep(id, 2);
    expect((await groups.watchGroup(id).first)!.onboardingStep, 2);
    await groups.setOnboardingStep(id, GroupInfo.onboardingSteps);
    expect((await groups.watchGroup(id).first)!.onboardingDone, isTrue);
  });
}
