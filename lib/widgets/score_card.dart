import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_state.dart'; // For InningRecord
import '../theme/fortune_theme.dart';

class ScoreCard extends StatelessWidget {
  final Player player1;
  final Player player2;
  final List<InningRecord> inningRecords;
  final String? winnerName;

  const ScoreCard({
    super.key,
    required this.player1,
    required this.player2,
    required this.inningRecords,
    this.winnerName,
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
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
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
              style: TextStyle(color: colors.primary, fontSize: 12),
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
                fontSize: 12,
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
                color: colors.primaryBright,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // P2 Notation
          Expanded(
            flex: 2, // FIXED: from 3 to 2 to match Header
            child: Center(child: _buildNotationText(colors, p2Notation)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotationText(FortuneColors colors, String notation) {
      if (notation.isEmpty) return const SizedBox.shrink();
      // No coloring, just plain text as requested (reverting previous change)
      return Text(
          notation, 
          style: TextStyle(color: colors.textMain, fontSize: 12), 
          textAlign: TextAlign.center
      );
  }
}
