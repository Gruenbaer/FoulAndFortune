

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import 'overlays/game_overlay_contents.dart';
import 'themed_widgets.dart'; // For ThemedButton
import '../../theme/fortune_theme.dart';
import '../../l10n/app_localizations.dart';
import '../utils/ui_utils.dart'; // For showZoomDialog

/// Unified Overlay System handling the Game Event Queue
class GameEventOverlay extends StatefulWidget {
  const GameEventOverlay({super.key});

  @override
  State<GameEventOverlay> createState() => _GameEventOverlayState();
}

class _GameEventOverlayState extends State<GameEventOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Queue State
  final List<GameEvent> _localQueue = [];
  bool _isAnimating = false;
  Widget? _currentContent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // Standard Duration
    );

    // Zoom In (Elastic) -> Hold -> Zoom Out
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.2), weight: 60), // Hold
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 2.0), weight: 20), // Exit Zoom
    ]).animate(_controller);

    // Fade In -> Hold -> Fade Out
    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70), // Hold
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationComplete();
      }
    });
  }

  void _onAnimationComplete() {
    setState(() {
      _currentContent = null;
      _isAnimating = false;
    });
    _controller.reset();
    _processNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processNext() {
    if (_isAnimating || _localQueue.isEmpty) return;

    final event = _localQueue.removeAt(0);

    // SPECIAL CASE: Decision Event (Dialog)
    // We handle this outside the standard animation loop because it requires user interaction
    if (event is DecisionEvent) {
      _showDecisionDialogHelper(event.title, event.message, event.options, event.onOptionSelected);
      return;
    }
    
    // SPECIAL CASE: Warning Event (Dialog)
    if (event is WarningEvent) {
      _showWarningDialog(event.title, event.message);
      return;
    }
    
    // SPECIAL CASE: Two Fouls Warning (Localized Dialog)
    if (event is TwoFoulsWarningEvent) {
      // Defer to post-frame to ensure Context access
       WidgetsBinding.instance.addPostFrameCallback((_) {
          final l10n = AppLocalizations.of(context);
          _showWarningDialog(l10n.twoFoulsWarning, l10n.twoFoulsMessage);
       });
       return;
    }

    // SPECIAL CASE: Break Foul Decision (Localized Dialog)
    if (event is BreakFoulDecisionEvent) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          final l10n = AppLocalizations.of(context);
          _showDecisionDialogHelper(
              l10n.breakFoulTitle, 
              l10n.whoBreaksNext,
              event.options, 
              event.onOptionSelected
          );
       });
       return;
    }

    _isAnimating = true;
    Widget? content;

    if (event is FoulEvent) {
      // Resolve message based on Type
      // We need context to localize, but we are in State used by build, so implicit/inherited context is available.
      // However, _processNext is called from listener/callback. context is valid.
      final l10n = AppLocalizations.of(context);
      String message;
      String? subMessage;
      
      switch (event.type) {
        case FoulType.normal:
          message = "FOUL"; 
          // Use localized if available, or hardcoded "FOUL" to match previous behavior
          // app_en has "foulMinusOne": "Foul -1". 
          // Maybe stick to simple "FOUL" for now or use l10n.foulMinusOne.
          // User wants "Show penalty points below".
          // The SplashContent likely handles subtitle.
          // Let's pass "FOUL" as message.
          // Wait, check if "FOUL" is localized. NO key for just "FOUL".
          // I will use "FOUL" literal for now as it's universal-ish or add "foul" key?
          // I'll use "FOUL" to be safe or reuse "twoFoulsWarning" -> "2 FOULS!".
          // Let's just use "FOUL" for now to minimize risk found in 'check all texts'.
          // Actually, I should check if I can separate the "FOUL" string.
          // app_en.arb has "noFoul", "foulMinusOne".
          // I'll use l10n.foulMinusOne for now, it's "Foul -1".
          message = l10n.foulMinusOne.replaceAll(" -1", ""); // Hack? No.
          message = "FOUL"; // Fallback to english/capital
          if (l10n.localeName == 'de') message = "FOUL"; // Same
          break;
        case FoulType.breakFoul:
          message = AppLocalizations.of(context).breakFoulMinusTwo.replaceAll(" -2", "").trim(); 
          if(message.isEmpty) message = "BREAK FOUL";
          break;
        case FoulType.threeFouls:
          message = AppLocalizations.of(context).threeFoulsTitle;
          break;
      }
      
      content = FoulSplashContent(message: message, penaltyPoints: event.points);

    } else if (event is SafeEvent) {
      content = const SafeSplashContent();
    } else if (event is ReRackEvent) {
      content = ReRackSplashContent(title: event.type);
      
      // We need to trigger the physical re-rack (hiding balls) *after* animation?
      // Or during?
      // Existing code: `finalizeReRack` called AFTER overlay finishes.
      // Let's utilize the callback mechanism or just do it on complete.
      // We need to know WHEN to trigger the state change.
      // We can attach a callback to `.then()` of the animation, but we are in a centralized loop.
      
      // Let's execute the side-effect when animation completes (in _onAnimationComplete logic?)
      // We need to store the event to know what side effect to run.
      // Or just run it now if it's purely visual? 
      // Re-rack clears the table visually. If we run it now, balls disappear before splash?
      // No, we want balls to disappear *after* splash screen covers them?
      // Or `finalizeReRack` calls `_resetRack` which puts balls back.
      // Wait. `_resetRack` sets balls to 15.
      // If we do it at end, we see old state -> Splash -> New State. Correct.
    } 

    if (content != null) {
      setState(() {
        _currentContent = content;
      });
      _controller.forward().then((_) {
        // Post-Animation Logic
        if (event is ReRackEvent) {
           Provider.of<GameState>(context, listen: false).finalizeReRack();
        }
      });
    } else {
      // Skip unknown event
      _isAnimating = false;
      _processNext();
    }
  }
  
  void _showWarningDialog(String title, String message) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        showZoomDialog(
        context: context,
        builder: (dialogContext) {
          final l10n = AppLocalizations.of(dialogContext);
          final colors = FortuneColors.of(dialogContext);
          return AlertDialog(
            backgroundColor: colors.backgroundCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.primary, width: 2)),
            title: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colors.primaryBright, fontWeight: FontWeight.bold)),
            content: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMain, fontSize: 16)),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ThemedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _processNext(); // Continue queue
                },
                label: l10n.gotIt,
              ),
            ],
          );
        },
      );
     });
  }

  void _showDecisionDialogHelper(String title, String message, List<String> options, Function(int) onSelected) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      showZoomDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final colors = FortuneColors.of(context);
          return AlertDialog(
            backgroundColor: colors.backgroundCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.primary, width: 2)),
            title: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colors.primaryBright, fontWeight: FontWeight.bold)),
            content: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMain)),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              ThemedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSelected(0);
                  _processNext(); // Continue queue
                },
                label: options[0],
              ),
              const SizedBox(width: 8),
              ThemedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSelected(1);
                  _processNext(); // Continue queue
                },
                label: options[1],
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // Consume events from GameState and add to local queue
        // PRO TIP: In build(), we shouldn't modify state directly or consume excessively if build is called often.
        // GameState handles `consumeEvents` which clears the queue.
        // We must ensure this build is triggered when events are added. (GameState notifies listeners).
        
        final newEvents = gameState.consumeEvents();
        if (newEvents.isNotEmpty) {
          _localQueue.addAll(newEvents);
          // Trigger processing if idle
          if (!_isAnimating) {
             // Use post frame to avoid setstate during build
             WidgetsBinding.instance.addPostFrameCallback((_) => _processNext());
          }
        }

        if (_currentContent == null) return const SizedBox.shrink();

        return Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _currentContent, // Display the content
                ),
              );
            },
          ),
        );
      },
    );
  }
}
