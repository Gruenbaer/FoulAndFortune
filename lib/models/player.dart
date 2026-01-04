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
  int lastAwardedPoints; // Explicitly track the last points awarded (e.g. +1, -1)
  
  // Inning-based tracking (new for proper point counting)
  int inningPoints; // Points accumulated in CURRENT active segment of the inning
  List<int> inningHistory; // List of completed segments (runs) in this inning (e.g. [14, 14])
  // int reRackPoints; // DEPRECATED - replaced by inningHistory
  bool inningHasFoul; // Whether current inning has a normal foul
  bool inningHasThreeFouls; // Whether current inning triggered 3-foul penalty
  bool inningHasBreakFoul; // Whether current inning has a break foul (-2)
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
    this.lastAwardedPoints = 0, // Default 0
    this.inningPoints = 0,
    List<int>? inningHistory, // Optional param
    this.inningHasFoul = false,
    this.inningHasThreeFouls = false,
    this.inningHasBreakFoul = false,
    this.inningHasSafe = false,
    this.inningHasReRack = false,
  }) : handicapMultiplier = handicapMultiplier.clamp(0.1, 10.0),
       inningHistory = inningHistory ?? []; // Initialize list

  void addScore(int points) {
    score += points;
    lastPoints = points;
    lastAwardedPoints = points; // Track specifically for "Last Points" box
    updateCount++;
    
    if (points > 0) {
      currentRun += points;
      consecutiveFouls = 0; // Legal points break foul streak
      if (currentRun > highestRun) {
         highestRun = currentRun;
      }
    }
    // Negative points don't affect current run (e.g. foul), 
    // but the run ends when inning increments.
  }

  void incrementInning() {
    // lastRun = currentRun; // Removed: lastRun is set explicitly in _finalizeInning based on net inning score.
    currentInning++;
    currentRun = 0; // Reset run for new inning
    
    // Reset inning trackers
    inningPoints = 0;
    inningHistory = [];
    inningHasThreeFouls = false;
    inningHasFoul = false;
    inningHasBreakFoul = false;
    inningHasSafe = false;
    inningHasReRack = false;
  }

  void incrementSaves() {
    saves++;
    lastAwardedPoints = 0; // Safe adds 0 points but is an event
    updateCount++; // Trigger animation for +0/Safe
  }

  // Helper to update inning points and trigger animation (Real-time)
  void addInningPoints(int points) {
    inningPoints += points;
    lastAwardedPoints = points;
    if (points > 0) {
      consecutiveFouls = 0; // Legal points break foul streak
    }
    updateCount++;
  }

  // Helper to set foul penalty for animation (Real-time)
  void setFoulPenalty(int penalty) {
    lastAwardedPoints = penalty;
    updateCount++;
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
    int? lastAwardedPoints,
    int? inningPoints,
    List<int>? inningHistory,
    bool? inningHasFoul,
    bool? inningHasThreeFouls,
    bool? inningHasBreakFoul,
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
      lastRun: lastRun,
      updateCount: updateCount ?? this.updateCount,
      lastAwardedPoints: lastAwardedPoints ?? this.lastAwardedPoints,
      inningPoints: inningPoints ?? this.inningPoints,
      inningHistory: inningHistory ?? List.from(this.inningHistory),
      inningHasFoul: inningHasFoul ?? this.inningHasFoul,
      inningHasThreeFouls: inningHasThreeFouls ?? this.inningHasThreeFouls,
      inningHasBreakFoul: inningHasBreakFoul ?? this.inningHasBreakFoul,
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
    'lastAwardedPoints': lastAwardedPoints,
    'inningPoints': inningPoints,
    'inningHistory': inningHistory,
    'inningHasFoul': inningHasFoul,
    'inningHasThreeFouls': inningHasThreeFouls,
    'inningHasBreakFoul': inningHasBreakFoul,
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
    lastAwardedPoints: json['lastAwardedPoints'] as int? ?? 0,
    inningPoints: json['inningPoints'] as int? ?? 0,
    inningHistory: (json['inningHistory'] as List?)?.map((e) => e as int).toList() ?? [],
    inningHasFoul: json['inningHasFoul'] as bool? ?? false,
    inningHasThreeFouls: json['inningHasThreeFouls'] as bool? ?? false,
    inningHasBreakFoul: json['inningHasBreakFoul'] as bool? ?? false,
    inningHasSafe: json['inningHasSafe'] as bool? ?? false,
    inningHasReRack: json['inningHasReRack'] as bool? ?? false,
  );
  // Projected Score for UI Display (Real-time feedback)
  int get projectedScore {
    int totalHistory = inningHistory.fold(0, (sum, item) => sum + item);
    int projected = score + inningPoints + totalHistory;
    
    // Apply penalties
    if (inningHasBreakFoul) {
      projected -= 2; // Break foul is always -2
    }
    
    if (inningHasFoul) {
        // Normal foul logic
        // If consecutive fouls is already 2, this 3rd one triggers -15 extra
        // OR if 3-foul was explicitly flagged
        if (consecutiveFouls >= 2 || inningHasThreeFouls) {
            projected -= 16; // -1 (foul) + -15 (3-foul penalty)
        } else {
            projected -= 1; // Standard foul
        }
    }
    
    return projected;
  }
}
