import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Added for Provider
import 'package:foulandfortune/models/game_state.dart'; // Added for GameState
import 'package:foulandfortune/models/player.dart';
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'dart:async';

class PlayerPlaque extends StatefulWidget {
  final Player player;
  final int raceToScore;
  final bool isLeft;

  const PlayerPlaque({
    super.key,
    required this.player,
    required this.raceToScore,
    required this.isLeft,
  });

  @override
  State<PlayerPlaque> createState() => PlayerPlaqueState();
}

class PlayerPlaqueState extends State<PlayerPlaque> with TickerProviderStateMixin {
  late AnimationController _effectController;

  
  // UI Logic: Visual Score (delayed update)
  late int _visualScore;
  Timer? _safetyTimer;

  // Animation for last points box pulse
  late AnimationController _lastPointsController;
  late Animation<double> _lastPointsPulse;

  // Track last update for animation trigger
  int _lastUpdateCount = -1;
  
  // Key for Animation Targeting
  final GlobalKey scoreKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _effectController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    

    
    
    
    // Last points pulse: 1.0 -> 5.0 -> Hold -> 1.0
    _lastPointsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // Slightly longer total
    );
    
    _lastPointsPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 5.0), weight: 20), // Grow
      TweenSequenceItem(tween: ConstantTween(5.0), weight: 40), // Hold
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 1.0), weight: 40), // Shrink back
    ]).animate(CurvedAnimation(
      parent: _lastPointsController,
      curve: Curves.easeOut,
    ));
    
    // Add listener to trigger rebuild when animation changes
    _lastPointsController.addListener(() {
      if (mounted) {
        setState(() {}); // Trigger rebuild
      }
    });

    _visualScore = widget.player.projectedScore; // Init with projected
    _lastUpdateCount = widget.player.updateCount;
  }

  @override
  void didUpdateWidget(PlayerPlaque oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger animation when lastPoints changes
    // Trigger animation when score/points updated (tracked by updateCount)
    if (widget.player.updateCount != _lastUpdateCount) {
      _lastUpdateCount = widget.player.updateCount;
      _lastPointsController.forward(from: 0.0); // Trigger pulse animation
    }
    
    // Always update immediately to prevent desync
    if (_visualScore != widget.player.projectedScore) {
      setState(() {
        _visualScore = widget.player.projectedScore;
      });
    }
    

  }

  @override
  void dispose() {
    _effectController.dispose();
    _lastPointsController.dispose();
    _safetyTimer?.cancel();
    super.dispose();
  }

  // Exposed method to trigger effect AND update score
  // Exposed method to trigger effect AND update score
  void triggerPenaltyImpact() {
    // Award the score (Sync visual to actual)
    final targetScore = widget.player.projectedScore;
    if (_visualScore != targetScore) {
      setState(() {
        _visualScore = targetScore;
      });
    }
    _safetyTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = FortuneColors.of(context);
    final isActive = widget.player.isActive;

    // Check theme for shape
    final isCyberpunk = colors.themeId == 'cyberpunk';
    
    // Determine Text Color (Normal or Flash)
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: AnimatedBuilder(
        animation: _effectController,
        builder: (context, child) {
        // Score Color: Always Golden (no flash)
        final nameColor = isActive ? colors.primaryBright : colors.primary;
        const scoreColor = Color(0xFFFFD700); // Standard Gold always

        return Container(
            // No fixed height constraints - controlled by Parent IntrinsicHeight
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
                  shape: isCyberpunk 
                      ? BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isActive ? colors.primaryBright : colors.primaryDark,
                            width: isActive ? 3 : 2,
                          ),
                        )
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isActive ? colors.primaryBright : colors.primaryDark,
                            width: isActive ? 3 : 2,
                          ),
                        ),
                  shadows: [
                    // Outer shadow for depth
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                    // Inner Glow for active player
                    if (isActive)
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                  // Subtle gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.backgroundCard,
                      Color.lerp(colors.backgroundCard, Colors.black, 0.4)!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      widget.isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  children: [
                  // Player Name
                  Text(
                    widget.player.name.toUpperCase(),
                    style: GoogleFonts.nunito( // Rounded font
                      textStyle: theme.textTheme.labelLarge,
                      color: nameColor,
                      letterSpacing: 1.5,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Score Display (Nixie Tube / Neon)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: widget.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          key: scoreKey,
                          '$_visualScore',
                          style: GoogleFonts.nunito(
                            textStyle: theme.textTheme.displayMedium,
                            color: scoreColor,
                            fontSize: 42,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              const Shadow(
                                color: scoreColor,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ ${widget.raceToScore}',
                          style: GoogleFonts.nunito(
                            textStyle: theme.textTheme.bodyMedium,
                            color: colors.primaryDark,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        // Foul Indicators (Red X) - Moved to right of score
                        if (widget.player.consecutiveFouls > 0) ...[
                          const SizedBox(width: 12),
                          ...List.generate(widget.player.consecutiveFouls, (index) => 
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.close, 
                                color: Colors.redAccent, 
                                size: 24,
                                shadows: [
                                  Shadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 4),
                                ],
                              ),
                            )
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Stats Row: Last Points | HR
                  Row(
                    mainAxisAlignment: widget.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      // Last Points (Left) - Always shown, animated via listener
                      // Last Points / Run Indicator
                      // Shows Cumulative Run
                      Builder(
                        builder: (context) {
                          // ═══════════════════════════════════════════════
                          // CRITICAL FIX: Use currentPlayerIndex for LR logic
                          // NOT isActive (which has 800ms visual delay)
                          // This ensures LR shows correct value even during
                          // the delayed visual switch window
                          // ═══════════════════════════════════════════════
                          
                          // Listen to GameState to trigger rebuilds
                          final gameState = Provider.of<GameState>(context, listen: true);
                          
                          // Determine if THIS player is the LOGICAL turn owner
                          // (not just visually highlighted)
                          final isLogicallyActive = gameState.currentPlayerIndex == 
                              (identical(widget.player, gameState.players[0]) ? 0 : 1);
                          
                          int runValue;
                          
                          if (isLogicallyActive) {
                             // Logical turn owner: show LIVE run accumulation
                             // Special case: if currentRun is 0 (just reset) but lastRun != 0
                             // this means turn just ended, show the completed run
                             if (widget.player.currentRun == 0 && widget.player.lastRun != 0) {
                               runValue = widget.player.lastRun;
                             } else {
                               // Active turn, showing live accumulation
                               runValue = widget.player.currentRun;
                               
                               // CRITICAL: Apply PENDING foul penalties
                               // This shows NET run during active play
                               if (widget.player.inningHasBreakFoul) {
                                 runValue -= 2; // Break foul penalty
                               } else if (widget.player.inningHasFoul) {
                                 runValue -= 1; // Normal foul penalty
                               }
                             }
                          } else {
                             // Not turn owner: show last completed run
                             runValue = widget.player.lastRun;
                          }

                          
                          // Always show sign (+0, +5, -1)
                          final String runText = runValue >= 0 ? '+$runValue' : '$runValue';
                          
                          // Color logic: 0 is Accent (for visibility), Negative Red
                          final Color valColor = runValue < 0 ? FortuneColors.of(context).danger : colors.accent;

                          return Transform.scale(
                            scale: _lastPointsPulse.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              constraints: const BoxConstraints(minWidth: 32),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: valColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'LR',
                                    style: GoogleFonts.nunito(
                                      textStyle: theme.textTheme.bodySmall,
                                      color: Colors.white70, // Lighter for readability
                                      fontSize: 8, 
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    runText,
                                    style: GoogleFonts.nunito(
                                      textStyle: theme.textTheme.bodySmall,
                                      color: valColor,
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                        }
                      ),
                      
                      // Spacer to center AVG
                      const Spacer(),

                      // Middle Box: AVG (Score / Inning)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        constraints: const BoxConstraints(minWidth: 32),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.primaryDark.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'AVG',
                              style: GoogleFonts.nunito(
                                textStyle: theme.textTheme.bodySmall,
                                color: const Color(0xFFB0B0B0), // Light Grey
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              (widget.player.score / (widget.player.currentInning > 0 ? widget.player.currentInning : 1)).toStringAsFixed(1),
                              style: GoogleFonts.nunito( // Rounded font
                                textStyle: theme.textTheme.bodySmall,
                                color: colors.textMain, // Readable Light Grey/White
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Spacer to push HR to right
                      const Spacer(), 

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        constraints: const BoxConstraints(minWidth: 32),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.primaryDark.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'HR',
                              style: GoogleFonts.nunito(
                                textStyle: theme.textTheme.bodySmall,
                                color: const Color(0xFFB0B0B0), // Light Grey
                                fontSize: 8, // Increased from 9
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${widget.player.highestRun}',
                              style: GoogleFonts.nunito(
                                textStyle: theme.textTheme.bodySmall,
                                color: colors.textMain, // Readable Light Grey/White
                                fontSize: 12, // Increased from 11
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
      },
    ),
    );
  }
}
