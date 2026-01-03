import 'package:flutter/foundation.dart';
import 'dart:async';
import 'foul_tracker.dart';
import 'achievement_manager.dart';
import '../data/messages.dart';
import 'game_settings.dart';

enum FoulMode { none, normal, severe }

// Event System for UI Animations
abstract class GameEvent {}

class FoulEvent extends GameEvent {
  final Player player;
  final int points;
  final String message;
  final int? positivePoints; // Optional: balls pocketed for breakdown display
  final int? penalty; // Optional: foul penalty for breakdown display

  FoulEvent(this.player, this.points, this.message,
      {this.positivePoints, this.penalty});
}

class WarningEvent extends GameEvent {
  final String title;
  final String message;
  WarningEvent(this.title, this.message);
}

class ReRackEvent extends GameEvent {
  final String type; // "14.1 Continuous", "After Foul", "Auto/Safe"
  ReRackEvent(this.type);
}

class DecisionEvent extends GameEvent {
  final String title;
  final String message;
  final List<String> options;
  final Function(int) onOptionSelected;

  DecisionEvent(this.title, this.message, this.options, this.onOptionSelected);
}

class SafeEvent extends GameEvent {}

// Inning Record for Score Card (replaces log parsing)
class InningRecord {
  final int inning;
  final String playerName;
  final String notation; // "15", "5.3F", "10S", etc.
  final int runningTotal; // Player's total score after this inning
  
  InningRecord({
    required this.inning,
    required this.playerName,
    required this.notation,
    required this.runningTotal,
  });
  
  Map<String, dynamic> toJson() => {
    'inning': inning,
    'playerName': playerName,
    'notation': notation,
    'runningTotal': runningTotal,
  };
  
  factory InningRecord.fromJson(Map<String, dynamic> json) => InningRecord(
    inning: json['inning'] as int,
    playerName: json['playerName'] as String,
    notation: json['notation'] as String,
    runningTotal: json['runningTotal'] as int,
  );
}

class GameState extends ChangeNotifier {
  GameSettings settings;
  int raceToScore;
  late List<Player> players;
  late FoulTracker foulTracker;
  late AchievementManager? achievementManager;
  Set<int> activeBalls = {};
  int currentPlayerIndex = 0;
  bool gameStarted = false;
  bool gameOver = false;
  Player? winner;
  String? lastAction;
  bool showThreeFoulPopup = false;
  bool showTwoFoulWarning = false;

  // Foul Mode Flag
  FoulMode foulMode = FoulMode.none;
  // Safe Mode Toggle
  bool isSafeMode = false;

  // Break Sequence Flag (True at start, false after first valid shot)
  bool inBreakSequence = true;

  // UI Hint Flag
  bool showBreakFoulHint = false;
  int breakFoulErrorCount = 0;
  int ball13ErrorCount = 0; // Easter egg for Alex
  String breakFoulHintMessage = "Only Ball 15!";

  // Match History
  List<String> matchLog = [];
  
  // Inning Records for Score Card (structured data, no parsing needed)
  List<InningRecord> inningRecords = [];

  // Undo/Redo Stacks
  final List<GameSnapshot> _undoStack = [];
  final List<GameSnapshot> _redoStack = [];

  // UI Event Queue (Consumed by UI)
  final List<GameEvent> eventQueue = [];

  bool get canUndo => _undoStack.isNotEmpty;

  // Robust check for Break Foul availability
  // Available if explicitly in sequence OR if game hasn't really started (log empty)
  bool get canBreakFoul => inBreakSequence || matchLog.isEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // Game Clock
  final Stopwatch _gameTimer = Stopwatch();
  Duration _savedDuration = Duration.zero; // For persistence

  Timer? _ticker;
  bool _isPaused = false;

  bool get isPaused => _isPaused;
  Duration get elapsedDuration => _savedDuration + _gameTimer.elapsed;

  void startGameTimer() {
    if (!gameStarted) return;
    if (!_gameTimer.isRunning && !_isPaused) {
      _gameTimer.start();
      _startTicker();
    }
  }

  void pauseGame() {
    if (_gameTimer.isRunning) {
      _gameTimer.stop();
      _isPaused = true;
      _stopTicker();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_isPaused) {
      _gameTimer.start();
      _isPaused = false;
      _startTicker();
      notifyListeners();
    }
  }

  void togglePause() {
    if (_isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners(); // Update UI every second
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  GameState({
    required this.settings,
    this.achievementManager,
  }) : raceToScore = settings.raceToScore {
    // Initialize Players
    players = [
      Player(
          name: settings.player1Name,
          isActive: true, // P1 starts active by default
          score: settings.player1Handicap,
          handicapMultiplier: settings.player1HandicapMultiplier),
      Player(
          name: settings.player2Name,
          isActive: false,
          score: settings.player2Handicap,
          handicapMultiplier: settings.player2HandicapMultiplier)
    ];

    foulTracker =
        FoulTracker(threeFoulRuleEnabled: settings.threeFoulRuleEnabled);
    _resetRack();
  }

  // Update settings mid-game
  void updateSettings(dynamic settings) {
    bool somethingChanged = false;

    // Update Race to Score
    if (raceToScore != settings.raceToScore) {
      raceToScore = settings.raceToScore;
      somethingChanged = true;
      _logAction('Race to Score changed to $raceToScore');
    }

    // Update 3-Foul Rule
    if (foulTracker.threeFoulRuleEnabled != settings.threeFoulRuleEnabled) {
      foulTracker.threeFoulRuleEnabled = settings.threeFoulRuleEnabled;
      somethingChanged = true;
      _logAction(
          '3-Foul Rule ${settings.threeFoulRuleEnabled ? "Enabled" : "Disabled"}');
    }

    // Update Player Names (if changed)
    if (players[0].name != settings.player1Name) {
      players[0] = players[0].copyWith(name: settings.player1Name);
      somethingChanged = true;
      _logAction('Player 1 renamed to ${settings.player1Name}');
    }

    if (players[1].name != settings.player2Name) {
      players[1] = players[1].copyWith(name: settings.player2Name);
      somethingChanged = true;
      _logAction('Player 2 renamed to ${settings.player2Name}');
    }

    // Update Handicap Multipliers
    if (players[0].handicapMultiplier != settings.player1HandicapMultiplier) {
      players[0] = players[0]
          .copyWith(handicapMultiplier: settings.player1HandicapMultiplier);
      somethingChanged = true;
      _logAction(
          'Player 1 Handicap changed to ${settings.player1HandicapMultiplier}x');
    }

    if (players[1].handicapMultiplier != settings.player2HandicapMultiplier) {
      players[1] = players[1]
          .copyWith(handicapMultiplier: settings.player2HandicapMultiplier);
      somethingChanged = true;
      _logAction(
          'Player 2 Handicap changed to ${settings.player2HandicapMultiplier}x');
    }

    // Check win condition if score limit was lowered
    if (somethingChanged) {
      _checkWinCondition();
      notifyListeners();
    }
  }

  void setShowBreakFoulHint(bool show) {
    showBreakFoulHint = show;
    notifyListeners();
  }

  // Toggle safe mode without switching players (per user request)
  void toggleSafeMode() {
    isSafeMode = !isSafeMode;
    notifyListeners();
  }

  void reportBreakFoulError({int? ballNumber}) {
    breakFoulErrorCount++;
    showBreakFoulHint = true;

    // Special Easter egg for Ball 13 (Alex)
    if (ballNumber == 13) {
      ball13ErrorCount++;

      // Update hint message based on count
      if (ball13ErrorCount == 1) {
        // Standard random message for first tap, or keep unique?
        // Let's keep it subtle at first
        breakFoulHintMessage = EasterEggs.getRandomBreakFoulMessage();
      } else if (ball13ErrorCount == 2) {
        breakFoulHintMessage = "Es ist Freitag der 15!";
      } else if (ball13ErrorCount == 5) {
        breakFoulHintMessage = "Alex...";
      } else if (ball13ErrorCount == 10) {
        breakFoulHintMessage = "ALEX...die 15!";
      } else {
        breakFoulHintMessage = EasterEggs.getRandomBreakFoulMessage();

        breakFoulHintMessage = EasterEggs.getRandomBreakFoulMessage();
      }
    } else {
      breakFoulHintMessage = EasterEggs.getRandomBreakFoulMessage();
    }

    notifyListeners();
  }

  void resetBreakFoulError() {
    breakFoulErrorCount = 0;
    ball13ErrorCount = 0;
    showBreakFoulHint = false;
    notifyListeners();
  }

  Player get currentPlayer => players[currentPlayerIndex];
  Player get otherPlayer => players[1 - currentPlayerIndex];

  void dismissThreeFoulPopup() {
    showThreeFoulPopup = false;
    notifyListeners();
  }

  void dismissTwoFoulWarning() {
    showTwoFoulWarning = false;
    notifyListeners();
  }

  void _resetRack() {
    activeBalls = Set.from(List.generate(15, (i) => i + 1));
    notifyListeners();
  }

  void _pushState() {
    _undoStack.add(GameSnapshot.fromState(this));
    _redoStack.clear(); // clear redo on new action
  }

  void undo() {
    if (!canUndo) return;
    final currentSnapshot = GameSnapshot.fromState(this);
    _redoStack.add(currentSnapshot);

    final snapshot = _undoStack.removeLast();
    snapshot.restore(this);
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final currentSnapshot = GameSnapshot.fromState(this);
    _undoStack.add(currentSnapshot);

    final snapshot = _redoStack.removeLast();
    snapshot.restore(this);
    notifyListeners();
  }

  void setFoulMode(FoulMode mode) {
    foulMode = mode;
    resetBreakFoulError();
    notifyListeners();
  }

  // Toggle Safe Mode
  void onSafe() {
    if (!isSafeMode) {
      // ENTER Safe Mode
      isSafeMode = true;
      notifyListeners();
    } else {
      // CONFIRM Standard Safe (No ball tap, just safe button)
      _pushState();
      
      // Mark inning as having safe (statistical)
      currentPlayer.inningHasSafe = true;
      currentPlayer.incrementSaves();
      
      _logAction('${currentPlayer.name}: Safe (Standard)');

      foulMode = FoulMode.none;
      isSafeMode = false; // Reset mode
      resetBreakFoulError();

      eventQueue.add(SafeEvent()); // Queue animation
      _switchPlayer(); // This will call _finalizeInning
      notifyListeners();
    }
  }

  void onBallTapped(int ballNumber) {
    _pushState();
    if (!gameStarted) {
      gameStarted = true;
      startGameTimer();
    }

    // Capture foul mode before reset
    final currentFoulMode = foulMode;
    final currentSafeMode = isSafeMode;
    foulMode = FoulMode.none; // Reset flag
    isSafeMode = false; // Reset flag
    resetBreakFoulError();

    // Calculate points (balls pocketed)
    int currentBallCount = activeBalls.length;
    int newBallCount = ballNumber;
    int ballsPocketed = currentBallCount - newBallCount;

    // Handle BREAK FOUL (use inning accumulation now)
    if (currentFoulMode == FoulMode.severe) {
      // Mark as break foul for notation
      currentPlayer.inningHasBreakFoul = true;
      currentPlayer.setFoulPenalty(-2); // Animate -2
      
      _logAction('${currentPlayer.name}: Break Foul (-2 pts)');
      
      // Queue animation event
      eventQueue.add(FoulEvent(currentPlayer, -2, "Break Foul!"));

      // Break Foul Decision: Who breaks next?
      final p1 = players[0];
      final p2 = players[1];

      eventQueue.add(DecisionEvent(
          "WHO BREAKS NEXT?",
          "Break Foul Rule: Decide who takes the next break shot.",
          [p1.name, p2.name], (selectedIndex) {
        final selectedPlayer = selectedIndex == 0 ? p1 : p2;

        // Switch to selected player if needed
        if (currentPlayer != selectedPlayer) {
          _switchPlayer();
        } else {
          // Same player continues, but still need to finalize this inning
          _finalizeInning(currentPlayer);
          currentPlayer.incrementInning();
        }

        // Reset rack for break
        _updateRackCount(15);
        notifyListeners();
      }));

      // Stay in break sequence
      inBreakSequence = true;
      
      // Update rack
      _updateRackCount(newBallCount);
      _checkWinCondition();
      notifyListeners();
      return; // Break foul handled, exit
    }

    // Exit break sequence (any non-break-foul action)
    inBreakSequence = false;

    // ACCUMULATE POINTS IN INNING
    currentPlayer.addInningPoints(ballsPocketed);

    // TRACK FOUL
    if (currentFoulMode == FoulMode.normal) {
      currentPlayer.inningHasFoul = true;
      currentPlayer.setFoulPenalty(-1); // Animate -1
    }

    // TRACK SAFE (statistical only)
    if (currentSafeMode) {
      currentPlayer.inningHasSafe = true;
      currentPlayer.incrementSaves(); // For statistics
    }

    // HANDLE RE-RACK
    bool isReRack = false;
    if (newBallCount == 1) {
      isReRack = true;
      // Save pre-rerack points
      currentPlayer.reRackPoints = currentPlayer.inningPoints;
      currentPlayer.inningPoints = 0; // Reset for post-rerack
      currentPlayer.inningHasReRack = true;
      
      // Queue re-rack animation event
      eventQueue.add(ReRackEvent("Re-rack!"));
      
      _logAction('${currentPlayer.name}: Re-rack');
      
      // CRITICAL LOGIC: 
      // Do NOT update rack to just 1 ball in the set of activeBalls immediately if we want it to persist visually?
      // Actually, if activeBalls = {1}, then only ball 1 is shown.
      // The user issue is "Rerack still removes the balls and does not make them opaque."
      // In 14.1, you leave the break ball (the last ball).
      // If we just set activeBalls = {1}, the other 14 are gone. 
      // The user might mean they want the RACK to fade out but the BALL 1 to stay solid?
      // Currently `_updateRackCount` wipes the set and rebuilds it.
      // If newBallCount is 1, activeBalls becomes {1}. 
      // This means balls 2-15 disappear instantly.
      // The user wants them to be greyed out or opacity change?
      // "does not make them opaque" implies they are transparent/gone.
      // "When tapping 1, 1 should stay active."
      
      // Wait, let's look at `_updateRackCount`.
      // It does: activeBalls = Set.from(List.generate(count, (i) => i + 1));
      
      // If we want ball 1 to stay, we should set count to 1.
      // Ball 1 will remain visible. 2-15 are removed from activeBalls, so they gain opacity 0.4 or 0.
      
      // Let's check GameScreen opacity logic:
      // !isOnTable ? 0.4 : (isInteractable ? 1.0 : 0.4)
      
      // If Ball 2 is NOT in activeBalls, isOnTable is false => Opacity 0.4.
      // User says "removes the balls". Maybe 0.4 is too light or they are invisible?
      // Wait, earlier fix: "Pocketed balls become invisible instead of greyed out" was fixed by setting 0.4.
      
      // "Rerack still removes the balls" -> This might mean they disappear COMPLETELY?
      // If Ball 1 is the ONLY active ball, then balls 2-15 are !isOnTable.
      // If !isOnTable opacity is 0.4, they should be visible grey ghosts.
      // Unless the re-rack overlay covers them? No, it's transparent.
      
      // "When tapping 1, 1 should stay active."
      // With count=1, Ball 1 IS in activeBalls. isOnTable=true.
      // isInteractable = !gameOver && isOnTable && (!severe || ball==15).
      // So Ball 1 IS interactable -> Opacity 1.0.
      
      // Why does user say "removes the balls"?
      // Ah, maybe they mean the animation `ReRackEvent`?
      // Does `ReRackOverlay` hide the rack? It's just a center popup.
      
      // Let's assume the user wants the "pocketed" balls (2-15) to NOT disappear instantly but fade out?
      // Or maybe they mean "removes the balls" = "balls disappear from screen".
      // If opacity 0.4 is working, they shouldn't disappear.
      
      // Let's ensure Ball 1 is indeed the one kept.
      // `_updateRackCount(1)` makes activeBalls = {1}. Correct.
      
      // Re-read: "Rerack still removes teh balls and dows not make them opaque."
      // "does not make them opaque" -> maybe they ARE opaque (invisible)?
      // If opacity is 0.0, they are invisible.
      // I set it to 0.4 in step 1162.
      
      // Maybe `_resetRack()` is called too early?
      // `finalizeReRack` calls `_resetRack` which sets count to 15.
      
      // Issue might be `onDoubleSack` vs `onBallTapped(1)`.
      // `onBallTapped(ballNumber)` calls `_updateRackCount(newBallCount)`.
      // If I tap Ball 1 (leaving 1 ball), newBallCount = 1.
      // `activeBalls` becomes {1}.
      // Balls 2-15 are removed. Opacity -> 0.4.
      
      // Maybe the user wants the other balls to stay visible as "pocketed"?
      // "make them opaque". Opaque = Solid (1.0). Transparent = Invisible (0.0).
      // Maybe user misused "opaque"? "make them opaque" usually means "make them visible".
      // "removes the balls" -> they are gone.
      // "does not make them opaque" -> they are transparent?
      
      // "When tapping 1, 1 should stay active."
      // Maybe they mean Ball 1 should be clickable? It IS clickable if active.
      
      // Let's just pass `newBallCount` to `_updateRackCount`.
      _updateRackCount(newBallCount);
    } else {
       // Only update rack if NOT a re-rack event triggering immediately?
       // No, we must update rack to reflect the shot.
       _updateRackCount(newBallCount);
    }

    // DETERMINE IF TURN ENDS
    bool turnEnded = false;

    if (currentFoulMode == FoulMode.normal) {
      // Normal foul always ends turn
      turnEnded = true;
    } else if (ballsPocketed > 0) {
      // Pocketed balls
      if (isReRack) {
        // Re-rack: player continues
        turnEnded = false;
      } else {
        // Normal shot: turn ends
        turnEnded = true;
      }
    } else if (ballsPocketed <= 0) {
      // Miss/Safe (0 or negative points)
      turnEnded = true;
      if (ballsPocketed == 0 && !currentSafeMode) {
        _logAction('${currentPlayer.name}: Miss (0 pts)');
      }
    }

    // Log action for match history
    if (ballsPocketed != 0 || currentFoulMode != FoulMode.none) {
      String foulText = currentFoulMode == FoulMode.normal ? ' (Foul)' : '';
      String safeText = currentSafeMode ? ' (Safe)' : '';
      String sign = ballsPocketed > 0 ? "+" : "";
      _logAction(
          '${currentPlayer.name}: $sign$ballsPocketed balls$foulText$safeText (Left: $newBallCount)');
    }

    _checkWinCondition();

    if (turnEnded) {
      _switchPlayer();
    }

    notifyListeners();
  }

  void _updateRackCount(int count) {
    if (count < 0) count = 0;
    if (count > 15) count = 15;
    activeBalls = Set.from(List.generate(count, (i) => i + 1));
  }

  // Called by UI after Splash animation to physically reset the rack
  void finalizeReRack() {
    _resetRack();
  }

  void onDoubleSack() {
    _pushState();
    if (!gameStarted) {
      gameStarted = true;
      startGameTimer();
    }

    final currentFoulMode = foulMode;
    foulMode = FoulMode.none;
    resetBreakFoulError();

    // Award points based on actual balls remaining on table
    int ballsRemaining = activeBalls.length;
    
    // ACCUMULATE POINTS IN INNING (like onBallTapped)
    currentPlayer.addInningPoints(ballsRemaining);
    
    // TRACK FOULS
    if (currentFoulMode == FoulMode.normal) {
      currentPlayer.inningHasFoul = true;
    } else if (currentFoulMode == FoulMode.severe) {
      currentPlayer.inningHasBreakFoul = true;
    }
    
    // Mark as re-rack (double sack implies re-rack)
    currentPlayer.inningHasReRack = true;
    
    // Log action
    String foulText = currentFoulMode == FoulMode.normal ? ' (Foul)' 
                    : currentFoulMode == FoulMode.severe ? ' (Break Foul)' 
                    : '';
    _logAction('${currentPlayer.name}: Double-sack! $ballsRemaining balls$foulText');

    // Check win BEFORE potentially switching player
    _checkWinCondition();

    // Double Sack: Player continues turn (unless foul)
    // Turn ends if there was a foul
    if (currentFoulMode != FoulMode.none) {
      _switchPlayer(); // This will call _finalizeInning
    }
    // If no foul, player continues (inning stays open for next shot)
    
    // Explicitly Clear Balls and Trigger Re-Rack Animation
    activeBalls.clear(); 
    eventQueue.add(ReRackEvent('14.1 Re-Rack'));
    
    notifyListeners();
  }

  // Helper to log actions with inning tracking
  void _logAction(String action) {
    // Get current player's inning number
    int currentInning = currentPlayer.currentInning;

    // Prefix with inning marker: "I{inning} | {action}"
    String logEntry = 'I$currentInning | $action';

    lastAction = logEntry;
    matchLog.insert(0, logEntry); // Newest first
    notifyListeners();
  }

  // Finalize the current player's inning: calculate score, apply multipliers/fouls, generate notation
  void _finalizeInning(Player player) {
    // Skip if no actions taken in this inning
    if (player.inningPoints == 0 && !player.inningHasFoul && !player.inningHasBreakFoul && !player.inningHasSafe) {
      return;
    }
    
    int totalInningPoints = player.inningPoints;
    
    // Apply handicap multiplier to positive points only
    if (totalInningPoints > 0) {
      totalInningPoints = (totalInningPoints * player.handicapMultiplier).round();
    }
    
    // Apply foul penalties
    int foulPenalty = 0;
    if (player.inningHasBreakFoul) {
      // Break foul: -2 points, doesn't count toward 3-foul rule
      foulPenalty = foulTracker.applySevereFoul(player);
      totalInningPoints += foulPenalty; // foulPenalty is -2
    } else if (player.inningHasFoul) {
      // Normal foul: -1 or -16 (if 3rd consecutive)
      foulPenalty = foulTracker.applyNormalFoul(player);
      totalInningPoints += foulPenalty; // foulPenalty is negative
    } else {
      // Valid shot resets consecutive fouls
      player.consecutiveFouls = 0;
    }
    
    // Update player score
    player.score += totalInningPoints;
    player.lastPoints = totalInningPoints;
    player.updateCount++;
    
    // Update current run
    if (totalInningPoints > 0) {
      player.currentRun += totalInningPoints;
      if (player.currentRun > player.highestRun) {
        player.highestRun = player.currentRun;
      }
    }
    
    // Generate notation
    String notation = _generateInningNotation(player);
    
    // Create inning record
    inningRecords.add(InningRecord(
      inning: player.currentInning,
      playerName: player.name,
      notation: notation,
      runningTotal: player.score,
    ));
  }
  
  // Generate score card notation for an inning
  String _generateInningNotation(Player player) {
    String notation = '';
    
    // Handle re-rack notation (X.Y format)
    if (player.inningHasReRack) {
      // Apply multiplier to pre-rerack points
      int preRerackPoints = player.reRackPoints;
      if (preRerackPoints > 0) {
        preRerackPoints = (preRerackPoints * player.handicapMultiplier).round();
      }
      
      // Apply multiplier to post-rerack points
      int postRerackPoints = player.inningPoints;
      if (postRerackPoints > 0) {
        postRerackPoints = (postRerackPoints * player.handicapMultiplier).round();
      }
      
      notation = '$preRerackPoints.$postRerackPoints';
    } else {
      // Simple notation: just the points
      int points = player.inningPoints;
      if (points > 0) {
        points = (points * player.handicapMultiplier).round();
      }
      
      if (points == 0 && !player.inningHasFoul && !player.inningHasBreakFoul && !player.inningHasSafe) {
        notation = '-'; // Miss/no action
      } else {
        notation = points.toString();
      }
    }
    
    // Add safe suffix
    if (player.inningHasSafe) {
      notation += 'S';
    }
    
    // Add foul suffix (BF for break foul, F for normal foul)
    if (player.inningHasBreakFoul) {
      notation += 'BF';
    } else if (player.inningHasFoul) {
      notation += 'F';
    }
    
    return notation;
  }

  void _switchPlayer() {
    // Finalize current player's inning before switching
    _finalizeInning(currentPlayer);
    currentPlayer.isActive = false;
    currentPlayer.incrementInning();

    // Switch
    currentPlayerIndex = 1 - currentPlayerIndex;

    currentPlayer.isActive = true;

    // Check for 2-Foul Warning upon entering turn
    if (foulTracker.threeFoulRuleEnabled &&
        currentPlayer.consecutiveFouls == 2) {
      // Replaced showTwoFoulWarning flag with Event
      eventQueue.add(WarningEvent("2 FOULS!",
          "You are on 2 consecutive fouls.\nOne more foul will result in a \n-15 points penalty!"));
    }

    notifyListeners();
  }

  // Method to consume events (UI calls this)
  List<GameEvent> consumeEvents() {
    final events = List<GameEvent>.from(eventQueue);
    eventQueue.clear();
    return events;
  }

  // Allow swapping starting player before game starts
  void swapStartingPlayer() {
    if (gameStarted || matchLog.isNotEmpty) return; // Only allow at start

    _pushState();

    // Deactivate current
    players[currentPlayerIndex].isActive = false;

    // Swap index
    currentPlayerIndex = 1 - currentPlayerIndex;

    // Activate new
    players[currentPlayerIndex].isActive = true;

    _logAction('Starting Player Swapped to ${currentPlayer.name}');
    // Clear log because we just added an action but game hasn't "started" for scoring purposes?
    // Actually, swapping starting player shouldn't be in match log usually?
    // Or maybe it is fine. But "gameStarted" flag triggers on first shot.
    // If we log it, matchLog is not empty, so next swap fails.
    // Let's NOT log it, or clear log.
    matchLog.clear();
    notifyListeners();
  }

  void _checkWinCondition() {
    // Check ALL players for win (in case of edge cases)
    for (var player in players) {
      if (player.score >= raceToScore && !gameOver) {
        gameOver = true;
        winner = player;
        _logAction('${player.name} WINS! 🎉');
        // TODO: Trigger win achievements in future
        notifyListeners();
        return; // Exit after first winner found
      }
    }
  }

  void resetGame() {
    _pushState();
    for (var player in players) {
      player.score = 0;
      player.currentInning = 1;
      player.saves = 0;
      player.isActive = false;
    }
    players[0].isActive = true;
    currentPlayerIndex = 0;
    foulTracker.reset();
    _resetRack();
    gameStarted = false;
    gameOver = false;
    winner = null;
    lastAction = null;
    showThreeFoulPopup = false;
    showTwoFoulWarning = false;
    foulMode = FoulMode.none;
    matchLog.clear();
    // We do NOT clear undo stack, so reset can be undone!
    resetBreakFoulError();
    inBreakSequence = true; // Reset Break Sequence Logic
    notifyListeners();
  }

  Map<String, dynamic> toJson() => GameSnapshot.fromState(this).toJson();

  void loadFromJson(Map<String, dynamic> json) {
    final snapshot = GameSnapshot.fromJson(json);
    snapshot.restore(this);

    // Resume timer if game was in progress and we just loaded it
    // But wait! snapshot restores 'gameStarted'.
    // Should we auto-resume timer?
    // Probably yes, but let's pause it initially to be safe?
    // Or effectively "resume" the stopwatch if it was running?
    // Since Stopwatch doesn't persist, we rely on 'elapsed' if we persisted it.
    // Current implementation doesn't persist 'elapsed' yet.
    // Let's add that to GameSnapshot first.
    notifyListeners();
  }
}

abstract class UndoState {
  void restore(GameState state);
}

class GameSnapshot implements UndoState {
  final List<Player> players;
  final Set<int> activeBalls;
  final int currentPlayerIndex;
  final bool gameStarted;
  final bool gameOver;
  final String? winnerName;
  final String? lastAction;
  final bool showThreeFoulPopup;
  final FoulMode foulMode;
  final List<String> matchLog;
  final List<InningRecord> inningRecords; // NEW: For score card
  final String breakFoulHintMessage;
  final bool inBreakSequence;
  final int elapsedDurationInSeconds;

  GameSnapshot.fromState(GameState state)
      : players = state.players.map((p) => p.copyWith()).toList(),
        activeBalls = Set.from(state.activeBalls),
        currentPlayerIndex = state.currentPlayerIndex,
        gameStarted = state.gameStarted,
        gameOver = state.gameOver,
        winnerName = state.winner?.name,
        lastAction = state.lastAction,
        showThreeFoulPopup = state.showThreeFoulPopup,
        foulMode = state.foulMode,
        matchLog = List.from(state.matchLog),
        inningRecords = List.from(state.inningRecords),
        breakFoulHintMessage = state.breakFoulHintMessage,
        inBreakSequence = state.inBreakSequence,
        elapsedDurationInSeconds = state.elapsedDuration.inSeconds;

  GameSnapshot.fromJson(Map<String, dynamic> json)
      : players =
            (json['players'] as List).map((e) => Player.fromJson(e)).toList(),
        activeBalls = Set<int>.from(json['activeBalls'] as List),
        currentPlayerIndex = json['currentPlayerIndex'] as int,
        gameStarted = json['gameStarted'] as bool,
        gameOver = json['gameOver'] as bool? ?? false,
        winnerName = json['winnerName'] as String?,
        lastAction = json['lastAction'] as String?,
        showThreeFoulPopup = json['showThreeFoulPopup'] as bool,
        foulMode = (json['foulMode'] as int?) != null &&
                (json['foulMode'] as int) < FoulMode.values.length
            ? FoulMode.values[json['foulMode'] as int]
            : FoulMode.none,
        matchLog = List<String>.from(json['matchLog'] as List),
        inningRecords = (json['inningRecords'] as List? ?? [])
            .map((e) => InningRecord.fromJson(e))
            .toList(),
        breakFoulHintMessage = json['breakFoulHintMessage'] as String,
        inBreakSequence = json['inBreakSequence'] as bool? ?? true,
        elapsedDurationInSeconds =
            json['elapsedDurationInSeconds'] as int? ?? 0;

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'activeBalls': activeBalls.toList(),
        'currentPlayerIndex': currentPlayerIndex,
        'gameStarted': gameStarted,
        'gameOver': gameOver,
        'winnerName': winnerName,
        'lastAction': lastAction,
        'showThreeFoulPopup': showThreeFoulPopup,
        'foulMode': foulMode.index,
        'matchLog': matchLog,
        'inningRecords': inningRecords.map((r) => r.toJson()).toList(),
        'breakFoulHintMessage': breakFoulHintMessage,
        'inBreakSequence': inBreakSequence,
        'elapsedDurationInSeconds': elapsedDurationInSeconds,
      };

  @override
  void restore(GameState state) {
    state.players = players.map((p) => p.copyWith()).toList();
    state.activeBalls = Set.from(activeBalls);
    state.currentPlayerIndex = currentPlayerIndex;
    state.gameStarted = gameStarted;
    state.gameOver = gameOver;
    // Restore winner by finding player with matching name
    state.winner = winnerName != null
        ? state.players.firstWhere((p) => p.name == winnerName,
            orElse: () => state.players[0])
        : null;
    state.lastAction = lastAction;
    state.showThreeFoulPopup = showThreeFoulPopup;
    state.inBreakSequence = inBreakSequence;
    state.foulMode = foulMode;
    state.matchLog = List.from(matchLog);
    state.inningRecords = List.from(inningRecords);
    state.breakFoulHintMessage = breakFoulHintMessage;

    // Restore Timer
    state._savedDuration = Duration(seconds: elapsedDurationInSeconds);
    state._gameTimer.reset();
  }
}
