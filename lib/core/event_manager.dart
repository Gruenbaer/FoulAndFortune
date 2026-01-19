import 'events/game_event.dart';

/// Manages the event queue for UI animations and overlays.
/// 
/// Events are emitted by GameState throughout gameplay and consumed
/// by GameEventOverlay to drive animations, splashes, and dialogs.
/// Extracted from GameState as part of Phase 1.3 refactoring.
class EventManager {
  final List<GameEvent> _queue = [];

  /// Adds an event to the queue.
  void add(GameEvent event) {
    _queue.add(event);
  }

  /// Consumes and clears all events from the queue.
  /// Returns a copy of the events in emission order.
  List<GameEvent> consumeAll() {
    final events = List<GameEvent>.from(_queue);
    _queue.clear();
    return events;
  }

  /// Clears all events without returning them.
  void clear() {
    _queue.clear();
  }

  /// Returns true if there are pending events.
  bool get hasEvents => _queue.isNotEmpty;

  /// Returns the number of pending events.
  int get eventCount => _queue.length;
}
