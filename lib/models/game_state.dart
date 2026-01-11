import 'package:flutter/foundation.dart';
import 'foul_tracker.dart';
import '../core/game_timer.dart';
import '../core/game_history.dart';
import '../core/event_manager.dart';
import '../core/events/game_event.dart';
import '../core/table_state.dart';
import 'achievement_manager.dart';
import '../data/messages.dart';
import 'game_settings.dart';
import '../services/achievement_checker.dart';
import '../codecs/notation_codec.dart';

import '../games/base/game_rules.dart' as rules;
import '../games/base/rules_state.dart';
import '../games/base/rule_outcome.dart' as rules_outcome;
import '../games/straight_pool/straight_pool_rules.dart';
import '../games/straight_pool/straight_pool_state.dart' as sp_state;
import '../core/actions/game_action.dart';

enum FoulMode { none, normal, severe }
// FoulType now imported from '../codecs/notation_codec.dart'
// (includes: none, normal, breakFoul, threeFouls)
// GameEvent classes now imported from '../core/events/game_event.dart'

class GameState extends ChangeNotifier {
  GameSettings settings;
  int raceToScore;
  late List<Player> players;
  late FoulTracker foulTracker;
  late AchievementManager? achievementManager;
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

  // Foul Mode Getter (Delegate to Rules State)
  FoulMode get foulMode {
     if (_rulesState is sp_state.StraightPoolState) {
        // Map sp_state.FoulMode to GameState.FoulMode (if enum is identical/imported)
        // sp_state.FoulMode is enum { none, normal, severe }
        // GameState.FoulMode is the SAME enum definition? NO.
        // GameState has `enum FoulMode { none, normal, severe }` at line 21.
        // StraightPoolState imports/defines its own or reused?
        // Step 144: `StraightPoolState` defines `enum FoulMode` at line 104.
        // They are different types. We must map them.
        final mode = (_rulesState as sp_state.StraightPoolState).pendingFoulMode;
        return switch (mode) {
           sp_state.FoulMode.none => FoulMode.none,
           sp_state.FoulMode.normal => FoulMode.normal,
           sp_state.FoulMode.severe => FoulMode.severe,
        };
     }
     return FoulMode.none;
  }
  
  set foulMode(FoulMode mode) {
     if (_rulesState is sp_state.StraightPoolState) {
        // Map GameState.FoulMode to sp_state.FoulMode
        final spMode = switch (mode) {
           FoulMode.none => sp_state.FoulMode.none,
           FoulMode.normal => sp_state.FoulMode.normal,
           FoulMode.severe => sp_state.FoulMode.severe,
        };
        (_rulesState as sp_state.StraightPoolState).pendingFoulMode = spMode;
        notifyListeners();
     }
  }

  // Safe Mode Getter
  bool get isSafeMode {
     if (_rulesState is sp_state.StraightPoolState) {
        return (_rulesState as sp_state.StraightPoolState).pendingSafeMode;
     }
     return false;
  }
  
  set isSafeMode(bool mode) {
     if (_rulesState is sp_state.StraightPoolState) {
        (_rulesState as sp_state.StraightPoolState).pendingSafeMode = mode;
        notifyListeners();
     }
  }

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

  // Undo/Redo History (extracted to GameHistory)
  final GameHistory<GameSnapshot> _history = GameHistory<GameSnapshot>();

  // UI Event Manager (extracted to EventManager)
  final EventManager _events = EventManager();

  // Table State (extracted to TableState)
  final TableState _table = TableState();

  // Rules Engine
  final rules.GameRules _rules = StraightPoolRules();
  late RulesState _rulesState;

  Set<int> get activeBalls => _table.activeBalls;

  bool get canUndo => _history.canUndo;

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
  bool get canRedo => _history.canRedo;
  
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
    
    // Initialize Rules State
    _rulesState = _rules.initialState(settings);
    
    _table.resetRack();
    
    // Setup timer tick callback
    _gameTimer.onTick = () {
      notifyListeners(); // UI updates every second
    };
  }

  // Update settings mid-game
  void updateSettings(GameSettings newSettings) {
    bool somethingChanged = false;

    // Update Race to Score
    if (raceToScore != newSettings.raceToScore) {
      raceToScore = newSettings.raceToScore;
      somethingChanged = true;
      _logAction('Race to Score changed to $raceToScore');
      onSaveRequired?.call();
    }

    // Update 3-Foul Rule
    if (foulTracker.threeFoulRuleEnabled != newSettings.threeFoulRuleEnabled) {
      foulTracker.threeFoulRuleEnabled = newSettings.threeFoulRuleEnabled;
      somethingChanged = true;
      _logAction(
          '3-Foul Rule ${newSettings.threeFoulRuleEnabled ? "Enabled" : "Disabled"}');
    }

    // Update Player Names (if changed)
    if (players[0].name != newSettings.player1Name) {
      players[0] = players[0].copyWith(name: newSettings.player1Name);
      somethingChanged = true;
      _logAction('Player 1 renamed to ${newSettings.player1Name}');
    }

    if (players[1].name != newSettings.player2Name) {
      players[1] = players[1].copyWith(name: newSettings.player2Name);
      somethingChanged = true;
      _logAction('Player 2 renamed to ${newSettings.player2Name}');
    }

    // Update Handicap Multipliers
    if (players[0].handicapMultiplier != newSettings.player1HandicapMultiplier) {
      players[0] = players[0]
          .copyWith(handicapMultiplier: newSettings.player1HandicapMultiplier);
      somethingChanged = true;
      _logAction(
          'Player 1 Handicap changed to ${newSettings.player1HandicapMultiplier}x');
    }

    if (players[1].handicapMultiplier != newSettings.player2HandicapMultiplier) {
      players[1] = players[1]
          .copyWith(handicapMultiplier: newSettings.player2HandicapMultiplier);
      somethingChanged = true;
      _logAction(
          'Player 2 Handicap changed to ${newSettings.player2HandicapMultiplier}x');
    }

    if (settings.isTrainingMode != newSettings.isTrainingMode) {
      settings = newSettings;
      somethingChanged = true;
      if (newSettings.isTrainingMode) {
        currentPlayerIndex = 0;
        players[0].isActive = true;
        players[1].isActive = false;
        _logAction('Training Mode enabled');
      } else {
        _logAction('Training Mode disabled');
      }
    } else {
      settings = newSettings;
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
    _table.resetRack();
    notifyListeners();
  }

  void manualPushState() {
    _pushState();
  }

  void _pushState() {
    _history.push(GameSnapshot.fromState(this));
    // State pushed means something is about to change, so we save AFTER the change usually. 
    // But methods calling _pushState will call notifyListeners (and should call onSaveRequired).
  }



  void undo() {
    if (!canUndo) return;
    final currentSnapshot = GameSnapshot.fromState(this);
    final snapshot = _history.undo(currentSnapshot);
    
    if (snapshot != null) {
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
  }

  void redo() {
    if (!canRedo) return;
    final currentSnapshot = GameSnapshot.fromState(this);
    final snapshot = _history.redo(currentSnapshot);
    
    if (snapshot != null) {
      snapshot.restore(this);
      notifyListeners();
      onSaveRequired?.call();
    }
  }

  void setFoulMode(FoulMode mode) {
    foulMode = mode;
    resetBreakFoulError();
    notifyListeners();
  }

  void onSafe() {
    if (!isSafeMode) {
      // ENTER Safe Mode
      isSafeMode = true;
      notifyListeners();
    } else {
      _pushState();
      // CONFIRM Standard Safe
      final outcome = _rules.apply(const SafeAction(), _buildCoreState(), _rulesState);
      _applyOutcome(outcome);
      
      // Reset Modes (Legacy behavior)
      foulMode = FoulMode.none;
      isSafeMode = false;
      resetBreakFoulError();
    }
  }

  void onBallTapped(int ballNumber) {
    _pushState();
    if (!gameStarted) {
      gameStarted = true;
      startGameTimer();
    }

    // VALIDATION: Strict Mutual Exclusion (Spec §7.3)
    if (!_validateInteraction(ballNumber)) return;
    
    // Delegate to Rules Engine
    final action = BallTappedAction(ballNumber);
    final core = _buildCoreState();
    final outcome = _rules.apply(action, core, _rulesState);
    
    // Sync rack state for normal taps (2-15). Re-rack/double-sack are handled via table directives.
    if (ballNumber > 1) {
      updateRackCount(ballNumber);
    }

    _applyOutcome(outcome);
    
    // Reset Modes
    foulMode = FoulMode.none;
    isSafeMode = false;
    resetBreakFoulError();
  }

  void handleBreakFoulDecision(int selectedIndex) {
      final action = BreakFoulDecisionAction(selectedIndex);
      final outcome = _rules.apply(action, _buildCoreState(), _rulesState);
      _applyOutcome(outcome);
  }

  void updateRackCount(int count) {
    _table.updateCount(count);
  }


  // Called by UI after Splash animation to physically reset the rack
  void finalizeReRack() {
     final outcome = _rules.apply(const FinalizeReRackAction(), _buildCoreState(), _rulesState);
     _applyOutcome(outcome);
  }

  // Helper to validate interactions against exclusion rules
  bool _validateInteraction(int ballNumber) {
    // Continuation actions (0, 1) are disabled if ANY Terminator (Safe, Foul, Break Foul) is active.
    bool termModeActive = isSafeMode || foulMode != FoulMode.none;
    if (termModeActive && (ballNumber == 0 || ballNumber == 1)) {
        debugPrint('ERROR: Mutual Exclusion - Cannot tap 0/1 during Safe/Foul');
        _events.add(WarningEvent(
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
    
    // VALIDATION: Strict Mutual Exclusion (Spec §7.3)
    if (!_validateInteraction(0)) return;
    
    final outcome = _rules.apply(const DoubleSackAction(), _buildCoreState(), _rulesState);
    _applyOutcome(outcome);
    
    // Reset Modes
    foulMode = FoulMode.none;
    isSafeMode = false;
    resetBreakFoulError();
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
        _events.add(FoulEvent(player, -16, FoulType.threeFouls, 
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
    
    // CRITICAL FIX: Clear inning buffers after finalization 
    // This prevents double-counting if _finalizeInning is called again (e.g. on win check)
    player.inningPoints = 0;
    player.inningHistory = [];
    player.inningBreakFoulCount = 0;
    player.inningHasFoul = false;
    player.inningHasThreeFouls = false;
    player.inningHasSafe = false;
    player.inningHasReRack = false;
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

  int getTotalFoulsForPlayer(Player player, {bool includeCurrent = false}) {
    int total = 0;
    for (final record in inningRecords) {
      if (record.playerName != player.name) continue;
      total += _countFoulsFromNotation(record.notation);
    }

    if (includeCurrent && !gameOver) {
      total += _countCurrentInningFouls(player);
    }

    return total;
  }

  int _countFoulsFromNotation(String notation) {
    try {
      final parsed = NotationCodec.parse(notation);
      switch (parsed.foul) {
        case FoulType.breakFoul:
          return parsed.foulCount;
        case FoulType.normal:
        case FoulType.threeFouls:
          return 1;
        case FoulType.none:
          return 0;
      }
    } catch (_) {
      return 0;
    }
  }

  int _countCurrentInningFouls(Player player) {
    if (player.inningBreakFoulCount > 0) {
      return player.inningBreakFoulCount;
    }
    if (player.inningHasThreeFouls || player.inningHasFoul) {
      return 1;
    }
    return 0;
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
    
    // 3. Determine foul suffix for Rules API
    String? foulSuffix;
    if (player.inningBreakFoulCount > 0) {
      // BF or BF2 etc. rules expects BF1 as BF usually?
      // StraightPoolRules parsing: BF(\d+). if no digit, 1.
      final count = player.inningBreakFoulCount;
      foulSuffix = 'BF${count > 1 ? count : ''}';
    } else if (player.inningHasThreeFouls) {
      foulSuffix = 'TF';
    } else if (player.inningHasFoul) {
      foulSuffix = 'F';
    }
    
    // 4. Delegate to Rules
    final inningData = rules.InningData(
      segments: segments,
      isSafe: player.inningHasSafe,
      foulSuffix: foulSuffix,
    );
    
    return _rules.generateNotation(inningData);
  }

  void _switchPlayer() {
  // 1. Capture references before switching logical index
  final oldPlayer = currentPlayer;

  // 2. Finalize inning (uses current/old player)
  //    This sets lastRun and adds to score
  _finalizeInning(oldPlayer);
  
  debugPrint('DEBUG _switchPlayer: ${oldPlayer.name} lastRun=${oldPlayer.lastRun} currentRun=${oldPlayer.currentRun}');
  
  // 3. Reset for next inning (currentRun = 0)
  oldPlayer.incrementInning();
  
  debugPrint('DEBUG _switchPlayer: After incrementInning currentRun=${oldPlayer.currentRun}');

  if (settings.isTrainingMode) {
    if (breakFoulStillAvailable) {
      breakFoulStillAvailable = false;
      if (_rulesState is sp_state.StraightPoolState) {
          (_rulesState as sp_state.StraightPoolState).breakFoulStillAvailable = false;
      }
    }

    if (foulTracker.threeFoulRuleEnabled &&
        oldPlayer.consecutiveFouls == 2) {
      _events.add(TwoFoulsWarningEvent());
    }

    notifyListeners();
    return;
  }
  
  final newPlayerIndex = 1 - currentPlayerIndex;
  final newPlayer = players[newPlayerIndex];
  
  // 4. Switch logical control immediately
  currentPlayerIndex = newPlayerIndex;
  
  // 5. Permanently disable break fouls when player switches during normal play
  if (breakFoulStillAvailable) {
    breakFoulStillAvailable = false;
    if (_rulesState is sp_state.StraightPoolState) {
        (_rulesState as sp_state.StraightPoolState).breakFoulStillAvailable = false;
    }
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
    _events.add(TwoFoulsWarningEvent());
  }
  
  notifyListeners();
}

  // Method to consume events (UI calls this)
  List<GameEvent> consumeEvents() {
<<<<<<< HEAD
    return _events.consumeAll();
=======
    final events = List<GameEvent>.from(eventQueue);
    eventQueue.clear();
    // Signal start of processing for these events (Input Locked)
    _processingEventsCount += events.length;
    return events;
>>>>>>> 5ed6842 (fix: state-based input blocking (v4.2.3))
  }

  // Allow swapping starting player before game starts
  void swapStartingPlayer() {
    if (settings.isTrainingMode) return;
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
    // Delegate to Rules Check
    final winResult = _rules.checkWin(_buildCoreState(), _rulesState);
    
    if (winResult != null && !gameOver) {
        // Validation: Ensure winner index is valid
        if (winResult.winningPlayerIndex >= 0 && winResult.winningPlayerIndex < players.length) {
            final winner = players[winResult.winningPlayerIndex];
            
            // CRITICAL: First finalize the inning to commit the winning run points
            _finalizeInning(winner); // Uses current logic to bank points
            
            gameOver = true;
            this.winner = winner;
            _gameTimer.pause();
            
            _logAction('${winner.name} WINS! 🎉');
            
            if (achievementManager != null) {
              AchievementChecker.checkAfterWin(winner, this, achievementManager!);
            }
            
            notifyListeners();
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
    inningRecords.clear(); // Fix: Clear score card
    // We do NOT clear undo stack, so reset can be undone!
    resetBreakFoulError();
    inBreakSequence = true; // Reset Break Sequence Logic
    breakingPlayerIndex = null; // Reset breaking player tracking
    breakFoulStillAvailable = true; // Re-enable break fouls for new game
    notifyListeners();
  }

  // === RULES INTEGRATION ===

  rules.CoreState _buildCoreState() {
    final rulePlayers = players.map((p) => rules.Player(
      name: p.name, 
      score: p.projectedScore
    )).toList();
    
    return rules.CoreState(
      players: rulePlayers,
      activePlayerIndex: currentPlayerIndex,
      inningNumber: currentPlayer.currentInning,
      turnNumber: 0,
      activeBalls: _table.activeBalls,
    );
  }

  void _applyOutcome(rules_outcome.RuleOutcome outcome) {
    // 1. Update Score & Sync Rules State
    if (outcome.rawPointsDelta != 0) {
       currentPlayer.addInningPoints(outcome.rawPointsDelta);
       
       // Sync Rules State (Crucial for SaveSegment logic in next step)
       if (_rulesState is sp_state.StraightPoolState) {
          (_rulesState as sp_state.StraightPoolState).currentInningPoints += outcome.rawPointsDelta;
       }
    }

    // 2. Apply State Mutations
    if (outcome.stateMutations.isNotEmpty) {
      if (_rulesState is sp_state.StraightPoolState) {
        final spState = _rulesState as sp_state.StraightPoolState;
        for (final mutation in outcome.stateMutations) {
          _applyStraightPoolMutation(spState, mutation);
        }
      }
    }
    
    // 3. Queue Events
    for (final event in outcome.events) {
       if (event is rules_outcome.FoulEventDescriptor) {
          // Map FoulType from Rules to Legacy (NotationCodec)
          FoulType legacyType = FoulType.none;
          if (event.type == rules_outcome.FoulType.normal) legacyType = FoulType.normal;
          else if (event.type == rules_outcome.FoulType.breakFoul) legacyType = FoulType.breakFoul;
          else if (event.type == rules_outcome.FoulType.threeFouls) legacyType = FoulType.threeFouls;
          
          _events.add(FoulEvent(currentPlayer, event.penalty, legacyType));
       } else if (event is rules_outcome.SafeEventDescriptor) {
          _events.add(SafeEvent());
       } else if (event is rules_outcome.ReRackEventDescriptor) {
          _events.add(ReRackEvent(event.variant)); 
       }
    }

    // 4. Turn Directive
    switch (outcome.turnDirective) {
       case rules_outcome.TurnDirective.continueTurn:
         break;
       case rules_outcome.TurnDirective.endTurn:
         if (outcome.endsInning) {
             _switchPlayer();
         }
         break;
       case rules_outcome.TurnDirective.gameOver:
         break;
       case rules_outcome.TurnDirective.awaitDecision:
         if (outcome.decisionRequirement != null) {
            final req = outcome.decisionRequirement!;
            if (req.type == 'breakFoulDecision') {
                 if (settings.isTrainingMode) {
                   handleBreakFoulDecision(currentPlayerIndex);
                 } else {
                   _events.add(BreakFoulDecisionEvent(
                      req.options, 
                      (selectedIndex) => handleBreakFoulDecision(selectedIndex)
                   ));
                 }
            }
         }
         break;
    }

    // 5. Table Directive
    if (outcome.tableDirective != null) {
       switch (outcome.tableDirective!) {
          case rules_outcome.TableDirective.reRack:
              break;
          case rules_outcome.TableDirective.clearRack:
             updateRackCount(0);
             break;
          case rules_outcome.TableDirective.showOne:
              updateRackCount(1);
              break;
          case rules_outcome.TableDirective.reset:
              _resetRack();
              break;
          case rules_outcome.TableDirective.spot:
              break;
       }
    }

    // 6. Log Message
    if (outcome.logMessage != null) {
       _logAction(outcome.logMessage!);
    }
    
    // 7. Check Win
    _checkWinCondition(); 

    notifyListeners();
  }

  void _applyStraightPoolMutation(sp_state.StraightPoolState state, rules_outcome.StateMutation mutation) {
    if (mutation is rules_outcome.SaveSegmentMutation) {
      state.currentInningSegments.add(mutation.points);
      state.currentInningPoints = 0; 
      // Sync Legacy
      currentPlayer.inningHistory.add(currentPlayer.inningPoints);
      currentPlayer.inningPoints = 0;
      currentPlayer.inningHasReRack = true;
    } else if (mutation is rules_outcome.IncrementBreakFoulCountMutation) {
      state.currentInningBreakFoulCount++;
      // Sync Legacy
      currentPlayer.inningBreakFoulCount++;
      currentPlayer.setFoulPenalty(currentPlayer.inningBreakFoulCount * -2);
    } else if (mutation is rules_outcome.DisableBreakFoulsMutation) {
      state.breakFoulStillAvailable = false;
      breakFoulStillAvailable = false;
    } else if (mutation is rules_outcome.EndBreakSequenceMutation) {
      state.inBreakSequence = false;
      inBreakSequence = false;
    } else if (mutation is rules_outcome.SetBreakingPlayerMutation) {
      state.breakingPlayerIndex = mutation.playerIndex;
      breakingPlayerIndex = mutation.playerIndex;
    } else if (mutation is rules_outcome.MarkInningFoulMutation) {
      state.currentInningHasFoul = true;
      // Sync Legacy
      currentPlayer.inningHasFoul = true;
      if (foulMode == FoulMode.normal) {
         currentPlayer.setFoulPenalty(-1);
      }
    } else if (mutation is rules_outcome.MarkInningSafeMutation) {
      state.currentInningHasSafe = true;
      // Sync Legacy
      currentPlayer.inningHasSafe = true;
      currentPlayer.incrementSaves();
    } else if (mutation is rules_outcome.MarkInningReRackMutation) {
       // Just flag
       currentPlayer.inningHasReRack = true;
    }
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
  final Map<String, dynamic> rulesState; // Added for Rules Engine

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
        elapsedDurationInSeconds = state.elapsedDuration.inSeconds,
        rulesState = state._rulesState.toJson();

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
            json['elapsedDurationInSeconds'] as int? ?? 0,
        rulesState = json['rulesState'] as Map<String, dynamic>? ?? {};

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
        'rulesState': rulesState,
      };

  @override
  void restore(GameState state) {
    // Restore Rules State - MUST be first to allow setters/getters to work
    if (rulesState.isNotEmpty) {
       state._rulesState = sp_state.StraightPoolState.fromJson(rulesState);
    }

    state.players = players.map((p) => p.copyWith()).toList();
    // Restore table state via TableState
    state._table.loadFromJson({'activeBalls': activeBalls.toList()});
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
    state.inBreakSequence = inBreakSequence; // Setter delegates to rules
    state.breakingPlayerIndex = breakingPlayerIndex; // Setter delegates to rules
    state.breakFoulStillAvailable = breakFoulStillAvailable; // Setter delegates to rules
    state.foulMode = foulMode; // Setter delegates to rules
    state.matchLog = List.from(matchLog);
    state.inningRecords = List.from(inningRecords);
    state.breakFoulHintMessage = breakFoulHintMessage;

    // Restore Timer
    state._gameTimer.loadSavedDuration(Duration(seconds: elapsedDurationInSeconds));
    // Reset only the stopwatch counter (preserves savedDuration)
    state._gameTimer.resetStopwatch();
  }
}
