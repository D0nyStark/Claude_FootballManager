import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/session_repository.dart';
import 'package:futsalteammaker/data/session/match_session.dart';

import '../helpers/deck_factory.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final guest = Player(
    id: 'guest-1',
    name: '게스트',
    stats: PlayerStats.uniform(4),
    mainPosition: Position.pivo,
    isGuest: true,
  );
  final session = MatchSession(
    format: MatchFormat.sixVsSix,
    deckIds: ['a', 'b', 'guest-1'],
    guests: [guest],
    teamCount: 3,
    keeperMode: KeeperMode.fixed,
    fixedKeepers: {0: 'a'},
    dayConstraints: [
      TeamConstraint(type: ConstraintType.apart, playerIds: {'a', 'b'}),
    ],
  );

  test('JSON 왕복', () {
    final back = MatchSession.fromJson(session.toJson());
    expect(back.format, MatchFormat.sixVsSix);
    expect(back.deckIds, ['a', 'b', 'guest-1']);
    expect(back.guests.single.name, '게스트');
    expect(back.guests.single.isGuest, isTrue);
    expect(back.guests.single.stats, PlayerStats.uniform(4));
    expect(back.teamCount, 3);
    expect(back.keeperMode, KeeperMode.fixed);
    expect(back.fixedKeepers, {0: 'a'});
    expect(back.dayConstraints.single.type, ConstraintType.apart);
  });

  test('deck(): 등록 선수 + 게스트, 삭제된 선수는 제외', () {
    final deck = session.deck([makePlayer('a'), makePlayer('x')]);
    expect([for (final p in deck) p.id], ['a', 'guest-1']);
  });

  test('prune(): 삭제된 선수와 그 키퍼 지정·제약 정리', () {
    final pruned = session.prune([makePlayer('b')]);
    expect(pruned.deckIds, ['b', 'guest-1']);
    expect(pruned.fixedKeepers, isEmpty);
    expect(pruned.dayConstraints, isEmpty);
  });

  test('저장소: 저장 → 불러오기 → 지우기', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final groupId = await GroupRepository(db).createGroup(name: 'G');
    final repo = SessionRepository(db);
    expect(await repo.load(groupId), isNull);
    await repo.save(groupId, session);
    expect((await repo.load(groupId))!.deckIds, session.deckIds);
    await repo.save(groupId, session.copyWith(teamCount: 2));
    expect((await repo.load(groupId))!.teamCount, 2);
    await repo.clear(groupId);
    expect(await repo.load(groupId), isNull);
  });
}
