import 'package:flutter/material.dart';
import 'pool_ball.dart';

class Rack extends StatelessWidget {
  final int ballsOnTable;
  final Set<int> activeBalls;
  final Function(int) onToggle;
  final bool is141Mode;

  const Rack({
    super.key,
    required this.ballsOnTable,
    required this.activeBalls,
    required this.onToggle,
    this.is141Mode = false,
  });

  @override
  Widget build(BuildContext context) {
    const double ballSize = 48.0;
    const double gap = 2.0;
    const double rowHeight = ballSize * 0.86;

    Offset getPos(int row, int col) {
      final double xOffset = -(row * (ballSize + gap) / 2);
      final double x = xOffset + col * (ballSize + gap);
      final double y = row * rowHeight;
      return Offset(x, y);
    }

    return Center(
      child: Container(
        width: 300,
        height: 260,
        alignment: Alignment.center,
        child: SizedBox(
          width: 300,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(15, (i) {
              if (is141Mode && i == 0) return const SizedBox.shrink();

              int r = 0, c = 0, idx = i;
              if (idx >= 10) {
                r = 4;
                c = idx - 10;
              } else if (idx >= 6) {
                r = 3;
                c = idx - 6;
              } else if (idx >= 3) {
                r = 2;
                c = idx - 3;
              } else if (idx >= 1) {
                r = 1;
                c = idx - 1;
              } else {
                r = 0;
                c = 0;
              }

              final pos = getPos(r, c);
              final isPotted = !activeBalls.contains(i);

              return Positioned(
                left: 150 + pos.dx - ballSize / 2,
                top: 20 + pos.dy,
                child: GestureDetector(
                  onTap: () => onToggle(i),
                  child: PoolBall(
                    number: i + 1,
                    size: ballSize,
                    isPotted: isPotted,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
