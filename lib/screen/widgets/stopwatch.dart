import 'package:flutter/material.dart';
import 'package:timer/screen/widgets/button3d.dart';
import 'package:timer/screen/widgets/glass_card.dart';
import 'package:timer/screen/widgets/ticker.dart';

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
    final millis = (_elapsed.inMilliseconds % 1000).toString().padLeft(3, '0');
    return GlassCard(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$minutes:$seconds.$millis', style: const TextStyle(fontSize: 64, fontFamily: 'Courier', letterSpacing: -3.0)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Button3D(
                enabled: !isRunning,
                onPressed: _start,
                label: _elapsed == Duration.zero ? 'Start' : 'Fortsetzen',
              ),
              const SizedBox(width: 16),
              Button3D(
                enabled: isRunning,
                onPressed: _stop,
                label: 'Stop',
              ),
            ],
          ),
          const SizedBox(height: 48),
          IntrinsicWidth(
            child: Button3D(
              enabled: !isRunning && _elapsed != Duration.zero,
              onPressed: _reset,
              label: 'Reset',
            ),
          ),
        ],
      ),
    );
  }
}
