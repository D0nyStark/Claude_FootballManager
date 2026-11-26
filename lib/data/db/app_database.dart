import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/models/formation.dart';
import '../../core/models/group_role.dart';
import '../../core/models/member_type.dart';
import '../../core/models/position.dart';
import '../../core/models/team_constraint.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Groups,
    Players,
    PlayerConstraints,
    DeviceSettings,
    SessionDrafts,
    LineupHistories,
    GroupSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 앱에서 쓰는 기기 내 SQLite 파일.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'futsal_team_maker',
      // 웹: 브라우저 저장소(OPFS 또는 IndexedDB)에 SQLite. 파일은 web/에 둔다.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(sessionDrafts);
      if (from < 3) {
        await m.createTable(lineupHistories);
        await m.createTable(groupSettings);
      }
      if (from < 4) await m.addColumn(groups, groups.lastSharedAt);
      if (from < 5) {
        await m.addColumn(players, players.stamina);
        // 예전 선수의 체력 = 나머지 7개 능력치 평균 (OVR이 거의 그대로 유지되게).
        await customStatement(
          'UPDATE players SET stamina = CAST(ROUND((shooting + dribbling + speed + '
          'passing + physical + creativity + teamwork) / 7.0) AS INTEGER)',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
