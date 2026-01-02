
enum GameActionType {
  pot,          // Regular points scored
  safety,       // Intentional safe (0 points, usually ends turn)
  foul,         // Standard Foul
  breakFoul,    // Severe/Break Foul
  reRack,       // Re-rack event (administrative or logic)
  defensivePot, // Safety where ball is pocketed (Safe Mode)
}

class GameAction {
  final GameActionType type;
  final int points;           // Net point change (e.g. +1, -1, -2, -15)
  final String playerId;      // Name or ID of player acting
  final int inning;           // Which inning this occurred in
  final DateTime timestamp;
  final String description;   // Fallback text description
  final int ballsRemaining;   // State of rack after action
  final bool isTurnEnd;       // Did this action end the turn?

  GameAction({
    required this.type,
    required this.points,
    required this.playerId,
    required this.inning,
    required this.timestamp,
    required this.description,
    required this.ballsRemaining,
    this.isTurnEnd = false,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'points': points,
    'playerId': playerId,
    'inning': inning,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
    'ballsRemaining': ballsRemaining,
    'isTurnEnd': isTurnEnd,
  };

  factory GameAction.fromJson(Map<String, dynamic> json) {
    return GameAction(
      type: GameActionType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => GameActionType.pot),
      points: json['points'] ?? 0,
      playerId: json['playerId'] ?? '',
      inning: json['inning'] ?? 1,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      ballsRemaining: json['ballsRemaining'] ?? 0,
      isTurnEnd: json['isTurnEnd'] ?? false,
    );
  }
}
