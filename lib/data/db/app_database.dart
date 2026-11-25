import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/models/formation.dart';
import '../../core/models/group_role.dart';
import '../../core/models/member_type.dart';
import '../../core/models/position.dart';
import '../../core/models/team_constraint.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Groups, Players, PlayerConstraints, DeviceSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 앱에서 쓰는 기기 내 SQLite 파일.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'futsal_team_maker'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
