import '../base/rules_state.dart';
import '../../models/foul_tracker.dart';

/// 14.1 Straight Pool specific game state.
/// Extends RulesState with foul tracking, break sequence, and inning accumulation.
class StraightPoolState extends RulesState {
  /// Tracks consecutive fouls for the 3-foul rule.
  final FoulTracker foulTracker;
  
  /// Win condition: race to this score.
  final int raceToScore;
  
  /// Pending foul mode (normal, breakFoul, or none).
  FoulMode pendingFoulMode;
  
  /// Pending safe mode flag.
  bool pendingSafeMode;
  
  /// Break sequence tracking.
  int? breakingPlayerIndex;
  bool breakFoulStillAvailable;
  bool inBreakSequence;
  
  /// Current inning accumulation (for multi-segment innings with re-racks).
  List<int> currentInningSegments;
  int currentInningPoints;
  bool currentInningHasFoul;
  bool currentInningHasSafe;
  int currentInningBreakFoulCount;
  
  StraightPoolState({
    required this.foulTracker,
    required this.raceToScore,
    this.pendingFoulMode = FoulMode.none,
    this.pendingSafeMode = false,
    this.breakingPlayerIndex,
    this.breakFoulStillAvailable = true,
    this.inBreakSequence = true,
    List<int>? currentInningSegments, // Changed from this.currentInningSegments = const []
    this.currentInningPoints = 0,
    this.currentInningHasFoul = false,
    this.currentInningHasSafe = false,
    this.currentInningBreakFoulCount = 0,
  }) : currentInningSegments = currentInningSegments ?? []; // Create modifiable list
  
  @override
  Map<String, dynamic> toJson() => {
    'threeFoulRuleEnabled': foulTracker.threeFoulRuleEnabled,
    'raceToScore': raceToScore,
    'pendingFoulMode': pendingFoulMode.index,
    'pendingSafeMode': pendingSafeMode,
    'breakingPlayerIndex': breakingPlayerIndex,
    'breakFoulStillAvailable': breakFoulStillAvailable,
    'inBreakSequence': inBreakSequence,
    'currentInningSegments': currentInningSegments,
    'currentInningPoints': currentInningPoints,
    'currentInningHasFoul': currentInningHasFoul,
    'currentInningHasSafe': currentInningHasSafe,
    'currentInningBreakFoulCount': currentInningBreakFoulCount,
  };
  
  factory StraightPoolState.fromJson(Map<String, dynamic> json) {
    return StraightPoolState(
      foulTracker: FoulTracker(
        threeFoulRuleEnabled: json['threeFoulRuleEnabled'] ?? true,
      ),
      raceToScore: json['raceToScore'] ?? 100,
      pendingFoulMode: FoulMode.values[json['pendingFoulMode'] ?? 0],
      pendingSafeMode: json['pendingSafeMode'] ?? false,
      breakingPlayerIndex: json['breakingPlayerIndex'],
      breakFoulStillAvailable: json['breakFoulStillAvailable'] ?? true,
      inBreakSequence: json['inBreakSequence'] ?? true,
      currentInningSegments: (json['currentInningSegments'] as List?)
          ?.map((e) => e as int).toList() ?? [],
      currentInningPoints: json['currentInningPoints'] ?? 0,
      currentInningHasFoul: json['currentInningHasFoul'] ?? false,
      currentInningHasSafe: json['currentInningHasSafe'] ?? false,
      currentInningBreakFoulCount: json['currentInningBreakFoulCount'] ?? 0,
    );
  }
  
  @override
  StraightPoolState copy() {
    return StraightPoolState(
      foulTracker: FoulTracker(
        threeFoulRuleEnabled: foulTracker.threeFoulRuleEnabled,
      ),
      raceToScore: raceToScore,
      pendingFoulMode: pendingFoulMode,
      pendingSafeMode: pendingSafeMode,
      breakingPlayerIndex: breakingPlayerIndex,
      breakFoulStillAvailable: breakFoulStillAvailable,
      inBreakSequence: inBreakSequence,
      currentInningSegments: List.from(currentInningSegments),
      currentInningPoints: currentInningPoints,
      currentInningHasFoul: currentInningHasFoul,
      currentInningHasSafe: currentInningHasSafe,
      currentInningBreakFoulCount: currentInningBreakFoulCount,
    );
  }
}

/// Foul mode enum (matches existing GameState).
enum FoulMode { none, normal, severe }
