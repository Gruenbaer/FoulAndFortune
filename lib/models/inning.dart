class Inning {
  final int player; // 1 or 2
  final int points;
  final int penalty;
  final bool isSafety;
  final int total;
  final int ballsOnTable; // State after this inning
  final DateTime timestamp;

  Inning({
    required this.player,
    required this.points,
    required this.penalty,
    required this.isSafety,
    required this.total,
    required this.ballsOnTable,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'player': player,
      'points': points,
      'penalty': penalty,
      'isSafety': isSafety,
      'total': total,
      'ballsOnTable': ballsOnTable,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Inning.fromJson(Map<String, dynamic> json) {
    return Inning(
      player: json['player'],
      points: json['points'],
      penalty: json['penalty'],
      isSafety: json['isSafety'],
      total: json['total'],
      ballsOnTable: json['ballsOnTable'] ?? 15,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
