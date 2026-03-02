import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/services/shot_event_service.dart';
import 'package:foulandfortune/stats/shot_event_type.dart';
import 'package:foulandfortune/stats/shot_stats_engine.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('ShotEventService', () {
    late AppDatabase db;
    late ShotEventService service;
    const uuid = Uuid();

    setUp(() async {
      db = AppDatabase();
      service = ShotEventService(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('emits shot event and retrieves it', () async {
      final gameId = uuid.v4();
      final playerId = uuid.v4();

      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 0,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 7},
      );

      final events = await service.getEventsForGame(gameId);
      expect(events.length, 1);
      expect(events[0].playerId, playerId);
      expect(events[0].turnIndex, 0);
      expect(events[0].shotIndex, 0);
      expect(events[0].eventType, 'shot');
      expect(events[0].payload, contains('"kind":"pocket"'));
      expect(events[0].payload, contains('"ballId":7'));
    });

    test('events are ordered by turnIndex and shotIndex', () async {
      final gameId = uuid.v4();
      final playerId = uuid.v4();

      // Insert out of order
      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 1,
        shotIndex: 0,
        eventType: ShotEventType.turnStart,
        data: {},
      );
      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 1,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 3},
      );
      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 0,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 7},
      );

      final events = await service.getEventsForGame(gameId);
      expect(events.length, 3);
      expect(events[0].turnIndex, 0);
      expect(events[0].shotIndex, 0);
      expect(events[1].turnIndex, 0);
      expect(events[1].shotIndex, 1);
      expect(events[2].turnIndex, 1);
      expect(events[2].shotIndex, 0);
    });

    test('unique constraint enforced on (gameId, turnIndex, shotIndex)', () async {
      final gameId = uuid.v4();
      final playerId = uuid.v4();

      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 0,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 7},
      );

      // Attempting to insert duplicate should throw
      expect(
        () => service.emit(
          gameId: gameId,
          playerId: playerId,
          turnIndex: 0,
          shotIndex: 0,
          eventType: ShotEventType.shot,
          data: {'kind': 'pocket', 'ballId': 3},
        ),
        throwsException,
      );
    });

    test('getNextShotIndex returns correct next index', () async {
      final gameId = uuid.v4();
      final playerId = uuid.v4();

      expect(await service.getNextShotIndex(gameId, 0), 0);

      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 0,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 7},
      );

      expect(await service.getNextShotIndex(gameId, 0), 1);

      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 1,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 3},
      );

      expect(await service.getNextShotIndex(gameId, 0), 2);
      expect(await service.getNextShotIndex(gameId, 1), 0); // New turn
    });

    test('hasEventsForGame returns correct status', () async {
      final gameId = uuid.v4();
      final playerId = uuid.v4();

      expect(await service.hasEventsForGame(gameId), false);

      await service.emit(
        gameId: gameId,
        playerId: playerId,
        turnIndex: 0,
        shotIndex: 0,
        eventType: ShotEventType.shot,
        data: {'kind': 'pocket', 'ballId': 7},
      );

      expect(await service.hasEventsForGame(gameId), true);
    });
  });

  group('ShotStatsEngine', () {
    ShotEventRow createEvent({
      required int turnIndex,
      required int shotIndex,
      required String eventType,
      required String payload,
      DateTime? ts,
    }) {
      final now = ts ?? DateTime.now();
      return ShotEventRow(
        id: const Uuid().v4(),
        gameId: 'game-1',
        playerId: 'player-1',
        turnIndex: turnIndex,
        shotIndex: shotIndex,
        eventType: eventType,
        payload: payload,
        ts: now,
        createdAt: now,
      );
    }

    test('calculates action stats correctly', () {
      final events = [
        createEvent(
          turnIndex: 0,
          shotIndex: 0,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"pocket","ballId":7}}',
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 1,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"pocket","ballId":3}}',
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 2,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"foul","foulType":"normal","penalty":-1}}',
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 3,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"safety"}}',
        ),
      ];

      final stats = ShotStatsEngine.calculate(events);

      expect(stats.actions.totalPockets, 2);
      expect(stats.actions.totalFouls, 1);
      expect(stats.actions.totalSafeties, 1);
      expect(stats.actions.pocketRate, 0.5); // 2/4
      expect(stats.actions.foulRatePerShot, 0.25); // 1/4
      expect(stats.actions.safetyRate, 0.25); // 1/4
      expect(stats.actions.foulsByType['normal'], 1);
    });

    test('filters voided events', () {
      final originalId = const Uuid().v4();
      final events = [
        ShotEventRow(
          id: originalId,
          gameId: 'game-1',
          playerId: 'player-1',
          turnIndex: 0,
          shotIndex: 0,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"pocket","ballId":7}}',
          ts: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 1,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"pocket","ballId":3}}',
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 2,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"void_","correctionOf":"$originalId"}}',
        ),
      ];

      final stats = ShotStatsEngine.calculate(events);

      // Original event should be excluded, void event should be excluded
      // Only the second pocket should count
      expect(stats.actions.totalPockets, 1);
    });

    test('returns empty stats for empty events', () {
      final stats = ShotStatsEngine.calculate([]);

      expect(stats.actions.totalPockets, 0);
      expect(stats.actions.totalFouls, 0);
      expect(stats.timeline.totalShots, 0);
      expect(stats.timeline.totalTurns, 0);
    });

    test('calculates timeline stats', () {
      final baseTime = DateTime(2026, 1, 1, 12, 0, 0);
      
      final events = [
        createEvent(
          turnIndex: 0,
          shotIndex: 0,
          eventType: 'turnStart',
          payload: '{"v":1,"data":{}}',
          ts: baseTime,
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 1,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"pocket","ballId":7}}',
          ts: baseTime.add(const Duration(seconds: 10)),
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 2,
          eventType: 'shot',
          payload: '{"v":1,"data":{"kind":"pocket","ballId":3}}',
          ts: baseTime.add(const Duration(seconds: 20)),
        ),
        createEvent(
          turnIndex: 0,
          shotIndex: 3,
          eventType: 'turnEnd',
          payload: '{"v":1,"data":{"pointsInTurn":2}}',
          ts: baseTime.add(const Duration(seconds: 30)),
        ),
      ];

      final stats = ShotStatsEngine.calculate(events);

      expect(stats.timeline.totalShots, 2);
      expect(stats.timeline.totalTurns, 1);
      // Average time between shots: (10s) / 1 pair = 10s
      expect(stats.timeline.avgTimeBetweenShots.inSeconds, 10);
      // Turn duration: 30s
      expect(stats.timeline.avgTurnDuration.inSeconds, 30);
    });
  });
}
