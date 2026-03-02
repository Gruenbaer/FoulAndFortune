import 'dart:convert';
import '../data/app_database.dart';
import 'shot_event_type.dart';

/// Time-based statistics derived from shot events.
/// 
/// See SHOT_EVENT_SOURCING.md Section 9.1.A
class ShotTimelineStats {
  /// Average time between consecutive shots.
  final Duration avgTimeBetweenShots;
  
  /// Average duration of a turn.
  final Duration avgTurnDuration;
  
  /// Average number of shots per turn.
  final double shotsPerTurn;
  
  /// Total number of shots.
  final int totalShots;
  
  /// Total number of turns.
  final int totalTurns;

  ShotTimelineStats({
    required this.avgTimeBetweenShots,
    required this.avgTurnDuration,
    required this.shotsPerTurn,
    required this.totalShots,
    required this.totalTurns,
  });
  
  factory ShotTimelineStats.empty() => ShotTimelineStats(
    avgTimeBetweenShots: Duration.zero,
    avgTurnDuration: Duration.zero,
    shotsPerTurn: 0,
    totalShots: 0,
    totalTurns: 0,
  );
}

/// Content-based statistics derived from shot events.
/// 
/// See SHOT_EVENT_SOURCING.md Section 9.1.B
class ShotActionStats {
  /// Fouls per shot (0-1 range).
  final double foulRatePerShot;
  
  /// Safeties per shot (0-1 range).
  final double safetyRate;
  
  /// Pockets per shot (0-1 range).
  final double pocketRate;
  
  /// Total pockets.
  final int totalPockets;
  
  /// Total fouls.
  final int totalFouls;
  
  /// Total safeties.
  final int totalSafeties;
  
  /// Breakdown of fouls by type.
  final Map<String, int> foulsByType;

  ShotActionStats({
    required this.foulRatePerShot,
    required this.safetyRate,
    required this.pocketRate,
    required this.totalPockets,
    required this.totalFouls,
    required this.totalSafeties,
    required this.foulsByType,
  });
  
  factory ShotActionStats.empty() => ShotActionStats(
    foulRatePerShot: 0,
    safetyRate: 0,
    pocketRate: 0,
    totalPockets: 0,
    totalFouls: 0,
    totalSafeties: 0,
    foulsByType: {},
  );
}

/// Combined shot-level statistics.
class ShotStats {
  final ShotTimelineStats timeline;
  final ShotActionStats actions;
  
  ShotStats({
    required this.timeline,
    required this.actions,
  });
  
  factory ShotStats.empty() => ShotStats(
    timeline: ShotTimelineStats.empty(),
    actions: ShotActionStats.empty(),
  );
}

/// Pure-function stats engine for shot-level analytics.
/// 
/// Consumes only List<ShotEventRow>, no direct DB access.
/// See SHOT_EVENT_SOURCING.md Section 9.
class ShotStatsEngine {
  
  /// Calculate all shot-level statistics from events.
  static ShotStats calculate(List<ShotEventRow> events) {
    if (events.isEmpty) return ShotStats.empty();
    
    // Filter out voided events
    final activeEvents = _filterVoided(events);
    if (activeEvents.isEmpty) return ShotStats.empty();
    
    return ShotStats(
      timeline: _calculateTimeline(activeEvents),
      actions: _calculateActions(activeEvents),
    );
  }
  
  /// Filter out voided/compensating events.
  static List<ShotEventRow> _filterVoided(List<ShotEventRow> events) {
    final voidedIds = <String>{};
    
    for (final event in events) {
      final payload = _parsePayload(event.payload);
      if (payload['kind'] == ShotKind.void_.name) {
        final correctionOf = payload['correctionOf'] as String?;
        if (correctionOf != null) {
          voidedIds.add(correctionOf);
        }
      }
    }
    
    return events.where((e) {
      final payload = _parsePayload(e.payload);
      // Exclude void events and their targets
      return payload['kind'] != ShotKind.void_.name && !voidedIds.contains(e.id);
    }).toList();
  }
  
  /// Calculate timeline statistics.
  static ShotTimelineStats _calculateTimeline(List<ShotEventRow> events) {
    // Get shot events only (not turn boundaries)
    final shots = events.where((e) => e.eventType == ShotEventType.shot.name).toList();
    final turnStarts = events.where((e) => e.eventType == ShotEventType.turnStart.name).toList();
    final turnEnds = events.where((e) => e.eventType == ShotEventType.turnEnd.name).toList();
    
    // Calculate average time between shots
    Duration totalTimeBetween = Duration.zero;
    int timePairs = 0;
    
    for (int i = 1; i < shots.length; i++) {
      final diff = shots[i].ts.difference(shots[i - 1].ts);
      // Only count reasonable intervals (< 5 minutes)
      if (diff.inMinutes < 5) {
        totalTimeBetween += diff;
        timePairs++;
      }
    }
    
    final avgTimeBetweenShots = timePairs > 0
        ? Duration(milliseconds: totalTimeBetween.inMilliseconds ~/ timePairs)
        : Duration.zero;
    
    // Calculate average turn duration
    Duration totalTurnDuration = Duration.zero;
    int turnCount = 0;
    
    for (int i = 0; i < turnStarts.length && i < turnEnds.length; i++) {
      final duration = turnEnds[i].ts.difference(turnStarts[i].ts);
      if (duration.inMinutes < 30) {
        totalTurnDuration += duration;
        turnCount++;
      }
    }
    
    final avgTurnDuration = turnCount > 0
        ? Duration(milliseconds: totalTurnDuration.inMilliseconds ~/ turnCount)
        : Duration.zero;
    
    // Shots per turn
    final shotsPerTurn = turnCount > 0 ? shots.length / turnCount : 0.0;
    
    return ShotTimelineStats(
      avgTimeBetweenShots: avgTimeBetweenShots,
      avgTurnDuration: avgTurnDuration,
      shotsPerTurn: shotsPerTurn,
      totalShots: shots.length,
      totalTurns: turnCount,
    );
  }
  
  /// Calculate action statistics.
  static ShotActionStats _calculateActions(List<ShotEventRow> events) {
    int pockets = 0;
    int fouls = 0;
    int safeties = 0;
    final foulsByType = <String, int>{};
    
    final shots = events.where((e) => e.eventType == ShotEventType.shot.name);
    
    for (final event in shots) {
      final payload = _parsePayload(event.payload);
      final kind = payload['kind'] as String?;
      
      switch (kind) {
        case 'pocket':
          pockets++;
          break;
        case 'foul':
          fouls++;
          final foulType = payload['foulType'] as String? ?? 'unknown';
          foulsByType[foulType] = (foulsByType[foulType] ?? 0) + 1;
          break;
        case 'safety':
          safeties++;
          break;
      }
    }
    
    final total = pockets + fouls + safeties;
    
    return ShotActionStats(
      foulRatePerShot: total > 0 ? fouls / total : 0,
      safetyRate: total > 0 ? safeties / total : 0,
      pocketRate: total > 0 ? pockets / total : 0,
      totalPockets: pockets,
      totalFouls: fouls,
      totalSafeties: safeties,
      foulsByType: foulsByType,
    );
  }
  
  /// Parse versioned JSON payload.
  static Map<String, dynamic> _parsePayload(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final version = json['v'] as int?;
      if (version == 1) {
        return json['data'] as Map<String, dynamic>? ?? {};
      }
      // Future versions can be handled here
      return {};
    } catch (e) {
      return {};
    }
  }
}
