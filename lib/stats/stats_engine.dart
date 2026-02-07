import 'dart:convert';
import '../stats/shot_event_type.dart';
import '../data/app_database.dart';

/// Aggregated statistics for a player based on shot events.
class PlayerAnalytics {
  final int totalShots;
  final int pockets;
  final int fouls;
  final int safeties;
  final int misses;
  final double pocketSuccessRate;
  final Duration averagePace;
  final Map<String, dynamic> extras;

  PlayerAnalytics({
    required this.totalShots,
    required this.pockets,
    required this.fouls,
    required this.safeties,
    required this.misses,
    required this.pocketSuccessRate,
    required this.averagePace,
    this.extras = const {},
  });
}

/// Interface for discipline-specific stats calculation.
abstract class DisciplineStatsAdapter {
  Map<String, dynamic> calculateSpecifics(List<ShotEventRow> events, String playerId);
}

/// Engine to process ShotEvent streams into meaningful analytics.
class StatsEngine {
  /// Calculate analytics for a specific player from a list of events.
  static PlayerAnalytics calculatePlayerAnalytics(
    List<ShotEventRow> events, 
    String playerId, {
    DisciplineStatsAdapter? adapter,
  }) {
    final playerEvents = events.where((e) => e.playerId == playerId).toList();
    if (playerEvents.isEmpty) {
      return PlayerAnalytics(
        totalShots: 0,
        pockets: 0,
        fouls: 0,
        safeties: 0,
        misses: 0,
        pocketSuccessRate: 0,
        averagePace: Duration.zero,
      );
    }

    int totalShots = 0;
    int pockets = 0;
    int fouls = 0;
    int safeties = 0;
    int misses = 0;
    List<Duration> shotIntervals = [];

    DateTime? lastEventTs;

    for (var event in events) {
      final isPlayer = event.playerId == playerId;
      final type = _parseType(event.eventType);
      
      if (type == ShotEventType.shot) {
        final payload = jsonDecode(event.payload);
        final data = payload['data'] as Map<String, dynamic>;
        final kind = data['kind'] as String?;

        if (isPlayer) {
          totalShots++;
          if (kind == ShotKind.pocket.name) pockets++;
          if (kind == ShotKind.foul.name) fouls++;
          if (kind == ShotKind.safety.name) safeties++;
          if (kind == ShotKind.miss.name) misses++;

          if (lastEventTs != null) {
            shotIntervals.add(event.ts.difference(lastEventTs));
          }
        }
      }
      
      // Update pacing anchor regardless of who shot? 
      // Usually "pace" is time since previous event in the game.
      lastEventTs = event.ts;
    }

    final double pocketSuccessRate = totalShots > 0 ? pockets / totalShots : 0;
    final Duration averagePace = shotIntervals.isEmpty 
        ? Duration.zero 
        : Duration(milliseconds: (shotIntervals.fold(0, (sum, d) => sum + d.inMilliseconds) / shotIntervals.length).round());

    Map<String, dynamic> extras = {};
    if (adapter != null) {
      extras = adapter.calculateSpecifics(events, playerId);
    }

    return PlayerAnalytics(
      totalShots: totalShots,
      pockets: pockets,
      fouls: fouls,
      safeties: safeties,
      misses: misses,
      pocketSuccessRate: pocketSuccessRate,
      averagePace: averagePace,
      extras: extras,
    );
  }

  static ShotEventType _parseType(String name) {
    return ShotEventType.values.firstWhere((e) => e.name == name);
  }
}
