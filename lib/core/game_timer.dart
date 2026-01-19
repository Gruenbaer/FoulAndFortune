import 'dart:async';

/// Game timer for tracking elapsed time during a billiards game.
/// 
/// Handles start, pause, resume, and provides elapsed duration.
/// Notifies listeners via callback when time updates (every second).
class GameTimer {
  final Stopwatch _stopwatch = Stopwatch();
  Duration _savedDuration = Duration.zero;
  Timer? _ticker;
  bool _isPaused = false;
  
  /// Callback invoked every second when timer is running (for UI updates)
  VoidCallback? onTick;
  
  /// Whether the timer is currently paused
  bool get isPaused => _isPaused;
  
  /// Total elapsed duration (saved + current stopwatch)
  Duration get elapsedDuration => _savedDuration + _stopwatch.elapsed;
  
  /// Whether the timer is currently running
  bool get isRunning => _stopwatch.isRunning;
  
  /// Start the timer
  void start() {
    if (!_stopwatch.isRunning && !_isPaused) {
      _stopwatch.start();
      _startTicker();
    }
  }
  
  /// Pause the timer
  void pause() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _isPaused = true;
      _stopTicker();
      onTick?.call();
    }
  }
  
  /// Resume the timer from a paused state
  void resume() {
    if (_isPaused) {
      _stopwatch.start();
      _isPaused = false;
      _startTicker();
      onTick?.call();
    }
  }
  
  /// Toggle between paused and running
  void toggle() {
    if (_isPaused) {
      resume();
    } else {
      pause();
    }
  }
  
  /// Reset only the stopwatch (keeps savedDuration for restoration)
  void resetStopwatch() {
    _stopwatch.reset();
    _isPaused = false;
    _stopTicker();
  }
  
  /// Reset the timer to zero
  void reset() {
    _stopwatch.reset();
    _savedDuration = Duration.zero;
    _isPaused = false;
    _stopTicker();
  }
  
  /// Load a saved duration (for resuming games)
  void loadSavedDuration(Duration duration) {
    _savedDuration = duration;
  }
  
  /// Clean up resources
  void dispose() {
    _stopTicker();
  }
  
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      onTick?.call(); // Notify every second for UI updates
    });
  }
  
  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

/// Type alias for void callback (for onTick)
typedef VoidCallback = void Function();
