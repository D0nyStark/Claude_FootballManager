import 'dart:convert';

import '../db/app_database.dart';
import '../session/match_session.dart';

/// 작성 중인 출전 덱·팀 설정 보존 (SPEC F2.5).
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  Future<MatchSession?> load(String groupId) async {
    final row = await (_db.select(
      _db.sessionDrafts,
    )..where((d) => d.groupId.equals(groupId))).getSingleOrNull();
    if (row == null) return null;
    try {
      return MatchSession.fromJson(
        (jsonDecode(row.json) as Map).cast<String, Object?>(),
      );
    } on Object {
      return null; // 손상된 임시 저장은 버린다.
    }
  }

  Future<void> save(String groupId, MatchSession session) => _db
      .into(_db.sessionDrafts)
      .insertOnConflictUpdate(
        SessionDraftsCompanion.insert(
          groupId: groupId,
          json: jsonEncode(session.toJson()),
          updatedAt: DateTime.now(),
        ),
      );

  Future<void> clear(String groupId) => (_db.delete(
    _db.sessionDrafts,
  )..where((d) => d.groupId.equals(groupId))).go();
}
