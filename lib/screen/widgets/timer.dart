import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class TimerWidget extends StatefulWidget {
  
  const TimerWidget({
    super.key, 
    this.initialTime = const Duration(minutes: 5, seconds: 0),
  });
  final Duration initialTime;

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late Duration _remaining;
  bool isRunning = false;
  late final Ticker _ticker;
  late int _minutes;
  late int _seconds;
  bool showPicker = true;
    Duration _startTime = Duration.zero;
  

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialTime;
    _ticker = Ticker(_onTick);
    _minutes = widget.initialTime.inMinutes;
    _seconds = widget.initialTime.inSeconds % 60;
    _startTime = Duration(minutes: _minutes, seconds: _seconds); // Startwert setzen
    _minuteController = FixedExtentScrollController(initialItem: _minutes);
    _secondController = FixedExtentScrollController(initialItem: _seconds);
  }

  void _updateTimeFromFields() {
    if (!isRunning) {
      if (mounted) {
        setState(() {
          _startTime = Duration(minutes: _minutes, seconds: _seconds);
          _remaining = _startTime;
        });
      }
    }
  }



  void _onTick(Duration elapsed) {
    if (isRunning && _remaining.inSeconds > 0) {
      if (mounted) {
        setState(() {
          _remaining = _startTime - elapsed;
          if (_remaining.inSeconds <= 0) {
            _remaining = Duration.zero;
            isRunning = false;
            _ticker.stop();
            // System-Sound abspielen
            FlutterRingtonePlayer().playAlarm();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _minuteController.jumpToItem(0);
              _secondController.jumpToItem(0);
            });
            showPicker = true; // Nach Ende wieder Anzeige
            _minutes = 0;
            _seconds = 0;
          }
        });
      }
    }
  }

  void _startTimer() {
    if (!isRunning) {
      setState(() {
        showPicker = false; // Nach Start wieder Anzeige
        isRunning = true;
        Future.delayed(Duration(milliseconds: 500), _ticker.start);
      });
    }
  }

  void _stopTimer() {
    if (isRunning) {
      setState(() {
        isRunning = false;
        _ticker.stop();
        showPicker = true; // Nach Stop wieder Anzeige
      });
      final min = _remaining.inMinutes;
      final sec = _remaining.inSeconds % 60;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _minuteController.jumpToItem(min);
        _secondController.jumpToItem(sec);
      });
    }
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = twoDigits(_remaining.inSeconds.remainder(60));
    Color timerColor;
    if (_remaining.inSeconds < 10) {
      timerColor = Colors.red;
    } else if (_remaining.inSeconds < 30) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.black;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 160, // Feste Höhe für Anzeige und Picker
          child: Center(
            child: !showPicker
                ? Text('$minutes:$seconds', style: TextStyle(fontSize: 64, fontFamily: 'Courier', color: timerColor))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text('Min'),
                          SizedBox(
                            height: 128,
                            width: 80,
                            child: CupertinoPicker(
                              itemExtent: 64,
                              scrollController: _minuteController,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  _minutes = value;
                                  _updateTimeFromFields();
                                });
                              },
                              children: List<Widget>.generate(60, (i) => Center(child: Text(i.toString(), style: const TextStyle(fontSize: 32, fontFamily: 'Courier')))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          const Text('Sek'),
                          SizedBox(
                            height: 128,
                            width: 80,
                            child: CupertinoPicker(
                              itemExtent: 64,
                              scrollController: _secondController,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  _seconds = value;
                                  _updateTimeFromFields();
                                });
                              },
                              children: List<Widget>.generate(60, (i) => Center(child: Text(i.toString(), style: const TextStyle(fontSize: 32, fontFamily: 'Courier')))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // start button
            ElevatedButton(
              onPressed: (!isRunning && (_minutes > 0 || _seconds > 0)) ? _startTimer : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: const Text('Start'),
              ),
            ),
            const SizedBox(height: 36),
            // stop button
            ElevatedButton(
              onPressed: isRunning  ? _stopTimer : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: const Text('Stopp'),
              ), 
            ),
          ],
        ),
      ],
    );
  }
}

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
