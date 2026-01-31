import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../codecs/notation_codec.dart'; // For InningRecord
import '../theme/fortune_theme.dart';

class ScoreCard extends StatelessWidget {
  final Player player1;
  final Player player2;
  final List<InningRecord> inningRecords;
  final String? winnerName;
  final bool isTrainingMode;

  const ScoreCard({
    super.key,
    required this.player1,
    required this.player2,
    required this.inningRecords,
    this.winnerName,
    this.isTrainingMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FortuneColors.of(context);
    
    // Group inning records by inning number
    final Map<int, Map<String, InningRecord>> inningsByNumber = {};
    for (var record in inningRecords) {
      if (!inningsByNumber.containsKey(record.inning)) {
        inningsByNumber[record.inning] = {};
      }
      inningsByNumber[record.inning]![record.playerName] = record;
    }

    // [NEW] Inject Active Inning Data (Real-time updates)
    for (var player in [player1, player2]) {
      // Check if player has active data for the CURRENT (unfinished) inning
      // Conditions:
      // 1. Has history segments (re-racks)
      // 2. Has current points (inningPoints > 0)
      // 3. Has pending flags (Foul, Safe, etc.)
      bool hasActiveData = player.inningHistory.isNotEmpty || 
                           player.inningPoints > 0 || 
                           player.inningHasFoul || 
                           player.inningHasBreakFoul || 
                           player.inningHasSafe;

      if (hasActiveData) {
         // Determine Foul Type
         FoulType currentFoul = FoulType.none;
         if (player.inningHasBreakFoul) {
           currentFoul = FoulType.breakFoul;
         } else if (player.inningHasThreeFouls) { // Prioritize 3-Foul
           currentFoul = FoulType.threeFouls;
         } else if (player.inningHasFoul) {
           currentFoul = FoulType.normal;
         }

         // Construct Notation Segments
         // Combine history + current points
         // NOTE: only add current points if > 0 OR if it's the only thing (to show '0'?) 
         // Actually, standard practice: if 14(1) . 0 -> Show 14 . 0
         List<int> liveSegments = [...player.inningHistory, player.inningPoints];
         
         // Create a temporary record
         try {
           final tempRecord = InningRecord(
             inning: player.currentInning,
             playerName: player.name,
             notation: '', // Will start empty, serialize below
             runningTotal: player.projectedScore, // Use projected score for live update
             segments: liveSegments,
             safe: player.inningHasSafe,
             foul: currentFoul,
           );
           
           // Generate the string using the Codec
           String liveNotation = NotationCodec.serialize(tempRecord);
           
           // Re-create record with valid notation string
           final finalRecord = InningRecord(
             inning: tempRecord.inning,
             playerName: tempRecord.playerName,
             notation: liveNotation,
             runningTotal: tempRecord.runningTotal,
             segments: tempRecord.segments,
             safe: tempRecord.safe,
             foul: tempRecord.foul
           );

           // Inject into map (Ensure map exists for this inning)
           if (!inningsByNumber.containsKey(player.currentInning)) {
             inningsByNumber[player.currentInning] = {};
           }
           inningsByNumber[player.currentInning]![player.name] = finalRecord;

         } catch (e) {
           // Fallback if logic fails (e.g. valid codec error), just don't show live data
           if (kDebugMode) {
             debugPrint('Error generating live notation: $e');
           }
         }
      }
    }
    
    // Determine max innings
    int maxInnings = player1.currentInning > player2.currentInning 
        ? player1.currentInning 
        : player2.currentInning;
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
                  flex: isTrainingMode ? 5 : 4,
                  child: Text(
                    player1.name.toUpperCase(),
                    style: TextStyle(
                      color: player1.name == winnerName 
                          ? colors.primaryBright 
                          : colors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (!isTrainingMode) ...[
                  Expanded(
                    flex: 1,
                    child: const SizedBox(), // Spacer for Inning column
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      player2.name.toUpperCase(),
                      style: TextStyle(
                        color: player2.name == winnerName 
                            ? colors.primaryBright 
                            : colors.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Arial',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
                if (!isTrainingMode) ...[
                  Expanded(flex: 2, child: _buildHeaderLabel(colors, 'TOTAL')),
                  Expanded(flex: 2, child: _buildHeaderLabel(colors, 'POINTS')),
                ],
              ],
            ),
          ),
          // Innings rows
          ...List.generate(
            maxInnings,
            (index) => _buildInningRow(context, index + 1, inningsByNumber),
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
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
        fontFamily: 'Arial',
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInningRow(BuildContext context, int inning, Map<int, Map<String, InningRecord>> inningsByNumber) {
    final colors = FortuneColors.of(context);

    // Get data for this inning
    final p1Record = inningsByNumber[inning]?[player1.name];
    final p2Record = inningsByNumber[inning]?[player2.name];
    
    String p1Notation = p1Record?.notation ?? '';
    String p1Total = p1Record != null ? '${p1Record.runningTotal}' : '';

    String p2Notation = p2Record?.notation ?? '';
    String p2Total = p2Record != null ? '${p2Record.runningTotal}' : '';

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
            child: Center(child: _buildNotationText(colors, p1Notation)),
          ),
          // P1 Total
          Expanded(
            flex: 2,
            child: Text(
              p1Total,
              style: TextStyle(color: colors.primary, fontSize: 14, fontFamily: 'Arial'),
              textAlign: TextAlign.center,
            ),
          ),
          // Inning #
          Expanded(
            flex: 1,
            child: Text(
              inning.toString(),
              style: TextStyle(
                color: colors.accent,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // P2 Total and Notation (hidden in training mode)
          if (!isTrainingMode) ...[
            Expanded(
              flex: 2,
               child: Text(
                p2Total,
                style: TextStyle(
                  color: colors.primaryBright,
                  fontSize: 14,
                  fontFamily: 'Arial',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // P2 Notation
            Expanded(
              flex: 2,
              child: Center(child: _buildNotationText(colors, p2Notation)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotationText(FortuneColors colors, String notation) {
      if (notation.isEmpty) return const SizedBox.shrink();
      
      // Format notation for display (Spec §9: Mixed Delimiters)
      final displayNotation = NotationCodec.formatForDisplay(notation);
      
      return Text(
          displayNotation, 
          style: TextStyle(color: colors.textMain, fontSize: 14, fontFamily: 'Arial'), 
          textAlign: TextAlign.center
      );
  }
}
