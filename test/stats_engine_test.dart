import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/data/app_database.dart';
import 'package:foulandfortune/stats/stats_engine.dart';
import 'package:foulandfortune/stats/straight_pool_stats_adapter.dart';
import 'package:foulandfortune/stats/shot_event_type.dart';

void main() {
  group('StatsEngine tests', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);
    
    ShotEventRow buildEvent({
      required int turn,
      required int shot,
      required ShotEventType type,
      String? player = 'p1',
      Map<String, dynamic> data = const {},
      int secondsOffset = 0,
    }) {
      return ShotEventRow(
        id: 'ev-$turn-$shot',
        gameId: 'game-1',
        playerId: player ?? 'p1',
        turnIndex: turn,
        shotIndex: shot,
        eventType: type.name,
        payload: jsonEncode({'v': 1, 'data': data}),
        ts: now.add(Duration(seconds: secondsOffset)),
        createdAt: now.add(Duration(seconds: secondsOffset)),
      );
    }

    test('calculatePlayerAnalytics computes basic metrics correctly', () {
      final events = [
        buildEvent(turn: 1, shot: 0, type: ShotEventType.turnStart, secondsOffset: 0),
        buildEvent(turn: 1, shot: 1, type: ShotEventType.shot, data: {'kind': 'pocket'}, secondsOffset: 10),
        buildEvent(turn: 1, shot: 2, type: ShotEventType.shot, data: {'kind': 'pocket'}, secondsOffset: 25),
        buildEvent(turn: 1, shot: 3, type: ShotEventType.shot, data: {'kind': 'miss'}, secondsOffset: 45),
        buildEvent(turn: 1, shot: 4, type: ShotEventType.turnEnd, secondsOffset: 46),
      ];

      final stats = StatsEngine.calculatePlayerAnalytics(events, 'p1');

      expect(stats.totalShots, 3);
      expect(stats.pockets, 2);
      expect(stats.misses, 1);
      expect(stats.pocketSuccessRate, 2 / 3);
      // Pacing: time since last game event to each player shot.
      // Intervals: (10-0), (25-10), (45-25) => 10s, 15s, 20s. Avg = 15s.
      expect(stats.averagePace.inMilliseconds, 15000); 
    });

    test('StraightPoolStatsAdapter calculates rack and break shot metrics', () {
      final adapter = StraightPoolStatsAdapter();
      final events = [
        buildEvent(turn: 1, shot: 0, type: ShotEventType.rerack, secondsOffset: 0), // Rack 1
        buildEvent(turn: 1, shot: 1, type: ShotEventType.shot, data: {'kind': 'pocket'}, secondsOffset: 10), // Break Success
        buildEvent(turn: 1, shot: 2, type: ShotEventType.shot, data: {'kind': 'pocket'}, secondsOffset: 20),
        buildEvent(turn: 1, shot: 3, type: ShotEventType.rerack, secondsOffset: 60), // Rack 2
        buildEvent(turn: 1, shot: 4, type: ShotEventType.shot, data: {'kind': 'miss'}, secondsOffset: 70),   // Break Failure
      ];

      final stats = StatsEngine.calculatePlayerAnalytics(events, 'p1', adapter: adapter);

      expect(stats.extras['totalRacks'], 2);
      expect(stats.extras['breakShotsAttempted'], 2);
      expect(stats.extras['breakShotsSuccessful'], 1);
      expect(stats.extras['breakShotSuccessRate'], 0.5);
    });
  });
}
