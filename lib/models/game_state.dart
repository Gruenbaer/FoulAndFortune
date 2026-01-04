import 'package:flutter/foundation.dart';
import 'dart:async';
import 'foul_tracker.dart';
import 'achievement_manager.dart';
import '../data/messages.dart';
import 'game_settings.dart';
import '../services/achievement_checker.dart';

enum FoulMode { none, normal, severe }
enum FoulType { normal, breakFoul, threeFouls }

// Event System for UI Animations
abstract class GameEvent {}

class FoulEvent extends GameEvent {
  final Player player;
  final int points;
  final FoulType type;
  final int? positivePoints; // Optional: balls pocketed for breakdown display
  final int? penalty; // Optional: foul penalty for breakdown display

  FoulEvent(this.player, this.points, this.type,
      {this.positivePoints, this.penalty});
}

class TwoFoulsWarningEvent extends GameEvent {}

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

class BreakFoulDecisionEvent extends GameEvent {
    final List<String> options;
    final Function(int) onOptionSelected;
    BreakFoulDecisionEvent(this.options, this.onOptionSelected);
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

    // Capture state before reset
    final currentFoulMode = foulMode;
    final currentSafeMode = isSafeMode;
    
    // VALIDATION: Check for illegal move combinations
    if (currentFoulMode == FoulMode.normal) {
      // "The Lone Ranger Foul": Cannot foul and leave 1 ball
      if (ballNumber == 1) {
        debugPrint('ERROR: Illegal move - cannot foul and tap ball 1');
        eventQueue.add(WarningEvent(
          'illegalMoveTitle',
          'cannotFoulAndLeave1Ball'
        ));
        // Reset state and return early
        foulMode = FoulMode.none;
        notifyListeners();
        return;
      }
      // "The Penalized Perfection": Cannot foul and clear the table
      if (ballNumber == 0) {
        debugPrint('ERROR: Illegal move - cannot foul and tap white ball (0)');
        eventQueue.add(WarningEvent(
          'illegalMoveTitle',
          'cannotFoulAndDoubleSack'
        ));
        // Reset state and return early
        foulMode = FoulMode.none;
        notifyListeners();
        return;
      }
    }
    
    // Reset temporary modes
    foulMode = FoulMode.none;
    isSafeMode = false;
    resetBreakFoulError();

    // Calculate basic data
    int currentBallCount = activeBalls.length;
    int newBallCount = ballNumber;
    int ballsPocketed = currentBallCount - newBallCount;

    // --- CASE 1: BREAK FOUL (Severe) ---
    if (currentFoulMode == FoulMode.severe) {
      // Mark as break foul (-2 points)
      currentPlayer.inningHasBreakFoul = true;
      currentPlayer.setFoulPenalty(-2);
      
      _logAction('${currentPlayer.name}: Break Foul (-2 pts)');
      eventQueue.add(FoulEvent(currentPlayer, -2, FoulType.breakFoul));

      // Decision: Who breaks next?
      final p1 = players[0];
      final p2 = players[1];
      
      eventQueue.add(BreakFoulDecisionEvent(
        [p1.name, p2.name],
        (selectedIndex) {
             handleBreakFoulDecision(selectedIndex);
        }
      ));
      
      inBreakSequence = true;
      _updateRackCount(15);
      
      // Finalize current inning immediately
      _finalizeInning(currentPlayer);
      currentPlayer.incrementInning();
      
      _checkWinCondition();
      notifyListeners();
      return; 
    }

    // --- CASE 2: NORMAL SHOT ---
    inBreakSequence = false;

    // ACCUMULATE POINTS
    // ACCUMULATE POINTS
    currentPlayer.addInningPoints(ballsPocketed);

    // TRACK FOUL
    if (currentFoulMode == FoulMode.normal) {
      currentPlayer.inningHasFoul = true;
      currentPlayer.setFoulPenalty(-1);
      
      // Always add Normal Foul (-1) event first
      eventQueue.add(FoulEvent(currentPlayer, -1, FoulType.normal));

      // Check if this will be the 3rd foul AFTER applying the foul logic
      // The foul tracker will handle incrementing/resetting based on ballsPocketed
      // We need to check BEFORE calling applyNormalFoul in _finalizeInning
      // For now, we'll determine if 3-foul penalty applies based on current count + foul type
      // This check will be properly done in _finalizeInning where we have all the data
    }

    // TRACK SAFE
    if (currentSafeMode) {
      currentPlayer.inningHasSafe = true;
      currentPlayer.incrementSaves();
    }

    // HANDLE RE-RACK
    bool isReRack = false;
    if (newBallCount == 1) {
      isReRack = true;
      // Add current inning points to history segment
      currentPlayer.inningHistory.add(currentPlayer.inningPoints);
      currentPlayer.inningPoints = 0; 
      currentPlayer.inningHasReRack = true;
      
      eventQueue.add(ReRackEvent("reRack"));
      _logAction('${currentPlayer.name}: Re-rack');
      _updateRackCount(newBallCount);
    } else {
      _updateRackCount(newBallCount);
    }

    // DETERMINE IF TURN ENDS
    // Simple rule: Turn ends on every tap EXCEPT re-rack (ball 1)
    bool turnEnded = false;

    if (isReRack) {
      // Re-rack (ball 1): Player continues their run
      turnEnded = false;
    } else {
      // Logic for standard shots:
      // Turn continues if:
      // 1. Balls were pocketed (> 0)
      // 2. NO standard foul
      // 3. NO safe declared
      bool isPot = ballsPocketed > 0;
      bool isFoul = currentPlayer.inningHasFoul;
      bool isSafe = currentPlayer.inningHasSafe;
      
      if (isPot && !isFoul && !isSafe) {
         turnEnded = false;
      } else {
         turnEnded = true; 
         
          // Log explicit Miss if no points scored and not Safe/Foul
          if (ballsPocketed == 0 && !isSafe && !isFoul) {
             _logAction('${currentPlayer.name}: Miss (0 pts)');
          }
      }
    }

    // LOGGING
    if (ballsPocketed != 0 || currentFoulMode != FoulMode.none) {
      String foulText = currentFoulMode == FoulMode.normal ? ' (Foul)' : '';
      String safeText = currentSafeMode ? ' (Safe)' : '';
      String sign = ballsPocketed > 0 ? "+" : "";
      _logAction(
          '${currentPlayer.name}: $sign$ballsPocketed balls$foulText$safeText (Left: $newBallCount)');
    }

    _checkWinCondition();

    _checkWinCondition();

    if (turnEnded) {
      _switchPlayer();
      // Check again after switching - score update happens in _finalizeInning
      _checkWinCondition();
    }

    notifyListeners();
  }

  void handleBreakFoulDecision(int selectedIndex) {
      // selectedIndex: 0 = Player 1, 1 = Player 2 (based on names array)
      if (selectedIndex != currentPlayerIndex) {
          // Switch active player manually
          players[currentPlayerIndex].isActive = false;
          currentPlayerIndex = selectedIndex; // Set to new player
          players[currentPlayerIndex].isActive = true;
          
          _logAction('Decision: ${currentPlayer.name} will break');
      } else {
          _logAction('Decision: ${currentPlayer.name} re-breaks');
      }
      
      inBreakSequence = true;
      _updateRackCount(15);
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
    
    // VALIDATION: "The Penalized Perfection" - Cannot foul and clear the table
    if (currentFoulMode == FoulMode.normal) {
      debugPrint('ERROR: Illegal move - cannot foul and tap white ball (double sack)');
      eventQueue.add(WarningEvent(
        'illegalMoveTitle',
        'cannotFoulAndDoubleSack'
      ));
      // Reset state and return early
      foulMode = FoulMode.none;
      notifyListeners();
      return;
    }
    
    foulMode = FoulMode.none;
    resetBreakFoulError();

    // Award points based on actual balls remaining on table
    int ballsRemaining = activeBalls.length;
    
    // ACCUMULATE POINTS IN INNING (like onBallTapped)
    currentPlayer.addInningPoints(ballsRemaining);
    
    // Push current points to history (Double Sack completes the rack)
    currentPlayer.inningHistory.add(currentPlayer.inningPoints);
    currentPlayer.inningPoints = 0;
    
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
    // Reset rack to 15 balls for next shot
    _resetRack(); 
    eventQueue.add(ReRackEvent('reRack'));
    
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
    // SKIP CHECK REMOVED:
    // Even if no points/fouls/safe occurred, if this method is called (via _switchPlayer),
    // it implies the turn has ended (e.g. a Miss). 
    // We MUST proceed to reset consecutive fouls and record the inning.
    /*
    if (player.inningPoints == 0 && !player.inningHasFoul && !player.inningHasBreakFoul && !player.inningHasSafe) {
      return;
    }
    */
    
    // Calculate points from both parts of the inning (pre and post re-rack)
    // Calculate points from all segments + current
    int pointsInInning = player.inningPoints;
    
    int addedPoints = 0;
    
    // 1. Process History Segments (Re-racks)
    for (int segmentPoints in player.inningHistory) {
      if (segmentPoints > 0) {
        addedPoints += (segmentPoints * player.handicapMultiplier).round();
      }
    }
    
    // 2. Process Current Active Segment
    if (pointsInInning > 0) {
      addedPoints += (pointsInInning * player.handicapMultiplier).round();
    }
    
    int totalInningPoints = addedPoints;
    
    // Apply foul penalties
    int foulPenalty = 0;
    if (player.inningHasBreakFoul) {
      // Break foul: -2 points, doesn't count toward 3-foul rule
      foulPenalty = foulTracker.applySevereFoul(player);
      totalInningPoints += foulPenalty; // foulPenalty is -2
    } else if (player.inningHasFoul) {
      // Normal foul: -1 or -16 (if 3rd consecutive)
      // Calculate total balls pocketed in this inning (pre-rerack + post-rerack)
      // Calculate total balls pocketed in this inning (history + current)
      int totalRawPoints = player.inningHistory.fold(0, (sum, p) => sum + p) + pointsInInning;
      
      // Check if this will trigger the 3-foul penalty BEFORE applying
      bool willTriggerThreeFouls = false;
      if (foulTracker.threeFoulRuleEnabled) {
        // Simulate the logic: if no balls pocketed and already at 2, this makes 3
        if (totalRawPoints == 0 && player.consecutiveFouls == 2) {
          willTriggerThreeFouls = true;
        }
      }
      
      foulPenalty = foulTracker.applyNormalFoul(player, totalRawPoints);
      totalInningPoints += foulPenalty; // foulPenalty is negative
      
      // Add 3-foul event if triggered
      if (willTriggerThreeFouls) {
        player.inningHasThreeFouls = true; // Mark for notation "TF"
        eventQueue.add(FoulEvent(player, -15, FoulType.threeFouls));
      }
    } else {
      // Valid shot (no foul) resets consecutive fouls
      player.consecutiveFouls = 0;
    }
    
    // Update player score
    player.score += totalInningPoints;
    player.lastPoints = totalInningPoints;
    player.lastRun = totalInningPoints; // Persist for "LR" display
    debugPrint('DEBUG: _finalizeInning - Total: $totalInningPoints, lastRun Set To: ${player.lastRun}, currentRun before: ${player.currentRun}');
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
    
    // Check for achievements after inning
    if (achievementManager != null) {
      AchievementChecker.checkAfterInning(player, achievementManager!);
    }
  }

  // Helper to calculate the REAL-TIME net score of the current inning
  // Used for the "LR" box to show "15 + 14 - 1 = 28"
  int getDynamicInningScore(Player player) {
     // Base Points (Current Rack + Previous Racks in this inning)
     int total = player.inningPoints + player.inningHistory.fold(0, (prev, element) => prev + element);
     
     // Apply Handicap
     if (total > 0) {
       total = (total * player.handicapMultiplier).round();
     }
     
     // Apply PENDING foul penalties (if currently selected but not yet finalized)
     // Only applies if the player is currently taking their turn (isActive)
     
     return total;
  }
  
  // Generate score card notation for an inning
  String _generateInningNotation(Player player) {
    String notation = '';
    List<String> segments = [];
    
    // 1. Process History Segments (completed racks)
    for (int segmentPoints in player.inningHistory) {
      int adjusted = segmentPoints;
      if (adjusted > 0) {
        adjusted = (adjusted * player.handicapMultiplier).round();
      }
      
      // RULE: 14 balls = '|'
      if (adjusted == 14) {
        segments.add('|');
      } else {
        segments.add(adjusted.toString());
      }
    }
    
    // 2. Process Current Active Segment
    int currentPoints = player.inningPoints;
    if (currentPoints > 0) {
      currentPoints = (currentPoints * player.handicapMultiplier).round();
    }
    
    // Only show current points if > 0 OR if it's the only thing (no history)
    // If we have history (re-rack), we join with bullet.
    // If currentPoints is 0 but we have a miss/foul/safe, we might just append suffix?
    // The requested format is "15.|.5SF" -> "15", "|", "5" joined by dots/bullets.
    
    if (currentPoints > 0 || segments.isEmpty) {
        // Special case: Miss (0 points) with no history -> '-'
        if (currentPoints == 0 && segments.isEmpty && 
            !player.inningHasFoul && !player.inningHasBreakFoul && !player.inningHasSafe) {
             segments.add('-');
        } else {
             // If we have history but 0 current points, do we show '0'? 
             // Example: "14.|" (missed immediately after break).
             // User example: "15.|.5SF".
             // If I have "15" and then miss (0), notation is "15." or "15.0"?
             // Standard usually implies just the run.
             if (currentPoints > 0 || segments.isEmpty) {
                segments.add(currentPoints.toString());
             }
        }
    } else {
        // Case: History exists (re-rack) but current points are 0.
        // Append empty string to create trailing bullet (e.g. "5•")
        segments.add('');
    }
    
    // Join all segments with bullet
    notation = segments.join('•');
    
    // Add safe suffix
    if (player.inningHasSafe) {
      notation += 'S';
    }
    
    // Add foul suffix (BF for break foul, TF for triple foul, F for normal foul)
    if (player.inningHasBreakFoul) {
      notation += 'BF';
    } else if (player.inningHasThreeFouls) {
      notation += 'TF';
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
      eventQueue.add(TwoFoulsWarningEvent());
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
      // Check PROJECTED score (Current run + Banked) for immediate win
      if (player.projectedScore >= raceToScore && !gameOver) {
        gameOver = true;
        winner = player;
        _stopTicker();
        
        // Finalize the winning inning to lock in the score
        _finalizeInning(player);
        
        _logAction('${player.name} WINS! 🎉');
        
        // Check win-related achievements
        if (achievementManager != null) {
          AchievementChecker.checkAfterWin(player, this, achievementManager!);
        }
        
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
