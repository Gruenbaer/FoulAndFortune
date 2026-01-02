import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_action.dart';
import '../theme/fortune_theme.dart';

class ScoreCard extends StatelessWidget {
  final Player player1;
  final Player player2;
  // We accept the history list now. The parent passes GameState.history.
  // We keep 'matchLog' param name for compatibility if parent matches type?
  // No, let's update parent too. But first, update type here.
  final List<GameAction> history; 
  final String? winnerName;

  const ScoreCard({
    super.key,
    required this.player1,
    required this.player2,
    required this.history,
    this.winnerName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    
    // Parse the structured history to get inning-by-inning data
    final inningScores = _processHistory();
    
    // Determine max innings based on parsed data or current innings
    int maxInnings = player1.currentInning > player2.currentInning 
        ? player1.currentInning 
        : player2.currentInning;
        
    // Ensure we show at least 1 row
    if (maxInnings < 1) maxInnings = 1;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.primaryDark),
        borderRadius: BorderRadius.circular(8),
        color: colors.backgroundCard.withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          // Header Row 1: Player Names
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colors.backgroundCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    player1.name.toUpperCase(),
                    style: TextStyle(
                      color: player1.name == winnerName 
                          ? colors.primaryBright 
                          : colors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(), // Spacer for Inning column
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    player2.name.toUpperCase(),
                    style: TextStyle(
                      color: player2.name == winnerName 
                          ? colors.primaryBright 
                          : colors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Header Row 2: Columns
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            color: colors.backgroundCard,
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderLabel(colors, 'POINTS')),
                Expanded(flex: 2, child: _buildHeaderLabel(colors, 'TOTAL')),
                Expanded(flex: 1, child: _buildHeaderLabel(colors, 'INN')),
                Expanded(flex: 2, child: _buildHeaderLabel(colors, 'TOTAL')),
                Expanded(flex: 2, child: _buildHeaderLabel(colors, 'POINTS')),
              ],
            ),
          ),
          // Innings rows
          ...List.generate(
            maxInnings,
            (index) => _buildInningRow(context, index + 1, inningScores),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLabel(FortuneColors colors, String text) {
    return Text(
      text,
      style: TextStyle(
        color: colors.textMain.withValues(alpha: 0.7),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNotationText(String notation) {
    // Parse notation and apply colors:
    // - "F" or anything containing "F" -> Red
    // - "S" -> Green
    // - Numbers -> White
    // - "-" (unplayed) -> White/dim
    
    if (notation.isEmpty || notation == '-') {
      return Text(
        notation,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        textAlign: TextAlign.center,
      );
    }
    
    // Check for F or S
    if (notation.contains('F')) {
      // Parse "4 F" or "5.3 F" etc.
      final parts = notation.split(' ');
      if (parts.length == 2 && parts[1] == 'F') {
        // Show number in white, F in red
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: parts[0], style: TextStyle(color: Colors.white)),
              TextSpan(text: ' F', style: TextStyle(color: Colors.red)),
            ],
          ),
        );
      }
    }
    
    if (notation == 'S') {
      return Text(
        notation,
        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }
    
    // Default: white for numbers
    return Text(
      notation,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInningRow(BuildContext context, int inning, Map<String, Map<int, InningStat>> inningScores) {
    final colors = FortuneColors.of(context);

    // Data for single inning
    final p1Data = inningScores[player1.name]?[inning];
    final p2Data = inningScores[player2.name]?[inning]; 
    
    String p1Notation = p1Data?.notation ?? '-'; // Default to dash if no data
    String p1Total = p1Data != null ? '${p1Data.total}' : ''; // Show 0 if exists

    String p2Notation = p2Data?.notation ?? '-'; // Default to dash if no data
    String p2Total = p2Data != null ? '${p2Data.total}' : ''; // Show 0 if exists
    
    // No special case needed - defaults handle it

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.primaryDark, width: 0.5)),
      ),
      child: Row(
        children: [
          // P1 Points
          Expanded(
            flex: 2,
            child: _buildNotationText(p1Notation),
          ),
          // P1 Total
          Expanded(
            flex: 2,
            child: Text(
              p1Total,
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          // Inning #
          Expanded(
            flex: 1,
            child: Text(
              inning.toString(),
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // P2 Total
          Expanded(
            flex: 2,
             child: Text(
              p2Total,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // P2 Notation
          Expanded(
            flex: 2,
            child: _buildNotationText(p2Notation),
          ),
        ],
      ),
    );
  }

  // Pure logic: Process list of GameActions into a Grid of InningStats
  Map<String, Map<int, InningStat>> _processHistory() {
     Map<String, Map<int, InningStat>> result = {
      player1.name: {},
      player2.name: {},
    };

    // State trackers
    Map<String, int> runningTotal = { player1.name: 0, player2.name: 0 };
    
    // Inning Accumulators
    Map<String, int> inningPoints = { player1.name: 0, player2.name: 0 };
    Map<String, bool> inningHasFoul = { player1.name: false, player2.name: false };
    Map<String, bool> inningHasSafety = { player1.name: false, player2.name: false };
    Map<String, List<int>> inningReRackSegments = { player1.name: [], player2.name: [] };
    
    Map<String, int> lastSeenInning = { player1.name: 0, player2.name: 0 };

    // We must process Chronologically (Oldest -> Newest)
    // HISTORY is stored Newest -> Oldest (Index 0 is latest).
    // So we iterate REVERSED.
    for (int i = history.length - 1; i >= 0; i--) {
      final action = history[i];
      final pName = action.playerId;
      
      // Update last seen inning for this player
      lastSeenInning[pName] = action.inning;

      // Accumulate score
      inningPoints[pName] = inningPoints[pName]! + action.points;
      runningTotal[pName] = runningTotal[pName]! + action.points;

      if (action.type == GameActionType.foul || action.type == GameActionType.breakFoul) {
        inningHasFoul[pName] = true;
      }
      if (action.type == GameActionType.safety) {
        inningHasSafety[pName] = true;
      }
      
      // Re-rack Logic (Segmentation)
      if (action.type == GameActionType.reRack) {
         // Push current segment if we have points or if it's not the end of turn
         // (If it IS end of turn, the re-rack logic usually implies a safe or just end)
         if (!action.isTurnEnd || inningPoints[pName]! > 0) {
             inningReRackSegments[pName]!.add(inningPoints[pName]!);
             inningPoints[pName] = 0; 
         }
      }

      // Turn End Logic
      if (action.isTurnEnd) {
         _finalizeInningData(
             result, 
             pName, 
             action.inning, 
             inningPoints, 
             inningHasFoul, 
             inningHasSafety,
             inningReRackSegments,
             runningTotal
         );
      }
    }
    
    // Process "Pending" Inning (Active Turn)
    // If the loop finished and we still have data in accumulators, or if the game is active,
    // we assume the current inning is still open.
    // We check both players.
    for (var pName in [player1.name, player2.name]) {
       // If we have points > 0, OR flags set, OR segments exist
       // AND we haven't already finalized this inning in the result map?
       // Actually, we overwrite in result map, so safe to call again?
       // NO, finalizing resets the accumulators.
       // So if accumulators are non-empty/dirty, we preserve them?
       // The loop above calls finalize on TurnEnd.
       // If turn didn't end, accumulators are DIRTY.
       // We flush them now.
       
       bool isDirty = inningPoints[pName] != 0 || 
                      inningHasFoul[pName]! || 
                      inningHasSafety[pName]! || 
                      inningReRackSegments[pName]!.isNotEmpty;

       // Also, if the player is currently ACTIVE (i.e. it's their turn), we want to show current stats even if 0.
       bool isActive = (pName == player1.name && player1.isActive) || (pName == player2.name && player2.isActive);
       
       if (isDirty || isActive) {
           // Use the last seen inning, or if 0 (start of game), use 1?
           int inning = lastSeenInning[pName]!;
           if (inning == 0) inning = 1; 
           
           // If we are active, `currentInning` from player object is authoritative
           if (isActive) {
               inning = (pName == player1.name) ? player1.currentInning : player2.currentInning;
           }

           _finalizeInningData(
             result, 
             pName, 
             inning, 
             inningPoints, 
             inningHasFoul, 
             inningHasSafety,
             inningReRackSegments,
             runningTotal,
             pending: true
         );
       }
    }
    
    return result;
  }
  
  void _finalizeInningData(
      Map<String, Map<int, InningStat>> result,
      String pName,
      int inning,
      Map<String, int> inningPoints,
      Map<String, bool> inningHasFoul,
      Map<String, bool> inningHasSafety,
      Map<String, List<int>> segments,
      Map<String, int> runningTotal,
      {bool pending = false}
  ) {
      if (inning == 0) return;
      
      int currentVal = inningPoints[pName]!;
      List<int> segs = segments[pName]!;
      
      // Calculate display string (Notation)
      String notation = '';
      
      // Re-rack segments: "5.3"
      if (segs.isNotEmpty) {
          notation = segs.join('.');
          // valid part: "5."
          
          // Append the remainder (currentVal)
          // "5.3"
          // Only append if it's non-zero or if it's the only thing left?
          // If 0 and turn ended, maybe just "5"?
          // If pending, "5.0"?
          // Let's stick to appending if non-zero OR if it's the end of the chain.
          if (currentVal != 0 || pending) {
             if (notation.isNotEmpty) notation += '.';
             notation += currentVal.toString();
          }
      } else {
          // Standard: Just the value
          notation = currentVal.toString();
      }
      
      // Safety Flag - show S if inning ended with a safety and 0 net points
      // Check the notation itself rather than just currentVal to handle re-racks
      if (inningHasSafety[pName]! && (notation == '0' || (currentVal == 0 && segs.isEmpty))) {
          notation = 'S'; // Safety with 0 points (will be colored green in rendering)
      }
       
      if (inningHasFoul[pName]!) {
          // Foul: Append F.
          // Note: If score was positive then foul (5.F), our logic above gives `currentVal`.
          // `currentVal` usually includes the penalty (-1). 
          // So if I shot 5 balls (+5), then foul (-1). Net +4.
          // Notation: "5 F"? Or "4 F"?
          // User said "5.F" implies showing positive run.
          // Refactor: We need a "Raw Run" counter vs "Net Score"?
          // History tracks NET points.
          // If we want "run count", we'd need to parse `ballsRemaining` or separate property.
          // For now, let's just show Net Score + F.
          // "4 F" is unambiguous.
          if (notation == '-') notation = '0'; // force 0 if foul
          // notation += ' F'; 
          // Use superscript or just space?
          notation = '$notation F';
      }
      
      // Determine Total to display
      // runningTotal map tracks it.
      int total = runningTotal[pName]!;
      
      result[pName]![inning] = InningStat(notation, total);
      
      // Reset accumulators ONLY if not pending (finalized)
      // Actually, we must reset them to start fresh for NEXT inning.
      // If 'pending' is true, this is just a "peek", we shouldn't wipe data if we called this mid-loop?
      // But we call this at end of loop for pending. So wiping is fine or irrelevant.
      if (!pending) {
          inningPoints[pName] = 0;
          inningHasFoul[pName] = false;
          inningHasSafety[pName] = false;
          segments[pName]!.clear();
      }
  }
}

class InningStat {
  final String notation;
  final int total;
  InningStat(this.notation, this.total);
}
