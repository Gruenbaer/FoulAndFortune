import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../data/app_database.dart';
import '../data/device_id_service.dart';
import '../data/outbox_service.dart';
import '../models/game_settings.dart';

class SettingsService {
  static const String _settingsId = 'default';

  SettingsService({AppDatabase? db, OutboxService? outbox})
      : _db = db ?? appDatabase,
        _outbox = outbox ?? OutboxService(db: db ?? appDatabase);

  final AppDatabase _db;
  final OutboxService _outbox;

  Future<GameSettings> loadSettings() async {
    try {
      final row = await (_db.select(_db.settings)
            ..where((settings) => settings.id.equals(_settingsId)))
          .getSingleOrNull();
      if (row == null) {
        final defaults = GameSettings();
        await saveSettings(defaults);
        return defaults;
      }
      return _fromRow(row);
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return GameSettings();
    }
  }

  Future<void> saveSettings(GameSettings settings) async {
    final now = DateTime.now();
    final deviceId = await DeviceIdService.instance.getDeviceId();
    final existing = await (_db.select(_db.settings)
          ..where((row) => row.id.equals(_settingsId)))
        .getSingleOrNull();
    final createdAt = existing?.createdAt ?? now;
    final revision = (existing?.revision ?? 0) + 1;

    final entry = SettingsCompanion(
      id: const Value(_settingsId),
      threeFoulRuleEnabled: Value(settings.threeFoulRuleEnabled),
      raceToScore: Value(settings.raceToScore),
      player1Name: Value(settings.player1Name),
      player2Name: Value(settings.player2Name),
      isLeagueGame: Value(settings.isLeagueGame),
      player1Handicap: Value(settings.player1Handicap),
      player2Handicap: Value(settings.player2Handicap),
      player1HandicapMultiplier:
          Value(settings.player1HandicapMultiplier),
      player2HandicapMultiplier:
          Value(settings.player2HandicapMultiplier),
      maxInnings: Value(settings.maxInnings),
      soundEnabled: Value(settings.soundEnabled),
      languageCode: Value(settings.languageCode),
      isDarkTheme: Value(settings.isDarkTheme),
      themeId: Value(settings.themeId),
      hasSeenBreakFoulRules: Value(settings.hasSeenBreakFoulRules),
      hasShown2FoulWarning: Value(settings.hasShown2FoulWarning),
      hasShown3FoulWarning: Value(settings.hasShown3FoulWarning),
      createdAt: Value(createdAt),
      updatedAt: Value(now),
      deletedAt: const Value.absent(),
      deviceId: Value(deviceId),
      revision: Value(revision),
    );

    await _db.into(_db.settings).insertOnConflictUpdate(entry);
    await _outbox.record(
      entityType: 'settings',
      entityId: _settingsId,
      operation: 'upsert',
      payload: settings.toJson(),
    );
  }

  GameSettings _fromRow(SettingsRow row) {
    return GameSettings(
      threeFoulRuleEnabled: row.threeFoulRuleEnabled,
      raceToScore: row.raceToScore,
      player1Name: row.player1Name,
      player2Name: row.player2Name,
      isLeagueGame: row.isLeagueGame,
      player1Handicap: row.player1Handicap,
      player2Handicap: row.player2Handicap,
      player1HandicapMultiplier: row.player1HandicapMultiplier,
      player2HandicapMultiplier: row.player2HandicapMultiplier,
      maxInnings: row.maxInnings,
      soundEnabled: row.soundEnabled,
      languageCode: row.languageCode,
      isDarkTheme: row.isDarkTheme,
      themeId: row.themeId,
      hasSeenBreakFoulRules: row.hasSeenBreakFoulRules,
      hasShown2FoulWarning: row.hasShown2FoulWarning,
      hasShown3FoulWarning: row.hasShown3FoulWarning,
    );
  }
}
