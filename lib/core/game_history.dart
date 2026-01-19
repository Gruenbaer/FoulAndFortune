import 'package:flutter/foundation.dart';

/// History manager for undo/redo functionality.
/// 
/// Manages stacks of opaque state snapshots that can be pushed, undone, and redone.
/// The actual snapshot type is generic to allow different state implementations.
class GameHistory<T> {
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];
  
  /// Callback for when history state changes (for UI updates)
  VoidCallback? onHistoryChanged;
  
  /// Whether undo is available
  bool get canUndo => _undoStack.isNotEmpty;
  
  /// Whether redo is available
  bool get canRedo => _redoStack.isNotEmpty;
  
  /// Push a new snapshot onto the undo stack
  void push(T snapshot) {
    _undoStack.add(snapshot);
    _redoStack.clear(); // Clear redo on new action
    onHistoryChanged?.call();
  }
  
  /// Undo to previous snapshot
  /// Returns the snapshot to restore, or null if none available
  T? undo(T currentState) {
    if (!canUndo) return null;
    
    // Save current state to redo stack
    _redoStack.add(currentState);
    
    // Get and remove last snapshot from undo stack
    final snapshot = _undoStack.removeLast();
    onHistoryChanged?.call();
    return snapshot;
  }
  
  /// Redo to next snapshot
  /// Returns the snapshot to restore, or null if none available
  T? redo(T currentState) {
    if (!canRedo) return null;
    
    // Save current state to undo stack
    _undoStack.add(currentState);
    
    // Get and remove last snapshot from redo stack
    final snapshot = _redoStack.removeLast();
    onHistoryChanged?.call();
    return snapshot;
  }
  
  /// Clear all history
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    onHistoryChanged?.call();
  }
}
