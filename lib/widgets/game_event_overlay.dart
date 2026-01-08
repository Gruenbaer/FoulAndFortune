import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foulandfortune/models/game_state.dart';
import 'package:foulandfortune/codecs/notation_codec.dart'; // For FoulType
import 'package:foulandfortune/widgets/overlays/game_overlay_contents.dart';
import 'package:foulandfortune/widgets/themed_widgets.dart'; // For ThemedButton
import 'package:foulandfortune/theme/fortune_theme.dart';
import 'package:foulandfortune/l10n/app_localizations.dart';
import 'package:foulandfortune/utils/ui_utils.dart'; // For showZoomDialog

/// Unified Overlay System handling the Game Event Queue


// Notification to bubble up shake request to parent Scaffold
class ScreenShakeNotification extends Notification {}

class GameEventOverlay extends StatefulWidget {
  const GameEventOverlay({super.key});

  @override
  State<GameEventOverlay> createState() => GameEventOverlayState();
}

class GameEventOverlayState extends State<GameEventOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeOffset;

  // Queue State
  final List<GameEvent> _localQueue = [];
  bool _isAnimating = false;
  Widget? _currentContent;
  GameState?
      _currentGameState; // Store reference to avoid Provider lookup in callbacks
  GameEvent? _currentEvent; // Store current event for post-animation logic
  
  // Public getter for game screen to check if animations are playing
  bool get isAnimating => _isAnimating;

  // Static method to check if any overlay is animating
  static bool isAnyAnimating(BuildContext context) {
    try {
      final state = context.findAncestorStateOfType<GameEventOverlayState>();
      return state?._isAnimating ?? false;
    } catch (e) {
      return false;
    }
  }


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

    // Initialize shake controller for triple foul
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Shake animation: rapid oscillation
    final shakeTween = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.05, 0), end: Offset.zero),
          weight: 1),
    ]);
    _shakeOffset = shakeTween.animate(_shakeController);
  }

  void _triggerScreenShake() {
    // Notify parent to shake the whole screen
    ScreenShakeNotification().dispatch(context);
    // _shakeController.forward(from: 0.0); // Disable local shake to avoid double-shake
  }

  void _onAnimationComplete() {
    // Handle post-animation logic for ReRackEvent
    if (_currentEvent is ReRackEvent && _currentGameState != null) {
      debugPrint(
          '[GameEventOverlay] ReRackEvent animation complete, calling finalizeReRack()');
      try {
        _currentGameState!.finalizeReRack();
        debugPrint('[GameEventOverlay] ✓ finalizeReRack() succeeded');
      } catch (e) {
        debugPrint('[GameEventOverlay] ✗ ERROR in finalizeReRack(): $e');
      }
    }

    setState(() {
      _currentContent = null;
      _isAnimating = false;
      _currentEvent = null;
      _currentGameState = null;
    });
    _controller.reset();
    _processNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _processNext() {
    if (_isAnimating || _localQueue.isEmpty) return;

    final event = _localQueue.removeAt(0);

    // SPECIAL CASE: Decision Event (Dialog)
    // We handle this outside the standard animation loop because it requires user interaction
    if (event is DecisionEvent) {
      _showDecisionDialogHelper(
          event.title, event.message, event.options, event.onOptionSelected);
      return;
    }

    // SPECIAL CASE: Warning Event (Dialog)
    if (event is WarningEvent) {
      // Keys could be localization keys or direct strings
      // We translate here if they are keys
      final l10n = AppLocalizations.of(context);
      // Translate keys to localized strings
      String title = event.title;
      String message = event.message;
      
      // Check if it's a localization key and translate it
      if (title == 'illegalMoveTitle') title = l10n.illegalMoveTitle;
      if (message == 'cannotFoulAndLeave1Ball') message = l10n.cannotFoulAndLeave1Ball;
      if (message == 'cannotFoulAndDoubleSack') message = l10n.cannotFoulAndDoubleSack;
      
      // Mark as animating so queue doesn't process next event
      setState(() {
        _isAnimating = true;
        _currentEvent = event;
      });
      
      _showWarningDialog(title, message);
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
        _showDecisionDialogHelper(l10n.breakFoulTitle, l10n.whoBreaksNext,
            event.options, event.onOptionSelected);
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


      switch (event.type) {
        case FoulType.none:
          // This shouldn't happen in a FoulEvent, but handle it for exhaustiveness
          message = l10n.foul;
          break;
        case FoulType.normal:
          message = l10n.foul;
          break;
        case FoulType.breakFoul:
          message = AppLocalizations.of(context)
              .breakFoulMinusTwo
              .replaceAll(" -2", "")
              .trim();
          if (message.isEmpty) message = "BREAK FOUL";
          break;
        case FoulType.threeFouls:
          message = AppLocalizations.of(context).threeFoulsTitle;
          _triggerScreenShake(); // Screen shake effect ONLY for triple foul
          break;
      }

      content =
          FoulSplashContent(message: message, penaltyPoints: event.points);
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
        _currentEvent = event; // Store event for post-animation logic
      });
      _controller.forward();
    } else {
      // Skip unknown event
      _isAnimating = false;
      _processNext();
    }
  }

  void _showWarningDialog(String title, String message) {
    showZoomDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        final colors = FortuneColors.of(dialogContext);
        return AlertDialog(
          backgroundColor: colors.backgroundCard,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.yellowAccent, width: 3)), // Yellow Border
          title: Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 24)), // Yellow Title
          content: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMain, fontSize: 16)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ThemedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Reset animation state before processing next
                setState(() {
                  _isAnimating = false;
                  _currentEvent = null;
                });
                _processNext(); // Continue queue
              },
              label: l10n.gotIt,
            ),
          ],
        );
      },
    );
  }

  void _showDecisionDialogHelper(String title, String message,
      List<String> options, Function(int) onSelected) {
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
    debugPrint(
        '[GameEventOverlay] build() called - checking for GameState provider');
    try {
      final testProvider = Provider.of<GameState>(context, listen: false);
      debugPrint(
          '[GameEventOverlay] ✓ GameState provider found: ${testProvider.runtimeType}');
    } catch (e) {
      debugPrint(
          '[GameEventOverlay] ✗ ERROR: GameState provider NOT found: $e');
    }

    return Consumer<GameState>(
      builder: (context, gameState, child) {
        debugPrint('[GameEventOverlay] Consumer builder called');
        // Store gameState reference for use in callbacks
        _currentGameState = gameState;

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
          child: SlideTransition(
            position: _shakeOffset,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Interactive content (Dialogs) should block.
                // Splash content (ReRack, Foul, etc.) should NOT block touches.
                // We check _currentEvent type.
                
                final bool isInteractive = _currentEvent is DecisionEvent || 
                                         _currentEvent is WarningEvent || 
                                         _currentEvent is TwoFoulsWarningEvent ||
                                         _currentEvent is BreakFoulDecisionEvent;
                
                return IgnorePointer(
                  ignoring: !isInteractive,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _currentContent, // Display the content
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
