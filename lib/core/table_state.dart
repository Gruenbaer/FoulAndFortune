/// Manages the physical state of balls on the table
class TableState {
  Set<int> _activeBalls = {};
  
  /// Current balls on table (1-15)
  Set<int> get activeBalls => Set.unmodifiable(_activeBalls);
  
  /// Number of balls currently on table
  int get count => _activeBalls.length;
  
  /// Reset to full 15-ball rack
  void resetRack() {
    _activeBalls = Set.from(List.generate(15, (i) => i + 1));
  }
  
  /// Update active balls to specific count (0-15)
  void updateCount(int count) {
    if (count < 0) count = 0;
    if (count > 15) count = 15;
    _activeBalls = Set.from(List.generate(count, (i) => i + 1));
  }
  
  /// Serialize for snapshots
  Map<String, dynamic> toJson() {
    return {
      'activeBalls': _activeBalls.toList(),
    };
  }
  
  /// Restore from snapshot
  void loadFromJson(Map<String, dynamic> json) {
    _activeBalls = Set<int>.from(json['activeBalls'] ?? []);
  }
}
