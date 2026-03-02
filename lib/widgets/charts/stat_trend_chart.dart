import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/game_trend_point.dart';
import '../../theme/fortune_theme.dart';

class StatTrendChart extends StatelessWidget {
  final List<GameTrendPoint> dataPoints;
  final double Function(GameTrendPoint) valueMapper;
  final String title;
  final bool isInteger;

  const StatTrendChart({
    super.key,
    required this.dataPoints,
    required this.valueMapper,
    required this.title,
    this.isInteger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FortuneColors>()!;

    if (dataPoints.isEmpty || dataPoints.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primaryDark),
        ),
        child: Center(
          child: Text(
            'Not enough data to show $title trend.',
            style: TextStyle(color: colors.textMain, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    // Extract values
    final yValues = dataPoints.map(valueMapper).toList();
    final minY = yValues.reduce((a, b) => a < b ? a : b);
    var maxY = yValues.reduce((a, b) => a > b ? a : b);
    
    // Add some padding to the top of the chart
    if (maxY == minY) maxY += 1.0; 
    final topPadding = (maxY - minY) * 0.2;
    maxY += topPadding;

    final spots = dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), valueMapper(e.value));
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textMain,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colors.primaryDark.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: dataPoints.length > 5 ? (dataPoints.length / 5).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dataPoints.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM/dd').format(dataPoints[index].date),
                            style: TextStyle(
                              color: colors.textMain.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxY - minY) / 4 > 0 ? ((maxY - minY) / 4) : 1,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          isInteger ? value.toInt().toString() : value.toStringAsFixed(1),
                          style: TextStyle(
                            color: colors.textMain.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: colors.primaryDark, width: 2),
                    left: BorderSide(color: colors.primaryDark, width: 2),
                    top: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),
                minX: 0,
                maxX: (dataPoints.length - 1).toDouble(),
                minY: minY > 0 ? (minY * 0.8) : 0, // Add bottom padding
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: colors.accent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: colors.accent,
                          strokeWidth: 2,
                          strokeColor: colors.backgroundCard,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colors.warning,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final valStr = isInteger 
                            ? spot.y.toInt().toString() 
                            : spot.y.toStringAsFixed(2);
                        return LineTooltipItem(
                          valStr,
                          TextStyle(
                            color: colors.textContrast,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
