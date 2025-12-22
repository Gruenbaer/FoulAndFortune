class Player {
  final String name;
  int score;
  int currentInning;
  bool isActive;
  int saves; // Statistics: number of safe plays
  int consecutiveFouls; // Track consecutive fouls for 3-foul rule

  Player({
    required this.name,
    this.score = 0,
    this.currentInning = 1,
    this.isActive = false,
    this.saves = 0,
    this.consecutiveFouls = 0,
  });

  void addScore(int points) {
    score += points;
  }

  void incrementInning() {
    currentInning++;
  }

  void incrementSaves() {
    saves++;
  }

  Player copyWith({
    String? name,
    int? score,
    int? currentInning,
    bool? isActive,
    int? saves,
    int? consecutiveFouls,
  }) {
    return Player(
      name: name ?? this.name,
      score: score ?? this.score,
      currentInning: currentInning ?? this.currentInning,
      isActive: isActive ?? this.isActive,
      saves: saves ?? this.saves,
      consecutiveFouls: consecutiveFouls ?? this.consecutiveFouls,
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'currentInning': currentInning,
    'isActive': isActive,
    'saves': saves,
    'consecutiveFouls': consecutiveFouls,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'] as String,
    score: json['score'] as int,
    currentInning: json['currentInning'] as int,
    isActive: json['isActive'] as bool? ?? false,
    saves: json['saves'] as int? ?? 0,
    consecutiveFouls: json['consecutiveFouls'] as int? ?? 0,
  );
}
