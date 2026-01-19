import '../../models/player.dart';
import '../../codecs/notation_codec.dart'; // For FoulType

/// Base class for all game events that trigger UI animations and overlays.
/// 
/// Events are emitted by GameState and consumed by GameEventOverlay.
/// Extracted from GameState as part of Phase 1.3 refactoring.
abstract class GameEvent {}

/// Event triggered when a player commits a foul.
class FoulEvent extends GameEvent {
  final Player player;
  final int points;
  final FoulType type;
  final int? positivePoints; // Optional: balls pocketed for breakdown display
  final int? penalty; // Optional: foul penalty for breakdown display

  FoulEvent(this.player, this.points, this.type,
      {this.positivePoints, this.penalty});
}

/// Event triggered when a player has 2 consecutive fouls (warning).
class TwoFoulsWarningEvent extends GameEvent {}

/// Event triggered for general warnings to the player.
class WarningEvent extends GameEvent {
  final String title;
  final String message;
  WarningEvent(this.title, this.message);
}

/// Event triggered when a re-rack occurs.
class ReRackEvent extends GameEvent {
  final String type; // "14.1 Continuous", "After Foul", "Auto/Safe"
  ReRackEvent(this.type);
}

/// Event triggered when the game needs a player decision.
class DecisionEvent extends GameEvent {
  final String title;
  final String message;
  final List<String> options;
  final Function(int) onOptionSelected;

  DecisionEvent(this.title, this.message, this.options, this.onOptionSelected);
}

/// Event triggered when a break foul requires a decision on who breaks next.
class BreakFoulDecisionEvent extends GameEvent {
  final List<String> options;
  final Function(int) onOptionSelected;
  BreakFoulDecisionEvent(this.options, this.onOptionSelected);
}

/// Event triggered when a player makes a safe shot.
class SafeEvent extends GameEvent {}
