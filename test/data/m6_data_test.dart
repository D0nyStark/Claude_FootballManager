import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/balancer/balancer.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/backup/group_bundle.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/history/confirmed_lineup.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/history_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:futsalteammaker/data/repositories/settings_repository.dart';
import 'package:futsalteammaker/features/share/share_text.dart';

Lineup sampleLineup() => Lineup(
  format: MatchFormat.sixVsSix,
  keeperMode: KeeperMode.rotation,
  teams: [
    TeamLineup(
      slots: {
        Slot.gk: 'a',
        Slot.fixo1: 'b',
        Slot.fixo2: 'c',
        Slot.alaLeft: 'd',
        Slot.alaRight: 'e',
        Slot.pivo: 'f',
      },
      bench: ['g'],
    ),
    TeamLineup(
      slots: {
        Slot.gk: 'h',
        Slot.fixo1: 'i',
        Slot.alaLeft: 'j',
        Slot.alaRight: 'k',
        Slot.pivo: 'l',
      },
    ),
  ],
);

ConfirmedLineup confirmed(String id, DateTime at) => ConfirmedLineup(
  id: id,
  confirmedAt: at,
  balanceScore: 92,
  lineup: sampleLineup(),
  teamNames: ['🔴 레드', '🔵 블루'],
  teamColors: [0xFFD64545, 0xFF2F6FD6],
  playerNames: {for (final c in 'abcdefghijkl'.split('')) c: '선수$c'},
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('편성 이력', () {
    test('최근 3개만 남고, JSON 왕복이 된다', () async {
      final gid = await GroupRepository(db).createGroup(name: 'G');
      final repo = HistoryRepository(db, 'dev');
      for (var i = 0; i < 5; i++) {
        await repo.save(gid, confirmed('h$i', DateTime(2026, 11, 1 + i)));
      }
      final list = await repo.list(gid);
      expect([for (final h in list) h.id], ['h4', 'h3', 'h2']);
      final h = list.first;
      expect(h.lineup.teams[0].slots[Slot.fixo2], 'c');
      expect(h.lineup.teams[0].bench, ['g']);
      expect(h.teamNames, ['🔴 레드', '🔵 블루']);
      expect(h.nameOf('a'), '선수a');
      expect(h.toHistoryEntry().teams[1], {'h', 'i', 'j', 'k', 'l'});

      await repo.delete('h4');
      expect((await repo.list(gid)).first.id, 'h3');
    });
  });

  group('모임 설정', () {
    test('기본값과 저장', () async {
      final gid = await GroupRepository(db).createGroup(name: 'G');
      final repo = SettingsRepository(db);
      var prefs = await repo.load(gid);
      expect(prefs.repeatAvoidance, RepeatAvoidance.medium);
      expect(prefs.defaultTeamCount, 2);
      await repo.set(gid, GroupPreferences.keyRepeat, 'strong');
      await repo.set(gid, GroupPreferences.keyTeamCount, '3');
      await repo.set(gid, GroupPreferences.keyKeeper, 'fixed');
      await repo.set(gid, GroupPreferences.keyWPosition, '0.25');
      prefs = await repo.load(gid);
      expect(prefs.repeatAvoidance, RepeatAvoidance.strong);
      expect(prefs.defaultTeamCount, 3);
      expect(prefs.defaultKeeperMode, KeeperMode.fixed);
      expect(prefs.weights.position, 0.25);
    });
  });

  group('백업 / 병합', () {
    Future<String> seed(AppDatabase d, {DateTime Function()? clock}) async {
      final gid = await GroupRepository(d).createGroup(name: '수요풋살');
      final players = PlayerRepository(d, 'devA', clock: clock);
      final ids = await players.addPlayersByName(gid, ['김철수', '이영희', '박민수']);
      await players.addConstraint(gid, ConstraintType.apart, {ids[0], ids[1]});
      await HistoryRepository(
        d,
        'devA',
      ).save(gid, confirmed('hist', DateTime(2026, 11, 20)));
      await SettingsRepository(d).set(gid, GroupPreferences.keyRepeat, 'weak');
      return gid;
    }

    test('encode → decode 왕복, 짧은 문자열', () async {
      final gid = await seed(db);
      final bundle = await BundleService(db, 'devA').export(gid);
      final text = bundle.encode();
      expect(text, startsWith(GroupBundle.prefix));
      final back = GroupBundle.decode('카톡에서 복사한 앞말 $text');
      expect(back.groupName, '수요풋살');
      expect(back.playerCount, 3);
      expect(back.constraintCount, 1);
      expect(back.lineupCount, 1);
      // ignore: avoid_print
      print('선수 3명 묶음 길이: ${text.length}자');
    });

    test('새 기기로 가져오기: 모임·선수·제약·이력·설정이 그대로', () async {
      final gid = await seed(db);
      final text = (await BundleService(db, 'devA').export(gid)).encode();

      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      final summary = await BundleService(other, 'devB').import(
        GroupBundle.decode(text),
        mode: ImportMode.merge,
        newGroupRole: 'manager',
      );
      expect(summary.createdGroup, isTrue);
      expect(summary.added, 4); // 선수 3 + 제약 1
      final groups = await GroupRepository(other).watchGroups().first;
      expect(groups.single.name, '수요풋살');
      expect(groups.single.role, GroupRole.manager);
      expect(groups.single.onboardingDone, isTrue);
      expect(await PlayerRepository(other, 'devB').players(gid), hasLength(3));
      expect(
        await PlayerRepository(other, 'devB').watchConstraints(gid).first,
        hasLength(1),
      );
      expect(await HistoryRepository(other, 'devB').list(gid), hasLength(1));
      expect(
        (await SettingsRepository(other).load(gid)).repeatAvoidance,
        RepeatAvoidance.weak,
      );
    });

    test('병합: 더 최근 수정이 이기고, 삭제가 전파된다', () async {
      var t = DateTime(2026, 11, 1);
      DateTime clock() => t = t.add(const Duration(minutes: 1));
      final gid = await seed(db, clock: clock);
      final a = PlayerRepository(db, 'devA', clock: clock);

      // 기기 B로 복사
      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      await BundleService(other, 'devB').import(
        await BundleService(db, 'devA').export(gid),
        mode: ImportMode.merge,
      );
      final b = PlayerRepository(other, 'devB', clock: clock);

      // A: 김철수 수정(나중) / B: 김철수 수정(먼저), 이영희 삭제
      final kimB = (await b.players(gid)).firstWhere((p) => p.name == '김철수');
      await b.savePlayer(gid, kimB.copyWith(name: '김철수B'));
      final leeB = (await b.players(gid)).firstWhere((p) => p.name == '이영희');
      await b.deletePlayer(leeB.id);
      final kimA = (await a.players(gid)).firstWhere((p) => p.name == '김철수');
      await a.savePlayer(gid, kimA.copyWith(name: '김철수A'));

      // B → A 로 공유
      final summary = await BundleService(db, 'devA').import(
        await BundleService(other, 'devB').export(gid),
        mode: ImportMode.merge,
      );
      final names = [for (final p in await a.players(gid)) p.name]..sort();
      expect(names, ['김철수A', '박민수']); // A의 수정이 더 최근, 이영희는 삭제 전파
      expect(summary.deleted, 1);
    });

    test('덮어쓰기: 이 기기 내용을 파일 내용으로 바꾼다', () async {
      final gid = await seed(db);
      final bundle = await BundleService(db, 'devA').export(gid);
      await PlayerRepository(db, 'devA').addPlayersByName(gid, ['나중추가']);
      await BundleService(
        db,
        'devA',
      ).import(bundle, mode: ImportMode.overwrite);
      expect(await PlayerRepository(db, 'devA').players(gid), hasLength(3));
    });

    test('손상된 문자열은 FormatException', () {
      expect(() => GroupBundle.decode('그냥 텍스트'), throwsFormatException);
    });
  });

  test('공유 텍스트 (SPEC F8.2)', () {
    final text = buildShareText(
      lineup: sampleLineup(),
      teamNames: ['🔴 레드', '🔵 블루'],
      nameOf: (id) => '선수$id',
      date: DateTime(2026, 11, 25),
      balanceScore: 92,
    );
    expect(text.split('\n'), [
      '⚽ 11/25(수) 풋살 6vs6 — 12명 / 2팀 (밸런스 92)',
      '🔴 레드: 🔄선수a | 픽소 선수b·선수c | 아라 선수d·선수e | 피보 선수f | 후보 선수g',
      '🔵 블루: 🔄선수h | 픽소 선수i | 아라 선수j·선수k | 피보 선수l',
    ]);
  });
}
