import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../history/confirmed_lineup.dart';

/// 확정 편성 이력 (모임별 최근 3개, SPEC F8.3).
class HistoryRepository {
  HistoryRepository(this._db, this.deviceId, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final String deviceId;
  final DateTime Function() _now;

  static const int keep = 3;

  Stream<List<ConfirmedLineup>> watch(String groupId) =>
      _query(groupId).watch().map((rows) => rows.map(_fromRow).toList());

  Future<List<ConfirmedLineup>> list(String groupId) =>
      _query(groupId).get().then((rows) => rows.map(_fromRow).toList());

  SimpleSelectStatement<$LineupHistoriesTable, LineupHistoryRow> _query(
    String groupId,
  ) => _db.select(_db.lineupHistories)
    ..where((h) => h.groupId.equals(groupId) & h.deletedAt.isNull())
    ..orderBy([(h) => OrderingTerm.desc(h.confirmedAt)])
    ..limit(keep);

  /// 저장 후 오래된 것부터 정리해 [keep]개만 남긴다 (삭제 표시로 남겨 공유 시 전파).
  Future<void> save(String groupId, ConfirmedLineup entry) => _db.transaction(
    () async {
      await _db
          .into(_db.lineupHistories)
          .insertOnConflictUpdate(
            LineupHistoriesCompanion.insert(
              id: entry.id,
              groupId: groupId,
              confirmedAt: entry.confirmedAt,
              balanceScore: entry.balanceScore,
              json: jsonEncode(entry.toJson()),
              updatedAt: _now(),
              updatedBy: deviceId,
              deletedAt: const Value(null),
            ),
          );
      final all =
          await (_db.select(_db.lineupHistories)
                ..where((h) => h.groupId.equals(groupId) & h.deletedAt.isNull())
                ..orderBy([(h) => OrderingTerm.desc(h.confirmedAt)]))
              .get();
      for (final old in all.skip(keep)) {
        await delete(old.id);
      }
    },
  );

  Future<void> delete(String id) =>
      (_db.update(_db.lineupHistories)..where((h) => h.id.equals(id))).write(
        LineupHistoriesCompanion(
          deletedAt: Value(_now()),
          updatedAt: Value(_now()),
          updatedBy: Value(deviceId),
        ),
      );

  static ConfirmedLineup _fromRow(LineupHistoryRow r) =>
      ConfirmedLineup.fromJson(
        (jsonDecode(r.json) as Map).cast<String, Object?>(),
        id: r.id,
        confirmedAt: r.confirmedAt,
        balanceScore: r.balanceScore,
      );
}
