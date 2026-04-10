import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/game_history.dart';
import 'game_settings.dart';

extension GameDisciplineMeta on GameDiscipline {
  String get label {
    switch (this) {
      case GameDiscipline.straightPool:
        return '14.1 Straight Pool';
      case GameDiscipline.eightBall:
        return '8-Ball';
      case GameDiscipline.nineBall:
        return '9-Ball';
      case GameDiscipline.tenBall:
        return '10-Ball';
      case GameDiscipline.onePocket:
        return '1-Pocket';
      case GameDiscipline.cowboy:
        return 'Cowboy';
    }
  }

  bool get supportsPushOut =>
      this == GameDiscipline.nineBall || this == GameDiscipline.tenBall;

  bool get supportsGroups => this == GameDiscipline.eightBall;

  String get finishLabel {
    switch (this) {
      case GameDiscipline.eightBall:
        return '8 on the Hill';
      case GameDiscipline.nineBall:
        return '9-Ball Finish';
      case GameDiscipline.tenBall:
        return '10-Ball Finish';
      case GameDiscipline.onePocket:
        return '1-Pocket Finish';
      case GameDiscipline.cowboy:
        return 'Cowboy Finish';
      case GameDiscipline.straightPool:
        return 'Finish';
    }
  }

  String get scoreLabel {
    switch (this) {
      case GameDiscipline.onePocket:
        return 'Games';
      case GameDiscipline.cowboy:
        return 'Sets';
      case GameDiscipline.straightPool:
      case GameDiscipline.eightBall:
      case GameDiscipline.nineBall:
      case GameDiscipline.tenBall:
        return 'Racks';
    }
  }

  String get singleScoreLabel {
    switch (this) {
      case GameDiscipline.onePocket:
        return 'Game';
      case GameDiscipline.cowboy:
        return 'Set';
      case GameDiscipline.straightPool:
      case GameDiscipline.eightBall:
      case GameDiscipline.nineBall:
      case GameDiscipline.tenBall:
        return 'Rack';
    }
  }

  String get setupHint {
    switch (this) {
      case GameDiscipline.eightBall:
        return 'Gruppen, Safeties und klares Match-Tempo fuer Liga- und Trainingsabende.';
      case GameDiscipline.nineBall:
        return 'Rotation mit Push-Out, Break-Druck und starkem Rack-Flow fuer lange Sessions.';
      case GameDiscipline.tenBall:
        return 'Praeziser Rotationsmodus mit mehr Kontrolle und sauberem Turn-Management.';
      case GameDiscipline.onePocket:
        return 'Taktischer Defensivmodus mit Fokus auf Safeties, Foul-Pressure und Session-Statistiken.';
      case GameDiscipline.cowboy:
        return 'Hybrid-Modus fuer kreative Sessions mit klarer Matchfuehrung und Live-Stats.';
      case GameDiscipline.straightPool:
        return 'Der bestehende 14.1-Pfad bleibt separat und unangetastet.';
    }
  }

  String get shortHomeHint {
    switch (this) {
      case GameDiscipline.eightBall:
        return 'Gruppen vergeben, Safeties tracken und den Tisch mit klaren Rack Wins abschliessen.';
      case GameDiscipline.nineBall:
        return 'Rotation mit Push-Out, Golden Break und schnellem Rack-Flow fuer klassische Sessions.';
      case GameDiscipline.tenBall:
        return 'Wie 9-Ball, nur kontrollierter: Call-Shot-Feeling, Push-Out und starker Safety-Druck.';
      case GameDiscipline.onePocket:
        return 'Taktikmodus mit einer Tasche pro Spieler, viel Defense und langen Druckphasen.';
      case GameDiscipline.cowboy:
        return 'Abwechslungsreicher Hybrid-Modus fuer kreative Sessions mit klaren Set- und Finish-Aktionen.';
      case GameDiscipline.straightPool:
        return 'Der bewaehrte 14.1-Modus mit eigener Bedienung bleibt separat erhalten.';
    }
  }

  List<String> get quickHowTo {
    switch (this) {
      case GameDiscipline.eightBall:
        return const [
          'Nach dem Break zuerst Gruppen festlegen: Open Table, Solids oder Stripes.',
          'Der Pool-Pfad wird live pro Aufnahme gefuehrt: Safety, Foul und Turnwechsel bilden den echten Rack-Verlauf ab.',
          'Rack Win fuer normale Racks, Runout fuer saubere Ausspiele und 8 on Break fuer den Sonderfall.',
          'Ausgegraute Buttons bedeuten nur: Eine Voraussetzung fuer diese Aktion ist gerade nicht erfuellt.',
        ];
      case GameDiscipline.nineBall:
        return const [
          'Der Pool-Pfad wird live pro Aufnahme gefuehrt: Jede Aktion beschreibt den aktuellen Stoss, nicht nur eine spaete Zusammenfassung.',
          'Nach einem trockenen Break ist Push Out verfuegbar; danach wird direkt geklaert, wer weiterspielt.',
          'Runout steht fuer regulaere Ausspiele, Golden Break fuer die 9 direkt vom Break. Ausgegraute Buttons bedeuten fehlende Voraussetzungen.',
        ];
      case GameDiscipline.tenBall:
        return const [
          'Der Pool-Pfad wird live pro Aufnahme gefuehrt und soll den wirklichen Rack-Ablauf direkt abbilden.',
          'Push Out gibt es nach trockenem Break; die App fragt anschliessend, wer den naechsten Stoß ausfuehrt.',
          'Nutze nur die gerade passenden Finishes. Ausgegraute Buttons bedeuten, dass eine Voraussetzung noch fehlt.',
        ];
      case GameDiscipline.onePocket:
        return const [
          'Der Pool-Pfad wird live pro Aufnahme gefuehrt: Safeties, Fouls und Turnwechsel spiegeln den echten Tischverlauf.',
          'Game Win zaehlt das Spiel, Safeties und Fouls sind die wichtigsten Steuerknopfe im laufenden Duell.',
          'Ausgegraute Buttons bedeuten nur, dass die passende Voraussetzung in dieser Aufnahme nicht erfuellt ist.',
        ];
      case GameDiscipline.cowboy:
        return const [
          'Der Pool-Pfad wird live pro Aufnahme gefuehrt: jede Aktion soll den aktuellen Tischzustand abbilden.',
          'Clean Finish steht fuer den besonderen Abschluss, Set Win fuer den regulaeren Punkt.',
          'Ausgegraute Buttons bedeuten nur, dass eine Voraussetzung gerade nicht passt; Long-Press erklaert den Grund.',
        ];
      case GameDiscipline.straightPool:
        return const [
          '14.1 bleibt im bestehenden Screen mit eigener Bedienlogik.',
        ];
    }
  }

  List<String> get ruleBook {
    switch (this) {
      case GameDiscipline.eightBall:
        return const [
          'Break: Nach einem legalen Break ist der Tisch offen, bis eine Gruppe sauber festgelegt wird.',
          'Gruppen: Solids und Stripes werden im Match-Center dem aktiven Spieler zugewiesen.',
          'Ziel: Erst die eigene Gruppe, dann die 8. 8 on Break kann als Sonderfinish geloggt werden.',
          'Fouls und Safeties werden live pro Aufnahme erfasst; ausgegraute Buttons bedeuten fehlende Voraussetzungen.',
        ];
      case GameDiscipline.nineBall:
        return const [
          'Rotation: Immer zuerst die niedrigste Kugel anspielen.',
          'Push Out: Nach einem trockenen Break verfuegbar; die App klaert danach, wer die naechste Aufnahme spielt.',
          'Gewinn: 9 regulär gelocht oder Golden Break direkt vom Break.',
          'Fouls, Safeties und Turnwechsel werden live pro Aufnahme erfasst. Ausgegraute Buttons bedeuten fehlende Voraussetzungen.',
        ];
      case GameDiscipline.tenBall:
        return const [
          'Rotation: Immer zuerst die niedrigste Kugel anspielen.',
          'Kontrolle: 10-Ball wird stricter gespielt; besondere Finishes bewusst nur dann loggen, wenn sie regelgerecht waren.',
          'Push Out: Nach trockenem Break verfuegbar; die App klaert danach, wer die naechste Aufnahme spielt.',
          'Fouls, Safeties und Turnwechsel werden live pro Aufnahme erfasst. Ausgegraute Buttons bedeuten fehlende Voraussetzungen.',
        ];
      case GameDiscipline.onePocket:
        return const [
          'Jeder Spieler verteidigt und spielt auf eine eigene Tasche.',
          'Safeties, Fouls und Ball in Hand sind im Match-Center die wichtigsten Match-Events.',
          'Ein gewonnenes Rack wird als Spiel gezaehlt und ueber Game Win abgeschlossen.',
          'Breaker und Rack-Tempo lassen sich im Menue sauber nachfuehren.',
        ];
      case GameDiscipline.cowboy:
        return const [
          'Cowboy wird hier als flexibler Hybrid-Modus fuer Sessions gefuehrt.',
          'Normale Gewinne laufen ueber Set Win, besondere Abschluesse ueber Clean Finish.',
          'Safety, Foul, Turn Switch und Chronik dokumentieren den Ablauf so, dass Stats und Historie konsistent bleiben.',
          'Wenn ihr hausinterne Varianten spielt, nutzt das Regelblatt im Menue als Referenz und die Chronik fuer Abweichungen.',
        ];
      case GameDiscipline.straightPool:
        return const [
          '14.1 wird im separaten Straight-Pool-Screen gefuehrt.',
        ];
    }
  }
}

enum TableGroup { open, solids, stripes }

class PoolMatchPlayerStats {
  final String name;
  final int rackWins;
  final int safeties;
  final int fouls;
  final int dryBreaks;
  final int breakAndRuns;
  final int goldenBreaks;
  final int runOuts;
  final int ballInHandWins;
  final int pushes;
  final int visits;
  final int momentum;
  final TableGroup? assignedGroup;

  const PoolMatchPlayerStats({
    required this.name,
    this.rackWins = 0,
    this.safeties = 0,
    this.fouls = 0,
    this.dryBreaks = 0,
    this.breakAndRuns = 0,
    this.goldenBreaks = 0,
    this.runOuts = 0,
    this.ballInHandWins = 0,
    this.pushes = 0,
    this.visits = 0,
    this.momentum = 0,
    this.assignedGroup,
  });

  PoolMatchPlayerStats copyWith({
    String? name,
    int? rackWins,
    int? safeties,
    int? fouls,
    int? dryBreaks,
    int? breakAndRuns,
    int? goldenBreaks,
    int? runOuts,
    int? ballInHandWins,
    int? pushes,
    int? visits,
    int? momentum,
    Object? assignedGroup = _unset,
  }) {
    return PoolMatchPlayerStats(
      name: name ?? this.name,
      rackWins: rackWins ?? this.rackWins,
      safeties: safeties ?? this.safeties,
      fouls: fouls ?? this.fouls,
      dryBreaks: dryBreaks ?? this.dryBreaks,
      breakAndRuns: breakAndRuns ?? this.breakAndRuns,
      goldenBreaks: goldenBreaks ?? this.goldenBreaks,
      runOuts: runOuts ?? this.runOuts,
      ballInHandWins: ballInHandWins ?? this.ballInHandWins,
      pushes: pushes ?? this.pushes,
      visits: visits ?? this.visits,
      momentum: momentum ?? this.momentum,
      assignedGroup: identical(assignedGroup, _unset)
          ? this.assignedGroup
          : assignedGroup as TableGroup?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rackWins': rackWins,
      'safeties': safeties,
      'fouls': fouls,
      'dryBreaks': dryBreaks,
      'breakAndRuns': breakAndRuns,
      'goldenBreaks': goldenBreaks,
      'runOuts': runOuts,
      'ballInHandWins': ballInHandWins,
      'pushes': pushes,
      'visits': visits,
      'momentum': momentum,
      'assignedGroup': assignedGroup?.name,
    };
  }

  factory PoolMatchPlayerStats.fromJson(Map<String, dynamic> json) {
    TableGroup? assignedGroup;
    final assignedGroupName = json['assignedGroup'] as String?;
    if (assignedGroupName != null) {
      for (final group in TableGroup.values) {
        if (group.name == assignedGroupName) {
          assignedGroup = group;
          break;
        }
      }
    }

    return PoolMatchPlayerStats(
      name: json['name'] as String? ?? 'Player',
      rackWins: json['rackWins'] as int? ?? 0,
      safeties: json['safeties'] as int? ?? 0,
      fouls: json['fouls'] as int? ?? 0,
      dryBreaks: json['dryBreaks'] as int? ?? 0,
      breakAndRuns: json['breakAndRuns'] as int? ?? 0,
      goldenBreaks: json['goldenBreaks'] as int? ?? 0,
      runOuts: json['runOuts'] as int? ?? 0,
      ballInHandWins: json['ballInHandWins'] as int? ?? 0,
      pushes: json['pushes'] as int? ?? 0,
      visits: json['visits'] as int? ?? 0,
      momentum: json['momentum'] as int? ?? 0,
      assignedGroup: assignedGroup,
    );
  }
}

const Object _unset = Object();

class PoolMatchSnapshot {
  final List<PoolMatchPlayerStats> players;
  final int activePlayerIndex;
  final int breakerIndex;
  final int rackNumber;
  final bool alternatingBreaks;
  final bool ballInHand;
  final bool openingShotPending;
  final bool breakAndRunEligible;
  final bool pushOutAvailable;
  final bool pushOutArmed;
  final bool matchOver;
  final TableGroup tableGroup;
  final List<String> actionLog;

  const PoolMatchSnapshot({
    required this.players,
    required this.activePlayerIndex,
    required this.breakerIndex,
    required this.rackNumber,
    required this.alternatingBreaks,
    required this.ballInHand,
    required this.openingShotPending,
    required this.breakAndRunEligible,
    required this.pushOutAvailable,
    required this.pushOutArmed,
    required this.matchOver,
    required this.tableGroup,
    required this.actionLog,
  });
}

class PoolMatchState extends ChangeNotifier {
  PoolMatchState({
    required this.discipline,
    required this.raceTo,
    required List<String> playerNames,
    this.alternatingBreaks = true,
    this.initialBreakerIndex = 0,
    String? matchId,
    DateTime? startedAt,
  })  : players = playerNames
            .map((name) => PoolMatchPlayerStats(name: name.trim()))
            .toList(),
        matchId = matchId ?? const Uuid().v4(),
        startedAt = startedAt ?? DateTime.now() {
    _actionLog = <String>[];
    breakerIndex = initialBreakerIndex.clamp(0, players.length - 1);
    activePlayerIndex = breakerIndex;
    _setOpeningState();
  }

  factory PoolMatchState.fromSnapshotJson(Map<String, dynamic> json) {
    final playersJson = (json['players'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
    final players =
        playersJson.map(PoolMatchPlayerStats.fromJson).toList(growable: false);
    final discipline =
        GameDiscipline.fromStorageKey(json['discipline'] as String?);

    final match = PoolMatchState(
      discipline: discipline,
      raceTo: json['raceTo'] as int? ?? 5,
      alternatingBreaks: json['alternatingBreaks'] as bool? ?? true,
      playerNames: players.isEmpty
          ? const ['Player 1', 'Player 2']
          : players.map((player) => player.name).toList(),
      matchId: json['matchId'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'] as String),
    );

    for (var i = 0; i < match.players.length && i < players.length; i++) {
      match.players[i] = players[i];
    }

    match.activePlayerIndex = json['activePlayerIndex'] as int? ?? 0;
    match.breakerIndex = json['breakerIndex'] as int? ?? 0;
    match.rackNumber = json['rackNumber'] as int? ?? 1;
    match.ballInHand = json['ballInHand'] as bool? ?? false;
    match.openingShotPending = json['openingShotPending'] as bool? ?? false;
    match.breakAndRunEligible = json['breakAndRunEligible'] as bool? ?? false;
    match.pushOutAvailable = json['pushOutAvailable'] as bool? ?? false;
    match.pushOutArmed = json['pushOutArmed'] as bool? ?? false;
    match.matchOver = json['matchOver'] as bool? ?? false;

    final tableGroupName = json['tableGroup'] as String?;
    match.tableGroup = TableGroup.values.firstWhere(
      (group) => group.name == tableGroupName,
      orElse: () => TableGroup.open,
    );
    match._actionLog =
        (json['actionLog'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toList();

    return match;
  }

  final GameDiscipline discipline;
  final int raceTo;
  final bool alternatingBreaks;
  final int initialBreakerIndex;
  final String matchId;
  final DateTime startedAt;
  final List<PoolMatchPlayerStats> players;
  final GameHistory<PoolMatchSnapshot> _history = GameHistory();

  late List<String> _actionLog;
  int activePlayerIndex = 0;
  int breakerIndex = 0;
  int rackNumber = 1;
  bool ballInHand = false;
  bool openingShotPending = true;
  bool breakAndRunEligible = true;
  bool pushOutAvailable = false;
  bool pushOutArmed = false;
  bool matchOver = false;
  TableGroup tableGroup = TableGroup.open;

  List<String> get actionLog => List.unmodifiable(_actionLog);
  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;
  PoolMatchPlayerStats get currentPlayer => players[activePlayerIndex];
  PoolMatchPlayerStats get opponent => players[1 - activePlayerIndex];
  String get scoreLine => '${players[0].rackWins}:${players[1].rackWins}';
  int get completedRacks =>
      players.fold<int>(0, (sum, player) => sum + player.rackWins);
  PoolMatchPlayerStats? get winner => matchOver
      ? players.firstWhere((player) => player.rackWins >= raceTo)
      : null;

  String get contextLine {
    final pieces = <String>[
      'Rack $rackNumber',
      'Breaker: ${players[breakerIndex].name}',
      'At table: ${currentPlayer.name}',
    ];
    if (discipline.supportsGroups) {
      pieces.add(
        tableGroup == TableGroup.open
            ? 'Open table'
            : 'Table: ${tableGroup.name}',
      );
    }
    if (ballInHand) pieces.add('Ball in Hand');
    if (pushOutArmed) pieces.add('Push Out');
    return pieces.join('  |  ');
  }

  double winRateFor(int index) {
    if (rackNumber <= 1) {
      return players[index].rackWins > 0 ? 100 : 0;
    }
    if (completedRacks == 0) return 0;
    return players[index].rackWins / completedRacks * 100;
  }

  double pressureIndexFor(int index) {
    final player = players[index];
    final offense = player.breakAndRuns + player.runOuts + player.goldenBreaks;
    final defense = player.safeties;
    final disciplineBonus = discipline == GameDiscipline.onePocket ? 1.25 : 1.0;
    return (offense * 1.6 + defense * 1.2 - player.fouls * 0.8) *
        disciplineBonus;
  }

  double tableControlFor(int index) {
    final player = players[index];
    final totalVisits = player.visits == 0 ? 1 : player.visits;
    return (player.safeties + player.ballInHandWins + player.runOuts) /
        totalVisits;
  }

  bool get canRecordDryBreak =>
      !matchOver &&
      openingShotPending &&
      activePlayerIndex == breakerIndex &&
      !ballInHand;

  bool get canTogglePushOut =>
      !matchOver && discipline.supportsPushOut && pushOutAvailable;

  bool get canRecordBreakAndRun =>
      !matchOver &&
      breakAndRunEligible &&
      activePlayerIndex == breakerIndex &&
      !ballInHand;

  bool get canRecordSpecialFinish {
    if (matchOver) return false;
    final breakOnlyFinish = discipline == GameDiscipline.eightBall ||
        discipline == GameDiscipline.nineBall ||
        discipline == GameDiscipline.tenBall;
    if (!breakOnlyFinish) return true;
    return openingShotPending && activePlayerIndex == breakerIndex;
  }

  void undo() {
    final snapshot = _history.undo(_snapshot());
    if (snapshot == null) return;
    _restore(snapshot);
    notifyListeners();
  }

  void redo() {
    final snapshot = _history.redo(_snapshot());
    if (snapshot == null) return;
    _restore(snapshot);
    notifyListeners();
  }

  void switchTurn({String? reason}) {
    _recordMutation(() {
      _incrementVisits(activePlayerIndex);
      openingShotPending = false;
      breakAndRunEligible = false;
      activePlayerIndex = 1 - activePlayerIndex;
      pushOutAvailable = false;
      pushOutArmed = false;
      final note = reason ?? 'Turn switched to ${currentPlayer.name}';
      _prependLog(note);
    });
  }

  void recordSafety() {
    _recordMutation(() {
      final player = currentPlayer;
      _replacePlayer(
        activePlayerIndex,
        player.copyWith(safeties: player.safeties + 1),
      );
      openingShotPending = false;
      breakAndRunEligible = false;
      pushOutAvailable = false;
      pushOutArmed = false;
      _incrementVisits(activePlayerIndex);
      activePlayerIndex = 1 - activePlayerIndex;
      _prependLog(
          '${player.name} played a safety. ${currentPlayer.name} is now at the table');
    });
  }

  void recordFoul() {
    _recordMutation(() {
      final foulingPlayer = currentPlayer;
      _replacePlayer(
        activePlayerIndex,
        foulingPlayer.copyWith(fouls: foulingPlayer.fouls + 1),
      );
      openingShotPending = false;
      breakAndRunEligible = false;
      ballInHand = true;
      pushOutAvailable = false;
      pushOutArmed = false;
      _incrementVisits(activePlayerIndex);
      activePlayerIndex = 1 - activePlayerIndex;
      _prependLog(
          '${foulingPlayer.name} committed a foul. ${currentPlayer.name} gets ball in hand');
    });
  }

  void toggleBallInHand() {
    _recordMutation(() {
      ballInHand = !ballInHand;
      openingShotPending = false;
      if (ballInHand) {
        breakAndRunEligible = false;
      }
      _prependLog(ballInHand
          ? '${currentPlayer.name} has ball in hand'
          : 'Ball in hand cleared');
    });
  }

  void setBreaker(int index, {bool makeActive = true}) {
    if (index < 0 || index >= players.length) return;
    _recordMutation(() {
      breakerIndex = index;
      if (makeActive) {
        activePlayerIndex = index;
      }
      ballInHand = false;
      pushOutArmed = false;
      _setOpeningState();
      _prependLog('Breaker set to ${players[index].name}');
    });
  }

  void recordDryBreak() {
    _recordMutation(() {
      final breaker = players[breakerIndex];
      _replacePlayer(
        breakerIndex,
        breaker.copyWith(dryBreaks: breaker.dryBreaks + 1),
      );
      openingShotPending = false;
      breakAndRunEligible = false;
      _incrementVisits(breakerIndex);
      pushOutAvailable = discipline.supportsPushOut;
      pushOutArmed = false;
      activePlayerIndex = 1 - breakerIndex;
      _prependLog('${breaker.name} broke dry');
    });
  }

  void recordPushOut({required bool keepCurrentPlayer}) {
    if (!discipline.supportsPushOut) return;
    _recordMutation(() {
      final pusherIndex = activePlayerIndex;
      final pusher = currentPlayer;
      _replacePlayer(
        pusherIndex,
        pusher.copyWith(pushes: pusher.pushes + 1),
      );
      openingShotPending = false;
      breakAndRunEligible = false;
      ballInHand = false;
      pushOutAvailable = false;
      pushOutArmed = false;
      if (!keepCurrentPlayer) {
        _incrementVisits(pusherIndex);
        activePlayerIndex = 1 - pusherIndex;
      }
      _prependLog(
        keepCurrentPlayer
            ? '${pusher.name} played a push out and stays at the table'
            : '${pusher.name} played a push out. ${currentPlayer.name} takes the next shot',
      );
    });
  }

  void assignTableGroup(TableGroup group) {
    if (!discipline.supportsGroups) return;
    _recordMutation(() {
      tableGroup = group;
      if (group == TableGroup.open) {
        _replacePlayer(
            activePlayerIndex, currentPlayer.copyWith(assignedGroup: null));
        _replacePlayer(
            1 - activePlayerIndex, opponent.copyWith(assignedGroup: null));
        _prependLog('Table reset to open');
        return;
      }
      final opposite =
          group == TableGroup.solids ? TableGroup.stripes : TableGroup.solids;
      final shooter = currentPlayer;
      final other = opponent;
      _replacePlayer(
        activePlayerIndex,
        shooter.copyWith(assignedGroup: group),
      );
      _replacePlayer(
        1 - activePlayerIndex,
        other.copyWith(assignedGroup: opposite),
      );
      _prependLog(
          '${shooter.name} takes ${group.name}. ${other.name} gets ${opposite.name}');
    });
  }

  void winRack({
    bool breakAndRun = false,
    bool goldenBreak = false,
    bool runOut = false,
    String? customLabel,
  }) {
    _recordMutation(() {
      final winnerIndex = activePlayerIndex;
      final winner = currentPlayer;
      var updated = winner.copyWith(
        rackWins: winner.rackWins + 1,
        momentum: winner.momentum + 1,
        ballInHandWins:
            ballInHand ? winner.ballInHandWins + 1 : winner.ballInHandWins,
        breakAndRuns:
            breakAndRun ? winner.breakAndRuns + 1 : winner.breakAndRuns,
        goldenBreaks:
            goldenBreak ? winner.goldenBreaks + 1 : winner.goldenBreaks,
        runOuts: runOut ? winner.runOuts + 1 : winner.runOuts,
      );
      _replacePlayer(winnerIndex, updated);
      _replacePlayer(
        1 - winnerIndex,
        opponent.copyWith(momentum: 0),
      );

      final label = customLabel ??
          (goldenBreak
              ? 'golden break'
              : breakAndRun
                  ? 'break and run'
                  : runOut
                      ? discipline.finishLabel.toLowerCase()
                      : 'rack');
      _prependLog('${winner.name} wins the $label');

      matchOver = updated.rackWins >= raceTo;
      if (matchOver) {
        _prependLog('${winner.name} wins the match ${updated.rackWins}:'
            '${players[1 - winnerIndex].rackWins}');
        return;
      }

      _prepareNextRack(winnerIndex: winnerIndex);
    });
  }

  void resetMatch() {
    _recordMutation(() {
      for (var i = 0; i < players.length; i++) {
        _replacePlayer(
          i,
          players[i].copyWith(
            rackWins: 0,
            safeties: 0,
            fouls: 0,
            dryBreaks: 0,
            breakAndRuns: 0,
            goldenBreaks: 0,
            runOuts: 0,
            ballInHandWins: 0,
            pushes: 0,
            visits: 0,
            momentum: 0,
            assignedGroup: null,
          ),
        );
      }
      rackNumber = 1;
      breakerIndex = 0;
      activePlayerIndex = 0;
      ballInHand = false;
      matchOver = false;
      tableGroup = TableGroup.open;
      _setOpeningState();
      _actionLog.clear();
      _prependLog('Match reset');
    });
  }

  PoolMatchSnapshot _snapshot() {
    return PoolMatchSnapshot(
      players: players.map((player) => player.copyWith()).toList(),
      activePlayerIndex: activePlayerIndex,
      breakerIndex: breakerIndex,
      rackNumber: rackNumber,
      alternatingBreaks: alternatingBreaks,
      ballInHand: ballInHand,
      openingShotPending: openingShotPending,
      breakAndRunEligible: breakAndRunEligible,
      pushOutAvailable: pushOutAvailable,
      pushOutArmed: pushOutArmed,
      matchOver: matchOver,
      tableGroup: tableGroup,
      actionLog: List<String>.from(_actionLog),
    );
  }

  void _restore(PoolMatchSnapshot snapshot) {
    for (var i = 0; i < players.length; i++) {
      players[i] = snapshot.players[i].copyWith();
    }
    activePlayerIndex = snapshot.activePlayerIndex;
    breakerIndex = snapshot.breakerIndex;
    rackNumber = snapshot.rackNumber;
    ballInHand = snapshot.ballInHand;
    openingShotPending = snapshot.openingShotPending;
    breakAndRunEligible = snapshot.breakAndRunEligible;
    pushOutAvailable = snapshot.pushOutAvailable;
    pushOutArmed = snapshot.pushOutArmed;
    matchOver = snapshot.matchOver;
    tableGroup = snapshot.tableGroup;
    _actionLog = List<String>.from(snapshot.actionLog);
  }

  void _recordMutation(VoidCallback mutation) {
    _history.push(_snapshot());
    mutation();
    notifyListeners();
  }

  void _replacePlayer(int index, PoolMatchPlayerStats value) {
    players[index] = value;
  }

  void _prepareNextRack({required int winnerIndex}) {
    rackNumber += 1;
    breakerIndex = alternatingBreaks ? 1 - breakerIndex : winnerIndex;
    activePlayerIndex = breakerIndex;
    ballInHand = false;
    tableGroup = TableGroup.open;
    pushOutArmed = false;
    _setOpeningState();
  }

  void _setOpeningState() {
    openingShotPending = true;
    breakAndRunEligible = true;
    pushOutAvailable = false;
  }

  void _incrementVisits(int index) {
    final player = players[index];
    _replacePlayer(index, player.copyWith(visits: player.visits + 1));
  }

  void _prependLog(String value) {
    _actionLog.insert(0, value);
    if (_actionLog.length > 30) {
      _actionLog = _actionLog.take(30).toList();
    }
  }

  Map<String, dynamic> toSnapshotJson() {
    return {
      'poolMatch': true,
      'matchId': matchId,
      'startedAt': startedAt.toIso8601String(),
      'discipline': discipline.storageKey,
      'raceTo': raceTo,
      'alternatingBreaks': alternatingBreaks,
      'activePlayerIndex': activePlayerIndex,
      'breakerIndex': breakerIndex,
      'rackNumber': rackNumber,
      'ballInHand': ballInHand,
      'openingShotPending': openingShotPending,
      'breakAndRunEligible': breakAndRunEligible,
      'pushOutAvailable': pushOutAvailable,
      'pushOutArmed': pushOutArmed,
      'matchOver': matchOver,
      'tableGroup': tableGroup.name,
      'players': players.map((player) => player.toJson()).toList(),
      'actionLog': List<String>.from(_actionLog),
      'scoreLine': scoreLine,
    };
  }
}
