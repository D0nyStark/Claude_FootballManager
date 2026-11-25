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
}
