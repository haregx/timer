import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:timer/screen/widgets/fancy_snackbar.dart';
import 'package:timer/screen/widgets/button3d.dart';
import 'package:timer/screen/widgets/glass_card.dart';
//import 'package:timer/screen/widgets/ticker.dart';

/// Timer Widget - Countdown Timer with Picker and Alerts
/// Provides a countdown timer with:
/// - Time selection via Cupertino pickers for minutes and seconds
/// - Start and stop controls with 3D-styled buttons
/// - Visual countdown display with color changes based on remaining time
/// - Alert sound and snackbar notification when the timer ends
class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key, 
    this.initialTime = const Duration(minutes: 5, seconds: 0),
  });
  final Duration initialTime;

  @override
  State<TimerWidget> createState() => TimerWidgetState();
}

/// State class for TimerWidget
/// Manages the timer logic, UI updates, and user interactions.
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

  /// Updates the start time and remaining time based on the selected minutes and seconds.
  /// This method is called when the user changes the picker values.
  /// It ensures that the timer reflects the user's input.
  /// If the timer is not running, it updates the start time and remaining time.
  /// This method is called when the user changes the picker values.
  /// It ensures that the timer reflects the user's input.
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


  /// Callback for ticker ticks
  /// Updates the remaining time based on the elapsed time.
  void _onTick(Duration elapsed,) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              FancySnackbar.build(
                'Timer beendet!',
                type: FancySnackbarType.info,
              ),
            );
          }
        });
      }
    }
  }

  /// Starts the timer and updates the UI accordingly.
  /// This method is called when the user presses the start button.
  /// It initializes the ticker and starts the countdown.
  void _startTimer() {
    if (!isRunning) {
      setState(() {
        showPicker = false; // Nach Start wieder Anzeige
        isRunning = true;
        Future.delayed(Duration(milliseconds: 500), _ticker.start);
      });
    }
  }

  /// Stops the timer and updates the UI accordingly.
  /// This method is called when the user presses the stop button.
  /// It halts the ticker and stops the countdown. 
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

  /// Disposes the controllers and ticker.
  /// This method is called when the widget is removed from the widget tree.
  /// It ensures that all resources are released properly.
  ///   - Disposes the minute and second controllers.
  ///   - Disposes the ticker.
  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  /// Builds the UI for the TimerWidget.
  /// Displays the countdown timer, pickers, and control buttons.
  /// The UI consists of a GlassCard containing:
  /// - A text display of the remaining time in minutes and seconds.
  /// - Cupertino pickers for selecting minutes and seconds when the timer is not running.
  /// - Start and Stop buttons for controlling the timer. 
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
    return GlassCard(
       padding: const EdgeInsets.all(32.0),
      margin: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250, // Feste Höhe für Anzeige und Picker
            child: Center(
              child: !showPicker
                  ? Text('$minutes:$seconds', style: TextStyle(fontSize: 64, fontFamily: 'Courier', color: timerColor, letterSpacing: -5.0))
                  : GlassCard(
                    margin: const EdgeInsets.all(32.0),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text('Min'),
                              SizedBox(
                                height: 128,
                                width: 80,
                                child: CupertinoPicker(
                                  looping: true,
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
                                  looping: true,
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
          ),
          const SizedBox(height: 32),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // start button
              IntrinsicWidth(
                stepWidth: 200,
                stepHeight: 60,
                child: Button3D(
                  enabled: true, // (!isRunning && (_minutes > 0 || _seconds > 0)),
                  onPressed: isRunning ? _stopTimer : _startTimer,
                  label: isRunning ? 'Stopp' : 'Start',
                ),
              ),
/*              const SizedBox(height: 36),
              // stop button
              IntrinsicWidth(
                child: Button3D(
                  enabled: isRunning,
                  onPressed: _stopTimer,
                  label: 'Stopp',
                ),
              ),
              */
            ],
          ),
        ],
      ),
    );
  }
}

