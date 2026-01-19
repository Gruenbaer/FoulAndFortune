import 'package:flutter/foundation.dart';
import 'foul_tracker.dart';
import '../core/game_timer.dart';
import 'achievement_manager.dart';
import '../data/messages.dart';
import 'game_settings.dart';
import '../services/achievement_checker.dart';
import '../codecs/notation_codec.dart';

enum FoulMode { none, normal, severe }
// FoulType now imported from '../codecs/notation_codec.dart'
// (includes: none, normal, breakFoul, threeFouls)

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
// InningRecord is now imported from '../codecs/notation_codec.dart'
// (Extended version with segments, safe, foul fields)

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
  
  void concedeGame(Player assignedWinner) {
    _pushState(); // Save state before ending
    
    // Finalize the current inning to commit any pending points/fouls
    // This ensures the scorecard on Victory screen matches the board
    _finalizeInning(currentPlayer);
    
    winner = assignedWinner;
    gameOver = true;
    _logAction('Game Conceded. Winner: ${assignedWinner.name}');
    notifyListeners();
    onSaveRequired?.call();
  }

  String? lastAction;

  bool showThreeFoulPopup = false;
  bool showTwoFoulWarning = false;

  // Foul Mode Flag
  FoulMode foulMode = FoulMode.none;
  // Safe Mode Toggle
  bool isSafeMode = false;

  // Break Sequence Flag (True at start, false after first valid shot)
  bool inBreakSequence = true;
  
  // Break Foul Eligibility Tracking
  int? breakingPlayerIndex; // Who started the match (can commit break fouls)
  bool breakFoulStillAvailable = true; // Permanently disabled after first ball potted or player switch

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
  // Only available at match start for the breaking player, before any balls potted or player switch
  bool get canBreakFoul {
    // Must be in break sequence
    if (!inBreakSequence) return false;
    
    // Must not be permanently disabled
    if (!breakFoulStillAvailable) return false;
    
    // If no breaking player set yet, it's available (first action of game)
    if (breakingPlayerIndex == null) return true;
    
    // Only the breaking player can commit break fouls
    return breakingPlayerIndex == currentPlayerIndex;
  }
  bool get canRedo => _redoStack.isNotEmpty;
  
  // Auto-Save Callback
  VoidCallback? onSaveRequired;

  // Game Clock (extracted to GameTimer)
  final GameTimer _gameTimer = GameTimer();

  bool get isPaused => _gameTimer.isPaused;
  Duration get elapsedDuration => _gameTimer.elapsedDuration;

  void startGameTimer() {
    if (!gameStarted) return;
    _gameTimer.start();
  }

  void pauseGame() {
    _gameTimer.pause();
    notifyListeners();
  }

  void resumeGame() {
    _gameTimer.resume();
    notifyListeners();
  }

  void togglePause() {
    _gameTimer.toggle();
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer.dispose();
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
    
    // Setup timer tick callback
    _gameTimer.onTick = () {
      notifyListeners(); // UI updates every second
    };
  }

  // Update settings mid-game
  void updateSettings(dynamic settings) {
    bool somethingChanged = false;

    // Update Race to Score
    if (raceToScore != settings.raceToScore) {
      raceToScore = settings.raceToScore;
      somethingChanged = true;
      _logAction('Race to Score changed to $raceToScore');
      onSaveRequired?.call();
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
    onSaveRequired?.call();
  }

  void dismissTwoFoulWarning() {
    showTwoFoulWarning = false;
    notifyListeners();
    onSaveRequired?.call();
  }

  void _resetRack() {
    activeBalls = Set.from(List.generate(15, (i) => i + 1));
    notifyListeners();
  }

  void manualPushState() {
    _pushState();
  }

  void _pushState() {
    _undoStack.add(GameSnapshot.fromState(this));
    _redoStack.clear(); // clear redo on new action
    // State pushed means something is about to change, so we save AFTER the change usually. 
    // But methods calling _pushState will call notifyListeners (and should call onSaveRequired).
  }



  void undo() {
    if (!canUndo) return;
    final currentSnapshot = GameSnapshot.fromState(this);
    _redoStack.add(currentSnapshot);

    final snapshot = _undoStack.removeLast();
    snapshot.restore(this);
    
    // If we're undoing from a won game, reset the game-over state
    // so the game can continue or re-detect victory
    if (gameOver) {
      gameOver = false;
      winner = null;
    }
    
    notifyListeners();
    onSaveRequired?.call();
  }

  void redo() {
    if (!canRedo) return;
    final currentSnapshot = GameSnapshot.fromState(this);
    _undoStack.add(currentSnapshot);

    final snapshot = _redoStack.removeLast();
    snapshot.restore(this);
    notifyListeners();
    onSaveRequired?.call();
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
    debugPrint('DEBUG: onBallTapped - Check FoulMode: $currentFoulMode');
    final currentSafeMode = isSafeMode;
    
    // VALIDATION: Strict Mutual Exclusion (Spec §7.3)
    if (!_validateInteraction(ballNumber)) return;
    
    // Reset temporary modes (Regular behavior for valid taps 2-15)
    foulMode = FoulMode.none;
    resetBreakFoulError();
    // Safety clear: if we tapped 2-15, safe mode naturally clears (statistical only)
    isSafeMode = false;

    // Calculate basic data
    int currentBallCount = activeBalls.length;
    int newBallCount = ballNumber;
    int ballsPocketed = currentBallCount - newBallCount;

    // --- CASE 1: BREAK FOUL (Severe) ---
    if (currentFoulMode == FoulMode.severe) {
      // Mark as break foul (-2 points)
      // Increment count (allow stacking)
      currentPlayer.inningBreakFoulCount++;
      currentPlayer.setFoulPenalty(currentPlayer.inningBreakFoulCount * -2);
      
      _logAction('${currentPlayer.name}: Break Foul #${currentPlayer.inningBreakFoulCount} (-2 pts)');
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
      
      // Do NOT finalize here! Wait for decision.
      // If decision is "Re-Rack" (Same Player), we continue to stack.
      // If decision is "Switch", we finalize then.
      
      _checkWinCondition();
      notifyListeners();
      return; 
    }

    // --- CASE 2: NORMAL SHOT ---
    inBreakSequence = false;
    
    // Set breaking player on first action if not set
    breakingPlayerIndex ??= currentPlayerIndex;
    
    // Permanently disable break fouls if any balls are potted
    if (ballsPocketed > 0 && breakFoulStillAvailable) {
      breakFoulStillAvailable = false;
    }

    // ACCUMULATE POINTS
    // ACCUMULATE POINTS
    currentPlayer.addInningPoints(ballsPocketed);

    // TRACK FOUL
    if (currentFoulMode == FoulMode.normal) {
      currentPlayer.inningHasFoul = true;
      currentPlayer.setFoulPenalty(-1);
      
      // Check if this will trigger 3-foul penalty
      // If so, DON'T add the -1 event (the -16 event includes it)
      bool willTriggerThreeFouls = false;
      if (foulTracker.threeFoulRuleEnabled && ballsPocketed == 0 && currentPlayer.consecutiveFouls == 2) {
        willTriggerThreeFouls = true;
      }
      
      // Only add -1 FoulEvent if NOT triggering three-foul penalty
      // (Three-foul event with -16 will be added in _finalizeInning)
      if (!willTriggerThreeFouls) {
        eventQueue.add(FoulEvent(currentPlayer, -1, FoulType.normal));
      }

      // The actual 3-foul logic and -16 event is handled in _finalizeInning
    }

    // TRACK SAFE
    if (currentSafeMode) {
      currentPlayer.inningHasSafe = true;
      currentPlayer.incrementSaves();
      eventQueue.add(SafeEvent()); // Show safe splash
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
      // CANONICAL: For regular re-rack (Ball 1), show ONLY the 1 ball.
      // Refill to 15 happens in finalizeReRack() after animation.
      _updateRackCount(1);
    } else {
      _updateRackCount(newBallCount);
    }

    // DETERMINE IF TURN ENDS
    // Logic update (Inning Scorer Model):
    // Turn ENDS on tap, UNLESS it is a continuation event (Re-rack).
    bool turnEnded = true; // Default to ending turn
  
    if (isReRack) { // Ball 1
      turnEnded = false;
    } else if (newBallCount == 0) {
      // Cleared table (Ball 0 Double Sack)
      turnEnded = false;
      _updateRackCount(0); // Clear immediately so balls vanish
      eventQueue.add(ReRackEvent("tableCleared"));
      _logAction('${currentPlayer.name}: Cleared table');
    } else {
      // Any other number (2-14, 15):
      turnEnded = true;
    }
  
  // Exception: If Foul or Safe, turn always ends (unless Break Foul where we might continue? No, BF logic returns earlier).
  // Actually, if I clear table (0) but fouled? "Penalized Perfection".
  // Logic at top of function catches "Cannot foul and tap 0". So we are safe.
    // LOGGING
    if (ballsPocketed != 0 || currentFoulMode != FoulMode.none) {
      String foulText = currentFoulMode == FoulMode.normal ? ' (Foul)' : '';
      String safeText = currentSafeMode ? ' (Safe)' : '';
      String sign = ballsPocketed > 0 ? "+" : "";
      _logAction(
          '${currentPlayer.name}: $sign$ballsPocketed balls$foulText$safeText (Left: $newBallCount)');
    }

    _checkWinCondition();

    // Only switch players if the game hasn't ended
    // (prevents double-finalization of winning inning)
    if (turnEnded && !gameOver) {
      _switchPlayer();
      // Check again after switching - score update happens in _finalizeInning
      _checkWinCondition();
    }

    notifyListeners();
  }

  void handleBreakFoulDecision(int selectedIndex) {
      // selectedIndex: 0 = Player 1, 1 = Player 2 (based on names array)
      if (selectedIndex != currentPlayerIndex) {
          // SWITCH: Opponent chose to break
          // Finalize the PREVIOUS player's inning (apply stacked penalties)
          _finalizeInning(currentPlayer);
          currentPlayer.incrementInning();
          
          // Switch active player manually
          players[currentPlayerIndex].isActive = false;
          currentPlayerIndex = selectedIndex; // Set to new player
          players[currentPlayerIndex].isActive = true;
          
          // Permanently disable break fouls when player switches after break foul
          breakFoulStillAvailable = false;
          
          _logAction('Decision: ${currentPlayer.name} will break');
      } else {
          // SAME PLAYER: Re-break (Stacking)
          // Do NOT finalize. Keep inning open.
          _logAction('Decision: ${currentPlayer.name} re-breaks (Inning Continues)');
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

  // Helper to validate interactions against exclusion rules
  bool _validateInteraction(int ballNumber) {
    // Continuation actions (0, 1) are disabled if ANY Terminator (Safe, Foul, Break Foul) is active.
    bool termModeActive = isSafeMode || foulMode != FoulMode.none;
    if (termModeActive && (ballNumber == 0 || ballNumber == 1)) {
        debugPrint('ERROR: Mutual Exclusion - Cannot tap 0/1 during Safe/Foul');
        eventQueue.add(WarningEvent(
          'actionRestrictedTitle', 
          'terminatorExclusionMessage' 
        ));
        // Do NOT auto-clear modes. Just reject the action.
        notifyListeners();
        return false;
    }
    return true;
  }

  void onDoubleSack() {
    _pushState();
    if (!gameStarted) {
      gameStarted = true;
      startGameTimer();
    }

    final currentFoulMode = foulMode;

    // VALIDATION: Strict Mutual Exclusion (Spec §7.3)
    if (!_validateInteraction(0)) return;
    
    foulMode = FoulMode.none;
    isSafeMode = false;
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
       // On double-sack in severe mode? Logic excludes this in _validate, 
       // but strictly speaking R0 is continuation.
       // For now, assume R0 is not possible during BF check (covered by _validateInteraction)
      currentPlayer.inningBreakFoulCount++;
    }
    
    // Mark as re-rack (double sack implies re-rack)
    currentPlayer.inningHasReRack = true;
    
    // Log action
    String foulText = currentFoulMode == FoulMode.normal ? ' (Foul)' 
                    : currentFoulMode == FoulMode.severe ? ' (Break Foul)' 
                    : '';
    _logAction('${currentPlayer.name}: Double-sack! $ballsRemaining balls$foulText');

    // Check win condition using PROJECTED score (Banked + Current Run)
  bool projectedWin = currentPlayer.projectedScore >= raceToScore;
  
  if (projectedWin) {
    // If winning, we MUST finalize to bake the points into the score
    _finalizeInning(currentPlayer);
    currentPlayer.incrementInning();
    _checkWinCondition(); // Will detect win and set gameOver
  } else if (currentFoulMode != FoulMode.none) {
    // If fouled, we MUST finalize and switch
    // Note: Double Sack + Foul is rare/illegal but handled here
    _finalizeInning(currentPlayer);
    currentPlayer.incrementInning();
    _switchPlayer();
  } else {
    // CONTINUE TURN
    // Do NOT finalize. Do NOT increment Inning.
    // Allow points to keep accumulating in currentRun for notation "15⟲..."
    
    // Safety check: ensure game is not over from some side effect
    if (!gameOver) {
       // rack reset handled below
    }
  }
    
    // Explicitly Clear Balls BEFORE Re-Rack Animation
    // So balls disappear immediately when white is tapped
    _updateRackCount(0);
    eventQueue.add(ReRackEvent('reRack'));
    // Reset rack to 15 balls happens in finalizeReRack() after animation
    
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
    onSaveRequired?.call();
  }

  // Finalize the current player's inning: calculate score, apply multipliers/fouls, generate notation
  void _finalizeInning(Player player) {
    // Skip if no actions taken in this inning
    // SKIP CHECK REMOVED:
    // Even if no points/fouls/safe occurred, if this method is called (via _switchPlayer),
    // it implies the turn has ended (e.g. a Miss). 
    // We MUST proceed to reset consecutive fouls and record the inning.
    
    // Calculate points from both parts of the inning (pre and post re-rack)
    // Calculate points from all segments + current
    debugPrint('DEBUG: _finalizeInning START for ${player.name} (HasFoul: ${player.inningHasFoul})');
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
    if (player.inningBreakFoulCount > 0) {
      // Break foul: -2 per instance
      foulPenalty = player.inningBreakFoulCount * -2;
      // Do NOT use applySevereFoul() from tracker if it only returns fixed -2, 
      // OR update tracker. But easier to calc here.
      // tracker.applySevereFoul() usually tracks count/history too?
      // FoulTracker only tracks consecutive pure fouls. BF is separate.
      // We should probably tell tracker about it for logging?
      // Revisit if FoulTracker needs update. For now, calc penalty manually.
      totalInningPoints += foulPenalty; 
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
      
      
      // NOTE: 2-foul warning is handled in _switchPlayer() when starting turn
      // This prevents duplicate warnings and ensures correct timing
      
      
      // Add 3-foul event if triggered
      if (willTriggerThreeFouls) {
        player.inningHasThreeFouls = true; // Mark for notation "TF"
        eventQueue.add(FoulEvent(player, -16, FoulType.threeFouls, 
          positivePoints: 0, penalty: -16));
      }
    } else {
      // Valid shot (no foul) resets consecutive fouls
      player.consecutiveFouls = 0;
    }
    
    // Update player score
    player.score += totalInningPoints;
    player.lastPoints = totalInningPoints;
    player.lastRun = totalInningPoints; // Persist for "LR" display
    debugPrint('DEBUG: _finalizeInning - Total: $totalInningPoints, lastRun Set To: ${player.lastRun}, currentRun: ${player.currentRun}');
    player.updateCount++;
    
    // NOTE: currentRun is now updated in real-time via addInningPoints()
    // NOT here at finalization to avoid double-counting
    // Only update highestRun if currentRun exceeded it
    if (player.currentRun > player.highestRun) {
      player.highestRun = player.currentRun;
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
  // ═══════════════════════════════════════════════════════════════
  // CRITICAL: LAST RUN (LR) DISPLAY LOGIC - DO NOT MODIFY
  // This method is called by PlayerPlaque for real-time LR display
  // Breaking this will cause LR to show +0 instead of actual values
  // Last broken: 2026-01-08 (missing foul penalties)
  // ═══════════════════════════════════════════════════════════════
  int getDynamicInningScore(Player player) {
     // Base Points (Current Rack + Previous Racks in this inning)
     int total = player.inningPoints + player.inningHistory.fold(0, (prev, element) => prev + element);
     
     // Apply Handicap
     if (total > 0) {
       total = (total * player.handicapMultiplier).round();
     }
     
     // CRITICAL: Apply PENDING foul penalties (must include or LR shows +0)
     // This shows the NET score during active play before finalization
     int penalty = 0;
     if (player.inningBreakFoulCount > 0) {
       penalty = player.inningBreakFoulCount * -2; // Stacked BF penalty
     } else if (player.inningHasFoul) {
       penalty = -1; // Normal foul penalty
     }
     
     return total + penalty;
  }
  
  // Generate score card notation for an inning (Canonical V2 format)
  String _generateInningNotation(Player player) {
    // Build segments list from history + current points
    final segments = <int>[];
    
    // 1. Add history segments (from previous re-racks in this inning)
    for (int segmentPoints in player.inningHistory) {
      int adjusted = segmentPoints;
      if (adjusted > 0) {
        adjusted = (adjusted * player.handicapMultiplier).round();
      }
      segments.add(adjusted);
    }
    
    // 2. Add current active segment
    int currentPoints = player.inningPoints;
    if (currentPoints > 0) {
      currentPoints = (currentPoints * player.handicapMultiplier).round();
    }
    
    // Always include current segment (explicit 0 in canonical format)
    if (currentPoints > 0 || segments.isEmpty) {
      segments.add(currentPoints);
    } else {
      // Re-rack occurred but no points scored yet in new rack
      segments.add(0);
    }
    
    // 3. Determine foul type
    FoulType foulType;
    if (player.inningBreakFoulCount > 0) {
      foulType = FoulType.breakFoul;
    } else if (player.inningHasThreeFouls) {
      foulType = FoulType.threeFouls;
    } else if (player.inningHasFoul) {
      foulType = FoulType.normal;
    } else {
      foulType = FoulType.none;
    }
    
    // 4. Create InningRecord and serialize to canonical notation
    final record = InningRecord(
      inning: player.currentInning,
      playerName: player.name,
      notation: '', // Will be generated by NotationCodec
      runningTotal: player.score,
      segments: segments,
      safe: player.inningHasSafe,
      foul: foulType,
      foulCount: player.inningBreakFoulCount, // Pass count to notation
    );
    
    return NotationCodec.serialize(record);
  }

  void _switchPlayer() {
  // 1. Capture references before switching logical index
  final oldPlayer = currentPlayer;
  final newPlayerIndex = 1 - currentPlayerIndex;
  final newPlayer = players[newPlayerIndex];

  // 2. Finalize inning (uses current/old player)
  //    This sets lastRun and adds to score
  _finalizeInning(oldPlayer);
  
  debugPrint('DEBUG _switchPlayer: ${oldPlayer.name} lastRun=${oldPlayer.lastRun} currentRun=${oldPlayer.currentRun}');
  
  // 3. Reset for next inning (currentRun = 0)
  oldPlayer.incrementInning();
  
  debugPrint('DEBUG _switchPlayer: After incrementInning currentRun=${oldPlayer.currentRun}');
  
  // 4. Switch logical control immediately
  currentPlayerIndex = newPlayerIndex;
  
  // 5. Permanently disable break fouls when player switches during normal play
  if (breakFoulStillAvailable) {
    breakFoulStillAvailable = false;
  }
  
  // 6. Delayed Visual Switch (Active State)
  // Keep oldPlayer.isActive = true during the delay so they stay "lit"
  // while the LR badge animates with the CORRECT lastRun value
  Future.delayed(const Duration(milliseconds: 800), () {
    oldPlayer.isActive = false;
    newPlayer.isActive = true;
    notifyListeners();
  });

  // Check for 2-Foul Warning upon entering turn (Logical check on new player)
  if (foulTracker.threeFoulRuleEnabled &&
      newPlayer.consecutiveFouls == 2) {
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
        // CRITICAL: First finalize the inning to commit the winning run points to the player's total score.
        // This ensures play.score matches the projectedScore and VictorySplash displays the correct total.
        _finalizeInning(player);

        gameOver = true;
        winner = player;
        _gameTimer.pause(); // Stop timer when game ends
        
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
    breakingPlayerIndex = null; // Reset breaking player tracking
    breakFoulStillAvailable = true; // Re-enable break fouls for new game
    notifyListeners();
  }

  Map<String, dynamic> toJson() => GameSnapshot.fromState(this).toJson();

  void loadFromJson(Map<String, dynamic> json) {
    final snapshot = GameSnapshot.fromJson(json);
    snapshot.restore(this);

    // Resume timer if game was in progress and we just loaded it
    if (gameStarted && !gameOver && !isPaused) {
       startGameTimer();
    }
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
  final int? breakingPlayerIndex; // Break foul eligibility tracking
  final bool breakFoulStillAvailable; // Break foul eligibility tracking
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
        breakingPlayerIndex = state.breakingPlayerIndex,
        breakFoulStillAvailable = state.breakFoulStillAvailable,
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
        breakingPlayerIndex = json['breakingPlayerIndex'] as int?,
        breakFoulStillAvailable = json['breakFoulStillAvailable'] as bool? ?? true,
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
        'breakingPlayerIndex': breakingPlayerIndex,
        'breakFoulStillAvailable': breakFoulStillAvailable,
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
    state.breakingPlayerIndex = breakingPlayerIndex;
    state.breakFoulStillAvailable = breakFoulStillAvailable;
    state.foulMode = foulMode;
    state.matchLog = List.from(matchLog);
    state.inningRecords = List.from(inningRecords);
    state.breakFoulHintMessage = breakFoulHintMessage;

    // Restore Timer
    state._gameTimer.loadSavedDuration(Duration(seconds: elapsedDurationInSeconds));
    state._gameTimer.reset();
  }
}
