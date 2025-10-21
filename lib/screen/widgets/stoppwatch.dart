import 'package:flutter/material.dart';

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  State<StopwatchWidget> createState() => StopwatchWidgetState();
}

class StopwatchWidgetState extends State<StopwatchWidget> {
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration _) {
    if (isRunning && mounted) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    }
  }

  void _start() {
    if (!isRunning) {
      setState(() {
        isRunning = true;
        _stopwatch.start();
        _ticker.start();
      });
    }
  }

  void _stop() {
    setState(() {
      isRunning = false;
      _stopwatch.stop();
    });
  }

  void _reset() {
    if (!isRunning) {
      setState(() {
        _stopwatch.reset();
        _elapsed = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsed.inSeconds.remainder(60));
    final millis = (_elapsed.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$minutes:$seconds.$millis', style: const TextStyle(fontSize: 64, fontFamily: 'Courier')),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRunning ? null : _start,
              child: const Text('Start'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: isRunning ? _stop : null,
              child: const Text('Stop'),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRunning ? null : _reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

class Ticker {
  final void Function(Duration) onTick;
  bool _active = false;
  late final Stopwatch _stopwatch;
  Future<void>? _tickerFuture;

  Ticker(this.onTick) {
    _stopwatch = Stopwatch();
  }

  void start() {
    if (_active) return;
    _active = true;
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
      await Future.delayed(const Duration(milliseconds: 50));
      onTick(_stopwatch.elapsed);
    }
  }
}
