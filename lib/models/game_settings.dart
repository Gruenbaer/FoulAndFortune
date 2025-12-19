class GameSettings {
  final int goalP1;
  final int goalP2;
  final int p1Spot;
  final int p2Spot;

  GameSettings({
    this.goalP1 = 100,
    this.goalP2 = 100,
    this.p1Spot = 0,
    this.p2Spot = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'goalP1': goalP1,
      'goalP2': goalP2,
      'p1Spot': p1Spot,
      'p2Spot': p2Spot,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      goalP1: json['goalP1'] ?? 100,
      goalP2: json['goalP2'] ?? 100,
      p1Spot: json['p1Spot'] ?? 0,
      p2Spot: json['p2Spot'] ?? 0,
    );
  }
}
