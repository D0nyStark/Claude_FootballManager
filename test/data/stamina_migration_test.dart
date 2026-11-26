import 'dart:convert';
import 'dart:io' show ZLibCodec;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/core/models/models.dart';
import 'package:futsalteammaker/data/backup/group_bundle.dart';
import 'package:futsalteammaker/data/backup/invite_codec.dart';
import 'package:futsalteammaker/data/db/app_database.dart';
import 'package:futsalteammaker/data/repositories/group_repository.dart';
import 'package:futsalteammaker/data/repositories/player_repository.dart';
import 'package:futsalteammaker/data/session/match_session.dart';

/// 지금 스키마의 CREATE 문 (테이블 이름 → SQL).
Future<Map<String, String>> currentSchema() async {
  final db = AppDatabase(NativeDatabase.memory());
  final rows = await db
      .customSelect("SELECT name, sql FROM sqlite_master WHERE type = 'table'")
      .get();
  await db.close();
  return {
    for (final r in rows)
      if (!(r.read<String>('name')).startsWith('sqlite_'))
        r.read<String>('name'): r.read<String>('sql'),
  };
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('DB 업그레이드(v4→v5): 예전 선수의 체력 = 나머지 7개 평균', () async {
    final schema = await currentSchema();
    final legacy = NativeDatabase.memory(
      setup: (raw) {
        for (final e in schema.entries) {
          var sql = e.value;
          if (e.key == 'players') {
            sql = sql.replaceAll(
              RegExp(r'"stamina" INTEGER NOT NULL DEFAULT 3,\s*'),
              '',
            );
            expect(sql.contains('stamina'), isFalse);
          }
          raw.execute(sql);
        }
        final now = DateTime(2026, 11, 1).millisecondsSinceEpoch ~/ 1000;
        raw.execute(
          "INSERT INTO groups (id, name, icon, color, my_role, my_display_name, "
          "default_format, onboarding_step, created_at, updated_at, last_used_at) "
          "VALUES ('g', '수요풋살', '⚽', 0, 'owner', NULL, 'fiveVsFive', 4, $now, $now, $now)",
        );
        raw.execute(
          "INSERT INTO players (id, group_id, name, member_type, shooting, dribbling, "
          "speed, passing, physical, creativity, teamwork, main_position, created_at, "
          "updated_at, updated_by) VALUES ('p', 'g', '김철수', 'core', 5, 5, 5, 4, 4, 4, 4, "
          "'ala', $now, $now, 'dev')",
        );
        raw.execute('PRAGMA user_version = 4');
      },
    );
    final db = AppDatabase(legacy);
    addTearDown(db.close);
    final p = (await PlayerRepository(db, 'x').players('g')).single;
    expect(p.stats[Stat.stamina], 4); // (5+5+5+4+4+4+4)/7 = 4.43 → 4
    expect(p.stats[Stat.shooting], 5);
    expect(p.stats[Stat.teamwork], 4);
  });

  test('예전 초대 링크(능력치 7자리)도 읽힌다', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final gid = await GroupRepository(db).createGroup(name: 'G');
    final repo = PlayerRepository(db, 'a');
    await repo.addPlayersByName(gid, ['가']);
    final p = (await repo.players(gid)).single;
    await repo.savePlayer(
      gid,
      p.copyWith(
        stats: PlayerStats(
          shooting: 5,
          dribbling: 4,
          speed: 3,
          passing: 2,
          physical: 1,
          stamina: 5,
          creativity: 2,
          teamwork: 3,
        ),
      ),
    );
    // 새 링크를 만든 뒤 능력치 문자열을 예전처럼 앞 7자리로 자른다.
    final link = InviteCodec.encode(await BundleService(db, 'a').export(gid));
    var b64 = link.substring(InviteCodec.prefix.length);
    b64 = b64.padRight((b64.length + 3) ~/ 4 * 4, '=');
    final json = jsonDecode(
      utf8.decode(ZLibCodec(raw: true).decode(base64Url.decode(b64))),
    ) as Map<String, Object?>;
    final row = (json['p'] as List).first as List;
    expect((row[4] as String).length, 8);
    row[4] = (row[4] as String).substring(0, 7);
    final legacyLink =
        '${InviteCodec.prefix}${base64Url.encode(ZLibCodec(raw: true).encode(utf8.encode(jsonEncode(json)))).replaceAll('=', '')}';

    final bundle = InviteCodec.decode(legacyLink);
    final player = bundle.players.single;
    expect(player['shooting'], 5);
    expect(player['teamwork'], 3);
    // 체력이 없으면 앞 7개(슈팅·드리블·스피드·패스·피지컬·창의력·협력) 평균: 20/7 → 3
    expect(player['stamina'], 3);
  });

  test('예전 백업 파일(stamina 항목 없음)을 가져오면 체력을 평균으로 채운다', () async {
    final a = AppDatabase(NativeDatabase.memory());
    final b = AppDatabase(NativeDatabase.memory());
    addTearDown(a.close);
    addTearDown(b.close);
    final gid = await GroupRepository(a).createGroup(name: 'G');
    await PlayerRepository(a, 'a').addPlayersByName(gid, ['가']);
    final bundle = await BundleService(a, 'a').export(gid);
    for (final p in bundle.players) {
      p.remove('stamina');
      p['shooting'] = 5;
    }
    final legacy = GroupBundle.decode(bundle.encode());
    await BundleService(b, 'b').import(legacy, mode: ImportMode.merge);
    final p = (await PlayerRepository(b, 'b').players(gid)).single;
    expect(p.stats[Stat.stamina], 3); // (5+3*6)/7 = 3.29 → 3
  });

  test('작성 중인 덱의 예전 게스트(능력치 7개)도 읽힌다', () {
    final session = MatchSession.fromJson({
      'v': 1,
      'format': 'fiveVsFive',
      'deck': ['guest-1'],
      'guests': [
        {
          'id': 'guest-1',
          'name': '용병',
          'stats': [5, 4, 3, 2, 1, 5, 1],
          'main': 'pivo',
        },
      ],
    });
    final g = session.guests.single;
    expect(g.stats[Stat.creativity], 5);
    expect(g.stats[Stat.teamwork], 1);
    expect(g.stats[Stat.stamina], 3); // 21/7
    // 새 형식으로 저장 → 다시 읽기
    final again = MatchSession.fromJson(session.toJson()).guests.single;
    expect(again.stats, g.stats);
  });
}
