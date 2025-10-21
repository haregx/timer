class Ticker {
  final void Function(Duration) onTick;
  Duration _elapsed = Duration.zero;
  bool _active = false;
  late final Stopwatch _stopwatch;
  Future<void>? _tickerFuture;

  Ticker(this.onTick) {
    _stopwatch = Stopwatch();
  }

  void start() {
    if (_active) return;
    _active = true;
    _stopwatch.reset(); // Verstrichene Zeit auf 0 setzen
    _stopwatch.start();
    _tickerFuture ??= _tick();
  }

  void stop() {
    _active = false;
    _stopwatch.stop();
    _tickerFuture = null;
  }

  void dispose() {
    _active = false;
    _stopwatch.stop();
  }

  Future<void> _tick() async {
    while (_active) {
      await Future.delayed(const Duration(milliseconds: 100));
      _elapsed = _stopwatch.elapsed;
      onTick(_elapsed);
    }
  }
}
