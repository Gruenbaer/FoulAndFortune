/// Event types for shot-level event sourcing.
/// 
/// These are the only valid event types. DB stores as String (enum.name).
/// See SHOT_EVENT_SOURCING.md for specification.
enum ShotEventType {
  /// Every confirmed player action (pocket, foul, safety, miss)
  shot,
  
  /// Turn boundary: player's turn starts
  turnStart,
  
  /// Turn boundary: player's turn ends
  turnEnd,
  
  /// Re-rack event (normal or triple-foul)
  rerack,
}

/// Payload "kind" values for shot events.
/// 
/// Used inside the versioned JSON payload: {"v":1,"data":{"kind":"pocket",...}}
enum ShotKind {
  pocket,
  foul,
  safety,
  miss,
  
  /// Compensating event to void a previous action (for undo)
  void_,
}
