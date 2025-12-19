class Player {
  final String id;
  final String name;
  final int score;
  final int racks;
  final int fouls;
  final int consecutiveFouls;
  final bool isProfile;
  
  // Permanent Stats
  final int gamesPlayed;
  final int wins;
  final int highRun;
  final double avg;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.racks = 0,
    this.fouls = 0,
    this.consecutiveFouls = 0,
    this.isProfile = false,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.highRun = 0,
    this.avg = 0.0,
  });

  Player copyWith({
    String? id,
    String? name,
    int? score,
    int? racks,
    int? fouls,
    int? consecutiveFouls,
    bool? isProfile,
    int? gamesPlayed,
    int? wins,
    int? highRun,
    double? avg,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      racks: racks ?? this.racks,
      fouls: fouls ?? this.fouls,
      consecutiveFouls: consecutiveFouls ?? this.consecutiveFouls,
      isProfile: isProfile ?? this.isProfile,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      highRun: highRun ?? this.highRun,
      avg: avg ?? this.avg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'highRun': highRun,
      'avg': avg,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      gamesPlayed: json['gamesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      highRun: json['highRun'] ?? 0,
      avg: (json['avg'] ?? 0.0).toDouble(),
      isProfile: true,
    );
  }
}
