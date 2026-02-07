import 'dart:convert';
import '../data/app_database.dart';
import '../stats/shot_event_type.dart';
import 'stats_engine.dart';

/// 14.1 (Straight Pool) specific statistics calculator.
class StraightPoolStatsAdapter implements DisciplineStatsAdapter {
  @override
  Map<String, dynamic> calculateSpecifics(List<ShotEventRow> events, String playerId) {
    int totalRacks = 0;
    int breakShotsAttempted = 0;
    int breakShotsSuccessful = 0;
    
    bool isWaitingForBreakShot = false;

    for (var event in events) {
      final type = _parseType(event.eventType);
      
      if (type == ShotEventType.rerack) {
        totalRacks++;
        isWaitingForBreakShot = true;
      } else if (type == ShotEventType.shot && isWaitingForBreakShot) {
        // The first shot after a rerack is the break shot.
        if (event.playerId == playerId) {
          breakShotsAttempted++;
          final payload = jsonDecode(event.payload);
          final data = payload['data'] as Map<String, dynamic>;
          if (data['kind'] == ShotKind.pocket.name) {
            breakShotsSuccessful++;
          }
        }
        isWaitingForBreakShot = false;
      }
    }

    return {
      'totalRacks': totalRacks,
      'breakShotSuccessRate': breakShotsAttempted > 0 ? breakShotsSuccessful / breakShotsAttempted : 0.0,
      'breakShotsAttempted': breakShotsAttempted,
      'breakShotsSuccessful': breakShotsSuccessful,
    };
  }

  ShotEventType _parseType(String name) {
    return ShotEventType.values.firstWhere((e) => e.name == name);
  }
}
