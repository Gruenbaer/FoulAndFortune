import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../theme/fortune_theme.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (!gameState.isPaused) return const SizedBox.shrink();

        final colors = FortuneColors.of(context);
        final isCyberpunk = colors.themeId == 'cyberpunk';

        return GestureDetector(
          onTap: gameState.resumeGame,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: Align(
              alignment: const Alignment(0, -0.12),
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  margin: const EdgeInsets.only(top: 72),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  decoration: isCyberpunk
                      ? BoxDecoration(
                          color: colors.backgroundCard.withOpacity(0.9),
                          border: Border.all(color: colors.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: colors.primary.withOpacity(0.5),
                                blurRadius: 20),
                          ],
                        )
                      : BoxDecoration(
                          color: colors.backgroundCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.primary, width: 3),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(0, 4)),
                          ],
                        ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GAME PAUSED',
                        textAlign: TextAlign.center,
                        style: isCyberpunk
                            ? GoogleFonts.orbitron(
                                fontSize: 32,
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(color: colors.primary, blurRadius: 10)
                                ],
                              )
                            : GoogleFonts.rye(
                                fontSize: 32,
                                color: colors.primary,
                                letterSpacing: 2,
                                shadows: [
                                  const Shadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                      offset: Offset(2, 2))
                                ],
                              ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Zeit bleibt oben sichtbar. Tippe irgendwo zum Fortsetzen.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.textMain.withOpacity(0.82),
                            ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCyberpunk
                                ? colors.secondary
                                : colors.primaryDark,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color:
                              isCyberpunk ? colors.secondary : colors.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
