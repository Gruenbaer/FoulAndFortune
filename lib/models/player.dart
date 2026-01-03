class Player {
  final String name;
  int score;
  int currentInning;
  bool isActive;
  int saves; // Statistics: number of safe plays
  int consecutiveFouls; // Track consecutive fouls for 3-foul rule
  double handicapMultiplier; // Points multiplier (1.0, 2.0, 3.0)
  int? lastPoints; // Points from the very last action
  int highestRun; // Highest run in the current match
  int lastRun; // Run from the previous inning (for display)
  int currentRun; // Run in current inning
  int updateCount; // For detecting changes (animations)
  
  // Inning-based tracking (new for proper point counting)
  int inningPoints; // Points accumulated in current inning (before multiplier/fouls)
  int reRackPoints; // Points before re-rack (for notation like "14.1")
  bool inningHasFoul; // Whether current inning has a foul
  bool inningHasSafe; // Whether current inning has a safe (statistical)
  bool inningHasReRack; // Whether current inning had a re-rack

  Player({
    required this.name,
    this.score = 0,
    this.currentInning = 1,
    this.isActive = false,
    this.saves = 0,
    this.consecutiveFouls = 0,
    double handicapMultiplier = 1.0,
    this.lastPoints,
    this.highestRun = 0,
    this.currentRun = 0,
    this.lastRun = 0,
    this.updateCount = 0,
    this.inningPoints = 0,
    this.reRackPoints = 0,
    this.inningHasFoul = false,
    this.inningHasSafe = false,
    this.inningHasReRack = false,
  }) : handicapMultiplier = handicapMultiplier.clamp(0.1, 10.0);

  void addScore(int points) {
    score += points;
    lastPoints = points;
    updateCount++;
    
    if (points > 0) {
      currentRun += points;
      if (currentRun > highestRun) {
         highestRun = currentRun;
      }
    }
    // Negative points don't affect current run (e.g. foul), 
    // but the run ends when inning increments.
  }

  void incrementInning() {
    lastRun = currentRun; // Capture run before reset for display
    currentInning++;
    currentRun = 0; // Reset run for new inning
    
    // Reset inning trackers
    inningPoints = 0;
    reRackPoints = 0;
    inningHasFoul = false;
    inningHasSafe = false;
    inningHasReRack = false;
  }

  void incrementSaves() {
    saves++;
    updateCount++; // Trigger animation for +0/Safe
  }

  Player copyWith({
    String? name,
    int? score,
    int? currentInning,
    bool? isActive,
    int? saves,
    int? consecutiveFouls,
    double? handicapMultiplier,
    int? lastPoints,
    int? highestRun,
    int? currentRun,
    int? updateCount,
    int? inningPoints,
    int? reRackPoints,
    bool? inningHasFoul,
    bool? inningHasSafe,
    bool? inningHasReRack,
  }) {
    return Player(
      name: name ?? this.name,
      score: score ?? this.score,
      currentInning: currentInning ?? this.currentInning,
      isActive: isActive ?? this.isActive,
      saves: saves ?? this.saves,
      consecutiveFouls: consecutiveFouls ?? this.consecutiveFouls,
      handicapMultiplier: (handicapMultiplier ?? this.handicapMultiplier).clamp(0.1, 10.0),
      lastPoints: lastPoints ?? this.lastPoints,
      highestRun: highestRun ?? this.highestRun,
      currentRun: currentRun ?? this.currentRun,
      lastRun: lastRun ?? this.lastRun,
      updateCount: updateCount ?? this.updateCount,
      inningPoints: inningPoints ?? this.inningPoints,
      reRackPoints: reRackPoints ?? this.reRackPoints,
      inningHasFoul: inningHasFoul ?? this.inningHasFoul,
      inningHasSafe: inningHasSafe ?? this.inningHasSafe,
      inningHasReRack: inningHasReRack ?? this.inningHasReRack,
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'currentInning': currentInning,
    'isActive': isActive,
    'saves': saves,
    'consecutiveFouls': consecutiveFouls,
    'handicapMultiplier': handicapMultiplier,
    'lastPoints': lastPoints,
    'highestRun': highestRun,
    'currentRun': currentRun,
    'lastRun': lastRun,
    'inningPoints': inningPoints,
    'reRackPoints': reRackPoints,
    'inningHasFoul': inningHasFoul,
    'inningHasSafe': inningHasSafe,
    'inningHasReRack': inningHasReRack,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'] as String,
    score: json['score'] as int,
    currentInning: json['currentInning'] as int,
    isActive: json['isActive'] as bool? ?? false,
    saves: json['saves'] as int? ?? 0,
    consecutiveFouls: json['consecutiveFouls'] as int? ?? 0,
    handicapMultiplier: (json['handicapMultiplier'] ?? 1.0).toDouble(),
    lastPoints: json['lastPoints'] as int?,
    highestRun: json['highestRun'] as int? ?? 0,
    currentRun: json['currentRun'] as int? ?? 0,
    lastRun: json['lastRun'] as int? ?? 0,
    inningPoints: json['inningPoints'] as int? ?? 0,
    reRackPoints: json['reRackPoints'] as int? ?? 0,
    inningHasFoul: json['inningHasFoul'] as bool? ?? false,
    inningHasSafe: json['inningHasSafe'] as bool? ?? false,
    inningHasReRack: json['inningHasReRack'] as bool? ?? false,
  );
}
