import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// 기기별 설정 (공유되지 않음).
class DeviceRepository {
  DeviceRepository(this._db);

  final AppDatabase _db;
  static const _deviceIdKey = 'deviceId';

  /// 이 기기를 구분하는 id. 로그인이 없으므로 처음 실행할 때 만든다.
  Future<String> deviceId() async {
    final existing = await (_db.select(
      _db.deviceSettings,
    )..where((s) => s.key.equals(_deviceIdKey))).getSingleOrNull();
    if (existing != null) return existing.value;
    final id = const Uuid().v4();
    await _db
        .into(_db.deviceSettings)
        .insert(DeviceSettingsCompanion.insert(key: _deviceIdKey, value: id));
    return id;
  }

  Future<String?> get(String key) async => (await (_db.select(
    _db.deviceSettings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> set(String key, String value) => _db
      .into(_db.deviceSettings)
      .insertOnConflictUpdate(
        DeviceSettingsCompanion.insert(key: key, value: value),
      );

  /// [prefix]로 시작하는 설정을 모두 지운다.
  Future<void> removePrefix(String prefix) => (_db.delete(
    _db.deviceSettings,
  )..where((s) => s.key.like('$prefix%'))).go();
}
