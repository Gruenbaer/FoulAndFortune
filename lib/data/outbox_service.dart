import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';
import 'device_id_service.dart';

class OutboxService {
  OutboxService({AppDatabase? db}) : _db = db ?? appDatabase;

  final AppDatabase _db;

  Future<void> record({
    required String entityType,
    required String entityId,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final entry = SyncOutboxCompanion(
      id: Value(const Uuid().v4()),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload == null ? null : jsonEncode(payload)),
      createdAt: Value(now),
      attemptCount: const Value(0),
      lastError: const Value.absent(),
      deviceId: Value(deviceId),
    );
    await _db.into(_db.syncOutbox).insert(entry);
  }
}
