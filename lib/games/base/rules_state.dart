/// Base class for game-specific state.
/// Each game type extends this with its own state requirements.
abstract class RulesState {
  /// Serialize to JSON for snapshot/persistence.
  Map<String, dynamic> toJson();
  
  /// Deserialize from JSON for restoration.
  static RulesState fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'fromJson must be implemented by concrete RulesState subclasses'
    );
  }
  
  /// Create a deep copy for undo/redo snapshots.
  RulesState copy();
}
