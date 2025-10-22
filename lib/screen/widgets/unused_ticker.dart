/// A simple ticker that calls [onTick] callback periodically with the elapsed time.
/// This implementation uses [Ticker] from Flutter's scheduler library.
/// It starts and stops the ticker based on the [start] and [stop] methods.
/// Dispose method should be called to clean up resources.
/// Usage:
/// ```dart
/// final ticker = Ticker((elapsed) {
///   // Handle tick
/// });
/// ticker.start();
/// ...
/// ticker.stop();
/// ticker.dispose();
/// ``` 
class Ticker {
  final void Function(Duration) onTick;
  Duration _elapsed = Duration.zero;
  bool _active = false;
  late final Stopwatch _stopwatch;
  Future<void>? _tickerFuture;

  Ticker(this.onTick) {
    _stopwatch = Stopwatch();
  }

  /// Starts the ticker.
  /// Calls the [onTick] callback periodically with the elapsed time. 
  void start() {
    if (_active) return;
    _active = true;
    _stopwatch.reset(); // set elapsed to zero
    _stopwatch.start();
    _tickerFuture ??= _tick();
  }

  /// Stops the ticker.
  void stop() {
    _active = false;
    _stopwatch.stop();
    _tickerFuture = null;
  }

  /// Disposes of the ticker and releases any resources.  
  void dispose() {
    _active = false;
    _stopwatch.stop();
  }

  /// Internal method that runs the ticker loop.  
  /// Calls the [onTick] callback with the elapsed time every 100 milliseconds.
  Future<void> _tick() async {
    while (_active) {
      await Future.delayed(const Duration(milliseconds: 100));
      _elapsed = _stopwatch.elapsed;
      onTick(_elapsed);
    }
  }
}
