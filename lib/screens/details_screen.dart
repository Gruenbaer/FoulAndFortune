import 'package:flutter/material.dart';
import '../models/game_state.dart';

class DetailsScreen extends StatelessWidget {
  final GameState gameState;

  const DetailsScreen({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Statistics'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Player Comparison Table
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50], // Subtle background
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Player Stats',
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Table(
                  border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(3),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        const Padding(padding: EdgeInsets.all(8), child: Text('Metric', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: const EdgeInsets.all(8), child: Text(gameState.players[0].name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: const EdgeInsets.all(8), child: Text(gameState.players[1].name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                    // Score
                    _buildTableRow('Score', '${gameState.players[0].score}', '${gameState.players[1].score}', boldValue: true),
                    // Saves
                    _buildTableRow('Saves', '${gameState.players[0].saves}', '${gameState.players[1].saves}'),
                    // Innings
                    _buildTableRow('Inning', '${gameState.players[0].currentInning}', '${gameState.players[1].currentInning}'),
                    // Status
                    _buildTableRow('Active', gameState.players[0].isActive ? '🟢' : '', gameState.players[1].isActive ? '🟢' : ''),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1),
          
          // Match Log / Score Sheet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.grey[300],
                  child: const Text(
                    'SCORE SHEET',
                    style: TextStyle(
                      fontFamily: 'Arial', // Consistent with user request
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Compact
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: gameState.matchLog.isEmpty
                    ? const Center(child: Text('No history yet.', style: TextStyle(fontFamily: 'Arial')))
                    : Container(
                        color: Colors.white, // Pure white background
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: gameState.matchLog.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '#${gameState.matchLog.length - index}', 
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: 'Arial')
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      gameState.matchLog[index],
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 14,
                                        color: Colors.black, // High contrast
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String p1Value, String p2Value, {bool boldValue = false}) {
    final style = TextStyle(
      fontWeight: boldValue ? FontWeight.bold : FontWeight.normal, 
      fontSize: 14
    );
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Padding(padding: const EdgeInsets.all(8), child: Text(p1Value, style: style, textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(8), child: Text(p2Value, style: style, textAlign: TextAlign.center)),
      ],
    );
  }
}
