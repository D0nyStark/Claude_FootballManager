import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/backup/group_bundle.dart';
import 'package:futsalteammaker/data/backup/invite_codec.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/history/confirmed_lineup.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/history_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';

const surnames = '김이박최정강조윤장임한오서신권황안송류홍';
const given = ['민수', '영희', '지훈', '다은', '상우', '세진', '하늘', '민재', '지우', '도현'];

/// 선수 [n]명 · 조건 5개 · 이력 3개인 모임.
Future<String> seedGroup(AppDatabase db, int n) async {
  final rng = math.Random(1);
  final gid = await GroupRepository(db).createGroup(name: '수요풋살');
  final repo = PlayerRepository(db, 'devA');
  final ids = await repo.addPlayersByName(gid, [
    for (var i = 0; i < n; i++)
      '${surnames[i % surnames.length]}${given[(i * 7) % given.length]}$i',
  ]);
  final players = await repo.players(gid);
  for (final p in players) {
    int s() => 1 + rng.nextInt(5);
    await repo.savePlayer(
      gid,
      p.copyWith(
        memberType: rng.nextBool() ? MemberType.core : MemberType.regular,
        mainPosition: Position.values[rng.nextInt(3)],
        subPositions: {if (rng.nextBool()) Position.values[rng.nextInt(3)]},
        canKeep: rng.nextDouble() < 0.2,
        statsSimple: false,
        stats: PlayerStats(
          shooting: s(),
          dribbling: s(),
          speed: s(),
          passing: s(),
          physical: s(),
          creativity: s(),
          teamwork: s(),
        ),
      ),
    );
  }
  for (var c = 0; c < 5; c++) {
    await repo.addConstraint(
      gid,
      c.isEven ? ConstraintType.apart : ConstraintType.together,
      {ids[(c * 2) % n], ids[(c * 2 + 1) % n]},
    );
  }
  final history = HistoryRepository(db, 'devA');
  for (var h = 0; h < 3; h++) {
    List<String> team(int t) => [
      for (var i = 0; i < 6; i++) ids[(h + t * 6 + i) % n],
    ];
    final slots = MatchFormat.sixVsSix.slots;
    await history.save(
      gid,
      ConfirmedLineup(
        id: 'h$h',
        confirmedAt: DateTime(2026, 11, 10 + h),
        balanceScore: 91.5,
        lineup: Lineup(
          format: MatchFormat.sixVsSix,
          keeperMode: KeeperMode.rotation,
          teams: [
            for (var t = 0; t < 2; t++)
              TeamLineup(
                slots: {for (var i = 0; i < 6; i++) slots[i]: team(t)[i]},
                bench: [if (t == 0) 'guest-xyz'],
              ),
          ],
        ),
        teamNames: ['🔴 레드', '🔵 블루'],
        teamColors: [0xFFD64545, 0xFF2F6FD6],
        playerNames: {for (final p in players) p.id: p.name, 'guest-xyz': '용병'},
      ),
    );
  }
  return gid;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase a;
  late AppDatabase b;
  setUp(() {
    a = AppDatabase(NativeDatabase.memory());
    b = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('선수 40명 · 조건 5 · 이력 3 → 링크 4,000자 이하', () async {
    final gid = await seedGroup(a, 40);
    final bundle = await BundleService(a, 'devA').export(gid, role: 'member');
    final link = InviteCodec.encode(bundle);
    final full = bundle.encode();
    // ignore: avoid_print
    print('초대 링크 ${link.length}자 (백업 형식 ${full.length}자)');
    expect(link.length, lessThanOrEqualTo(InviteCodec.maxLinkLength));
    expect(link.length, lessThan(full.length));
  });

  test('왕복: 링크로 받은 기기에 선수·능력치·조건·이력이 그대로', () async {
    final gid = await seedGroup(a, 20);
    final link = InviteCodec.encode(
      await BundleService(a, 'devA').export(gid, role: 'manager'),
    );
    final parsed = InviteCodec.tryParse('카톡 메시지 https://x/join#$link 끝')!;
    expect(parsed.role, 'manager');
    expect(parsed.groupId, gid);

    final summary = await BundleService(
      b,
      'devB',
    ).import(parsed, mode: ImportMode.merge, role: parsed.role!);
    expect(summary.createdGroup, isTrue);
    final groupB = (await GroupRepository(b).watchGroups().first).single;
    expect(groupB.role, GroupRole.manager);
    expect(groupB.name, '수요풋살');

    final pa = {
      for (final p in await PlayerRepository(a, 'x').players(gid)) p.id: p,
    };
    final pb = await PlayerRepository(b, 'x').players(gid);
    expect(pb, hasLength(20));
    for (final p in pb) {
      final o = pa[p.id]!;
      expect(p.name, o.name);
      expect(p.stats, o.stats);
      expect(p.mainPosition, o.mainPosition);
      expect(p.subPositions, o.subPositions);
      expect(p.memberType, o.memberType);
      expect(p.canKeep, o.canKeep);
    }
    final cb = await PlayerRepository(b, 'x').watchConstraints(gid).first;
    expect(cb, hasLength(5));
    final ha = await HistoryRepository(a, 'x').list(gid);
    final hb = await HistoryRepository(b, 'x').list(gid);
    expect([for (final h in hb) h.id], [for (final h in ha) h.id]);
    expect(hb.first.lineup.teams[0].slots, ha.first.lineup.teams[0].slots);
    expect(hb.first.lineup.teams[0].bench, ['guest-xyz']);
    expect(hb.first.nameOf('guest-xyz'), '용병');
    expect(hb.first.balanceScore, 91.5);
  });

  test('능력치 없는 변경(멤버가 보냄): 받는 쪽 능력치 유지, 이름 변경은 반영', () async {
    final gid = await seedGroup(a, 6);
    // B에 전체 복사
    await BundleService(b, 'devB').import(
      InviteCodec.decode(
        InviteCodec.encode(await BundleService(a, 'devA').export(gid)),
      ),
      mode: ImportMode.merge,
      role: 'member',
    );
    // B(멤버)가 이름을 고치고, 능력치 없이 변경 공유
    final repoB = PlayerRepository(b, 'devB', clock: () => DateTime(2030));
    final p = (await repoB.players(gid)).first;
    await repoB.savePlayer(
      gid,
      p.copyWith(name: '새이름', stats: PlayerStats.uniform(1)),
    );
    final change = InviteCodec.encode(
      await BundleService(b, 'devB').export(gid),
      includeStats: false,
    );
    final before = (await PlayerRepository(a, 'x').players(gid)).first;
    await BundleService(a, 'devA').import(
      InviteCodec.decode(change),
      mode: ImportMode.merge,
      role: 'member',
    );
    final after = (await PlayerRepository(a, 'x').players(gid)).first;
    expect(after.name, '새이름');
    expect(after.stats, before.stats); // 멤버의 능력치(1점)는 무시
  });

  test('운영진 링크를 받으면 멤버 → 운영진으로 승격, 반대로는 내리지 않음', () async {
    final gid = await seedGroup(a, 4);
    final export = await BundleService(a, 'devA').export(gid);
    await BundleService(
      b,
      'devB',
    ).import(export, mode: ImportMode.merge, role: 'member');
    expect(
      (await GroupRepository(b).watchGroup(gid).first)!.role,
      GroupRole.member,
    );
    final s = await BundleService(
      b,
      'devB',
    ).import(export, mode: ImportMode.merge, role: 'manager');
    expect(s.roleUpgraded, isTrue);
    expect(
      (await GroupRepository(b).watchGroup(gid).first)!.role,
      GroupRole.manager,
    );
    await BundleService(
      b,
      'devB',
    ).import(export, mode: ImportMode.merge, role: 'member');
    expect(
      (await GroupRepository(b).watchGroup(gid).first)!.role,
      GroupRole.manager,
    );
  });

  test('미리보기는 저장하지 않는다', () async {
    final gid = await seedGroup(a, 5);
    final bundle = await BundleService(a, 'devA').export(gid);
    final s = await BundleService(b, 'devB').preview(bundle);
    expect(s.createdGroup, isTrue);
    expect(s.added, 5 + 5);
    expect(await GroupRepository(b).watchGroups().first, isEmpty);
  });

  test('공유 안 된 변경 건수', () async {
    var now = DateTime(2026, 11, 1);
    DateTime clock() => now = now.add(const Duration(minutes: 1));
    final groups = GroupRepository(a, clock: clock);
    final gid = await groups.createGroup(name: 'G');
    final repo = PlayerRepository(a, 'devA', clock: clock);
    await repo.addPlayersByName(gid, ['가', '나']);
    expect(await groups.watchUnsharedChanges(gid).first, isNull); // 공유 전
    await groups.markShared(gid);
    expect(await groups.watchUnsharedChanges(gid).first, 0);
    final p = (await repo.players(gid)).first;
    await repo.savePlayer(gid, p.copyWith(name: '가2'));
    await repo.addConstraint(gid, ConstraintType.apart, {
      p.id,
      (await repo.players(gid)).last.id,
    });
    expect(await groups.watchUnsharedChanges(gid).first, 2);
  });

  test('잘못된 텍스트는 null', () {
    expect(InviteCodec.tryParse('안녕하세요'), isNull);
    expect(InviteCodec.tryParse('MUG2:깨진데이터'), isNull);
  });
}
