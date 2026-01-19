import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../data/app_database.dart';
import '../data/device_id_service.dart';
import '../data/outbox_service.dart';
import 'achievement.dart';

class AchievementManager extends ChangeNotifier {
  final Map<String, Achievement> _achievements = {};
  Function(Achievement)? onAchievementUnlocked;

  AchievementManager({AppDatabase? db, OutboxService? outbox})
      : _db = db ?? appDatabase,
        _outbox = outbox ?? OutboxService(db: db ?? appDatabase) {
    // Initialize with all definitions
    for (var achievement in AchievementDefinitions.all) {
      _achievements[achievement.id] = achievement;
    }
    _loadFromDb();
  }

  final AppDatabase _db;
  final OutboxService _outbox;

  List<Achievement> get allAchievements => _achievements.values.toList();
  List<Achievement> get unlockedAchievements => 
      _achievements.values.where((a) => a.isUnlocked).toList();

  bool isUnlocked(String id) => _achievements[id]?.isUnlocked ?? false;

  Future<void> unlock(String id, {String playerName = ''}) async {
    final achievement = _achievements[id];
    if (achievement == null || achievement.isUnlocked) return;

    final unlockedAchievement = achievement.copyWith(
      unlockedAt: DateTime.now(),
      unlockedBy: playerName.isNotEmpty 
          ? [...achievement.unlockedBy, playerName]
          : achievement.unlockedBy,
    );
    
    _achievements[id] = unlockedAchievement;
    notifyListeners();
    await _saveToDb(unlockedAchievement);

    // Trigger callback for splash screen
    onAchievementUnlocked?.call(unlockedAchievement);
  }

  Future<void> _loadFromDb() async {
    try {
      final rows = await _db.select(_db.achievements).get();
      for (final row in rows) {
        final existing = _achievements[row.id];
        if (existing == null) {
          continue;
        }
        _achievements[row.id] = existing.copyWith(
          unlockedAt: row.unlockedAt,
          unlockedBy: row.unlockedBy ?? const <String>[],
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  Future<void> _saveToDb(Achievement achievement) async {
    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final existing = await (_db.select(_db.achievements)
          ..where((row) => row.id.equals(achievement.id)))
        .getSingleOrNull();
    final createdAt = existing?.createdAt ?? now;
    final revision = (existing?.revision ?? 0) + 1;

    final entry = AchievementsCompanion(
      id: Value(achievement.id),
      unlockedAt: Value(achievement.unlockedAt),
      unlockedBy: Value(achievement.unlockedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      deletedAt: const Value.absent(),
      deviceId: Value(deviceId),
      revision: Value(revision),
    );

    if (existing == null) {
      await _db.into(_db.achievements).insert(entry);
    } else {
      await (_db.update(_db.achievements)
            ..where((row) => row.id.equals(achievement.id)))
          .write(entry);
    }

    await _outbox.record(
      entityType: 'achievement',
      entityId: achievement.id,
      operation: 'upsert',
      payload: achievement.toJson(),
    );
  }

  Future<void> reset() async {
    for (var id in _achievements.keys) {
      final def = AchievementDefinitions.all.firstWhere((a) => a.id == id);
      _achievements[id] = def;
    }
    notifyListeners();

    await _db.delete(_db.achievements).go();
    await _outbox.record(
      entityType: 'achievement',
      entityId: '*',
      operation: 'reset',
      payload: {'resetAt': DateTime.now().toIso8601String()},
    );
  }
}
