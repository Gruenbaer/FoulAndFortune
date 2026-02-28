
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/analytics/replay/game_replay_engine.dart';
import 'package:foulandfortune/analytics/replay/replay_state.dart';
import 'package:foulandfortune/analytics/replay/replay_validator.dart';
import 'package:foulandfortune/data/app_database.dart';

void main() {
  group('GameReplayEngine', () {
    late GameReplayEngine engine;
    late GameMeta meta;

    setUp(() {
      engine = GameReplayEngine();
      meta = GameMeta(
        gameId: 'test_game',
        discipline: 'StraightPool',
        raceToScore: 100,
        startTime: DateTime.now(),
        players: [
          PlayerMeta(id: 'p1', name: 'Player 1'),
          PlayerMeta(id: 'p2', name: 'Player 2'),
        ],
      );
    });

    ShotEventRow createEvent(int turn, int shot, String type, Map<String, dynamic> data, {String playerId = 'p1'}) {
      return ShotEventRow(
        id: 'e_${turn}_$shot',
        gameId: 'test_game',
        playerId: playerId,
        turnIndex: turn,
        shotIndex: shot,
        eventType: type,
        payload: jsonEncode({'v': 1, 'data': data}),
        ts: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }

    test('Simple scoring run', () {
      final events = [
        createEvent(0, 0, 'shot', {'kind': 'pocket', 'ballId': 1}),
        createEvent(0, 1, 'shot', {'kind': 'pocket', 'ballId': 2}),
        createEvent(0, 2, 'shot', {'kind': 'miss'}),
        createEvent(0, 3, 'turnEnd', {}),
      ];

      final result = engine.replayGame(meta: meta, events: events);

      expect(result.state.scores['p1'], 2);
      expect(result.state.scores['p2'], 0);
      expect(result.state.innings['p1'], 1); // p1 finished 1 inning
      expect(result.state.activePlayerId, 'p2');
    });

    test('Foul handling in 14.1', () {
      final events = [
        createEvent(0, 0, 'shot', {'kind': 'foul', 'foulType': 'normal'}), // -1
        createEvent(0, 1, 'turnEnd', {}), // End of p1
        
        createEvent(1, 0, 'shot', {'kind': 'foul', 'foulType': 'breakFoul'}, playerId: 'p2'), // -2 (p2)
        createEvent(1, 1, 'turnEnd', {}, playerId: 'p2'), // End of p2
      ];

      final result = engine.replayGame(meta: meta, events: events);

      expect(result.state.scores['p1'], -1);
      expect(result.state.scores['p2'], -2);
      expect(result.state.fouls['p1'], 1);
      expect(result.state.fouls['p2'], 1);
    });

    test('Three foul penalty', () {
        // Assume p1 has 2 fouls already (simulated or events)
        // Actually replay must see them to count them if logic was state-dependent.
        // But ReplayEngine as implemented currently handles each event atomically with penalty derived from TYPE.
        // So we just check if 'threeFouls' type gives -15.
        
        final events = [
            createEvent(0, 0, 'shot', {'kind': 'foul', 'foulType': 'threeFouls'}),
        ];
        
        final result = engine.replayGame(meta: meta, events: events);
        expect(result.state.scores['p1'], -15);
    });

    test('Validator detects mismatch', () {
        final events = [
             createEvent(0, 0, 'shot', {'kind': 'pocket'}),
        ];
        // Replay: p1 score = 1
        
        final result = engine.replayGame(meta: meta, events: events);
        
        // Snapshot says score = 5 (Mismatch)
        final snapshot = {
            'players': [
                {'id': 'p1', 'name': 'Player 1', 'score': 5},
                {'id': 'p2', 'name': 'Player 2', 'score': 0},
            ]
        };
        
        final validator = ReplayValidator();
        final report = validator.validate(rebuilt: result.state, snapshot: snapshot);
        
        expect(report.isValid, false);
        expect(report.mismatches.first, contains('Score Mismatch'));
    });
  });
}
