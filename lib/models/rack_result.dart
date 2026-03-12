import 'package:flutter/foundation.dart';

/// Represents the metadata and performance results of a single completed rack or inning segment.
/// 
/// Part of the 'Ultimate Scorer' system to track advanced analytics inspired by BilliardManager Pro.
@immutable
class RackResult {
  final String? id;
  final String? playerId;
  final String? playerName; // For display/log convenience
  
  // Performance Flags
  final bool wasBreakSuccessful; // Made a ball on break
  final bool isBreakAndRun;    // Run out from own successful break
  
  final int ballsMade;
  final int? inningNumber;
  final DateTime timestamp;

  const RackResult({
    this.id,
    this.playerId,
    this.playerName,
    required this.wasBreakSuccessful,
    required this.isBreakAndRun,
    this.ballsMade = 0,
    this.inningNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'playerName': playerName,
      'wasBreakSuccessful': wasBreakSuccessful,
      'isBreakAndRun': isBreakAndRun,
      'ballsMade': ballsMade,
      'inningNumber': inningNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RackResult.fromJson(Map<String, dynamic> json) {
    return RackResult(
      id: json['id'] as String?,
      playerId: json['playerId'] as String?,
      playerName: json['playerName'] as String?,
      wasBreakSuccessful: json['wasBreakSuccessful'] as bool? ?? false,
      isBreakAndRun: json['isBreakAndRun'] as bool? ?? false,
      ballsMade: json['ballsMade'] as int? ?? 0,
      inningNumber: json['inningNumber'] as int?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : DateTime.now(),
    );
  }

  RackResult copyWith({
    String? id,
    String? playerId,
    String? playerName,
    bool? wasBreakSuccessful,
    bool? isBreakAndRun,
    int? ballsMade,
    int? inningNumber,
    DateTime? timestamp,
  }) {
    return RackResult(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      wasBreakSuccessful: wasBreakSuccessful ?? this.wasBreakSuccessful,
      isBreakAndRun: isBreakAndRun ?? this.isBreakAndRun,
      ballsMade: ballsMade ?? this.ballsMade,
      inningNumber: inningNumber ?? this.inningNumber,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
