import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final p1 = provider.player1;
    final p2 = provider.player2;
    final innings = provider.inningHistory;

    // Calculations
    int p1InningsCount = 0;
    int p2InningsCount = 0;
    int p1HighRun = 0;
    int p2HighRun = 0;

    for (var turn in innings) {
      if (turn.player == 1) {
        p1InningsCount++;
        if (turn.points > p1HighRun) p1HighRun = turn.points;
      } else {
        p2InningsCount++;
        if (turn.points > p2HighRun) p2HighRun = turn.points;
      }
    }

    final p1Avg = p1InningsCount > 0 ? (p1.score / p1InningsCount).toStringAsFixed(2) : "0.00";
    final p2Avg = p2InningsCount > 0 ? (p2.score / p2InningsCount).toStringAsFixed(2) : "0.00";

    // Chart Data
    final p1Scores = [0.0];
    final p2Scores = [0.0];
    double p1Total = 0;
    double p2Total = 0;

    for (var turn in innings.reversed) {
      final net = (turn.points - turn.penalty).toDouble();
      if (turn.player == 1) {
        p1Total += net;
      } else {
        p2Total += net;
      }
      p1Scores.add(p1Total);
      p2Scores.add(p2Total);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(provider.t('statistics').toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats Table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(p1.name, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold))),
                        const Text("VS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(p2.name, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  _buildStatRow(provider.t('score'), "${p1.score}", "${p2.score}", highlight: true),
                  _buildStatRow(provider.t('innings'), "$p1InningsCount", "$p2InningsCount"),
                  _buildStatRow(provider.t('highRun'), "$p1HighRun", "$p2HighRun"),
                  _buildStatRow(provider.t('avg'), p1Avg, p2Avg),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Progression Chart
            Align(
              alignment: Alignment.centerLeft,
              child: Text(provider.t('progression').toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: p1Scores.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: const Color(0xFF22C55E),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: p2Scores.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: const Color(0xFF3B82F6),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String p1, String p2, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? Colors.white.withOpacity(0.05) : null,
        border: const Border(bottom: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(p1, style: TextStyle(color: highlight ? const Color(0xFF22C55E) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Expanded(child: Text(p2, textAlign: TextAlign.right, style: TextStyle(color: highlight ? const Color(0xFF3B82F6) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
        ],
      ),
    );
  }
}
