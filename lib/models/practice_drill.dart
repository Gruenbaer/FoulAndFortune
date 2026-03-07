enum PracticeCategory {
  straightness,
  potting,
  technique,
  position,
}

class PracticeDrill {
  const PracticeDrill({
    required this.id,
    required this.title,
    required this.category,
    required this.goal,
    required this.recommendedReps,
  });

  final String id;
  final String title;
  final PracticeCategory category;
  final String goal;
  final int recommendedReps;
}

class DrillProgress {
  const DrillProgress({
    required this.attempts,
    required this.successes,
    required this.bestPercent,
    required this.lastPercent,
  });

  final int attempts;
  final int successes;
  final double bestPercent;
  final double lastPercent;

  DrillProgress copyWith({
    int? attempts,
    int? successes,
    double? bestPercent,
    double? lastPercent,
  }) {
    return DrillProgress(
      attempts: attempts ?? this.attempts,
      successes: successes ?? this.successes,
      bestPercent: bestPercent ?? this.bestPercent,
      lastPercent: lastPercent ?? this.lastPercent,
    );
  }

  Map<String, dynamic> toJson() => {
        'attempts': attempts,
        'successes': successes,
        'bestPercent': bestPercent,
        'lastPercent': lastPercent,
      };

  factory DrillProgress.fromJson(Map<String, dynamic> json) {
    return DrillProgress(
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      successes: (json['successes'] as num?)?.toInt() ?? 0,
      bestPercent: (json['bestPercent'] as num?)?.toDouble() ?? 0,
      lastPercent: (json['lastPercent'] as num?)?.toDouble() ?? 0,
    );
  }

  static const empty = DrillProgress(
    attempts: 0,
    successes: 0,
    bestPercent: 0,
    lastPercent: 0,
  );
}

const List<PracticeDrill> kPracticeDrills = [
  PracticeDrill(
    id: 'straightness_1',
    title: 'Geradlinigkeit – Weiße zurück auf Linie',
    category: PracticeCategory.straightness,
    goal: 'Weiße sauber über Bande auf Ausgangslinie zurückführen.',
    recommendedReps: 20,
  ),
  PracticeDrill(
    id: 'straightness_2',
    title: 'Geradlinigkeit – Stoppball',
    category: PracticeCategory.straightness,
    goal: 'Objektball lochen, Weiße am Treffpunkt stoppen.',
    recommendedReps: 20,
  ),
  PracticeDrill(
    id: 'potting_1',
    title: 'Senken – Seitenwechsel Referenzen',
    category: PracticeCategory.potting,
    goal: 'Objektbälle mit sauberem Nachläufer in Ecktaschen versenken.',
    recommendedReps: 20,
  ),
  PracticeDrill(
    id: 'technique_1',
    title: 'Technik – Stop/Nach/Rückläufer Referenzen',
    category: PracticeCategory.technique,
    goal: 'Für jeden Referenzpunkt reproduzierbare Stoßqualität erzielen.',
    recommendedReps: 15,
  ),
  PracticeDrill(
    id: 'position_1',
    title: 'Position – 3-Ball Reihen',
    category: PracticeCategory.position,
    goal: 'Freie Reihenfolge, sichere Positionswahl, Fehlerquote minimieren.',
    recommendedReps: 10,
  ),
  PracticeDrill(
    id: 'position_2',
    title: 'Position – 2er/3er Cluster',
    category: PracticeCategory.position,
    goal: 'Cluster in Aufnahmen strukturieren und kontrolliert auflösen.',
    recommendedReps: 10,
  ),
];

const List<String> kPreShotChecklist = [
  'Zielpunkt fixieren (Banden-/Objektball-Punkt).',
  'Standbein auf Stoßlinie, stabiler Stand.',
  'Queue mittig auf der Weißen, gerade Führung.',
  'Ja/Nein-Check: Nur bei klarem Ja stoßen.',
  'Nach dem Stoß ruhig bleiben, Ergebnis reflektieren.',
];
