import 'package:drift/drift.dart';
import 'app_database.dart';
import 'device_id_service.dart';
import 'prefs_migration_service.dart';

class DatabaseBootstrapper {
  DatabaseBootstrapper({AppDatabase? db}) : _db = db ?? appDatabase;

  final AppDatabase _db;

  static const String _syncStateId = 'default';

  Future<void> initialize() async {
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final migration = PrefsMigrationService(db: _db);
    await migration.migrateIfNeeded(deviceId: deviceId);
    await _ensureSyncState(deviceId);
  }

  Future<void> _ensureSyncState(String deviceId) async {
    final existing = await (_db.select(_db.syncState)
          ..where((row) => row.id.equals(_syncStateId)))
        .getSingleOrNull();
    if (existing != null) {
      return;
    }

    final now = DateTime.now();
    final entry = SyncStateCompanion(
      id: const Value(_syncStateId),
      deviceId: Value(deviceId),
      lastSyncAt: const Value.absent(),
      lastSyncToken: const Value.absent(),
      schemaVersion: const Value(1),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    await _db.into(_db.syncState).insert(entry);
  }
}
