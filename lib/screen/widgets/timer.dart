
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:timer/widgets/fancy_snackbar.dart';
import 'package:timer/widgets/fancy_button.dart';
import 'package:timer/widgets/fancy_glasscard.dart';
import 'package:timer/widgets/fancy_picker.dart';


/// Timer Widget - Countdown Timer with Picker and Alerts
/// Provides a countdown timer with:
/// - Time selection via Cupertino pickers for minutes and seconds
/// - Start and stop controls with 3D-styled buttons
/// - Visual countdown display with color changes based on remaining time
/// - Alert sound and snackbar notification when the timer ends
class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key,
    this.initialTime = const Duration(hours: 0, minutes: 5, seconds: 0),
  });
  final Duration initialTime;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

/// State class for TimerWidget
/// Manages the timer logic, UI updates, and user interactions.
class _TimerWidgetState extends State<TimerWidget> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
 
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  //AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late Duration _remaining;
  bool isRunning = false;
  late final Ticker _ticker;
  late int _hours;
  late int _minutes;
  late int _seconds;
  bool showPicker = true;
  Duration _startTime = Duration.zero;

  /// Initializes the timer and sets up the controllers.
  /// This method is called when the widget is created.
  /// It sets the initial values for the hour, minute, and second controllers.
  /// It also initializes the blink animation.
  @override
  void initState() {
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.initialTime;
    _ticker = Ticker(_onTick);
    _hours = widget.initialTime.inHours;
    _minutes = widget.initialTime.inMinutes;
    _seconds = widget.initialTime.inSeconds % 60;
    _startTime = Duration(
      hours: _hours,
      minutes: _minutes,
      seconds: _seconds,
    ); // Startwert setzen
    _hourController = FixedExtentScrollController(initialItem: _hours);
    _minuteController = FixedExtentScrollController(initialItem: _minutes);
    _secondController = FixedExtentScrollController(initialItem: _seconds);
  }

/// Disposes the controllers and ticker.
  /// This method is called when the widget is removed from the widget tree.
  /// It ensures that all resources are released properly.
  ///   - Disposes the minute and second controllers.
  ///   - Disposes the ticker.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blinkController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _ticker.dispose();
    super.dispose();
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
          _startTime = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
          _remaining = _startTime;
        });
      }
    }
  }

  
  /// Callback for ticker ticks
  /// Updates the remaining time based on the elapsed time.
  Future<void> _onTick(Duration elapsed) async {
    if (isRunning && _remaining.inSeconds > 0) {
      if (mounted) {
        final newRemaining = _startTime - elapsed;
        if (newRemaining.inSeconds > 0) {
          // Sekunden-Ping bei < 10 Sekunden
          setState(() {
            _remaining = newRemaining;
          });
        } else {
          _remaining = Duration.zero;
          isRunning = false;
          _ticker.stop();
          // TODO alert notification

          setState(() {
            showPicker = true;
            _hours = 0;
            _minutes = 0;
            _seconds = 0;
            // ...other state updates
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _hourController.jumpToItem(0);
            _minuteController.jumpToItem(0);
            _secondController.jumpToItem(0);
          });

          final totalHours = _startTime.inHours.remainder(24).toString().padLeft(2, '0');
          final totalMinutes = _startTime.inMinutes.remainder(60).toString().padLeft(2, '0');
          final totalSeconds = _startTime.inSeconds.remainder(60).toString().padLeft(2, '0');
          ScaffoldMessenger.of(context).showSnackBar(
            FancySnackbar.build(
              'Timer beendet! Gesamtzeit: $totalHours:$totalMinutes:$totalSeconds',
              type: FancySnackbarType.info,
            ),
          );
        }
      }
    }
  }

  /// Starts the timer and updates the UI accordingly.
  /// This method is called when the user presses the start button.
  /// It initializes the ticker and starts the countdown.
  void _startTimer() async {
    if (!isRunning) {
      setState(() {
        showPicker = false;
        isRunning = true;
        Future.delayed(Duration(milliseconds: 500), _ticker.start);
        debugPrint('(Re-)start timer)');
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
      final hrs = _remaining.inHours;
      final min = _remaining.inMinutes;
      final sec = _remaining.inSeconds % 60;
      WidgetsBinding.instance.addPostFrameCallback((_) {

        _hourController.jumpToItem(hrs);
        _minuteController.jumpToItem(min);
        _secondController.jumpToItem(sec);
      });
    }
  }

  

/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }
  */

  /// Builds the UI for the TimerWidget.
  /// Displays the countdown timer, pickers, and control buttons.
  /// The UI consists of a GlassCard containing:
  /// - A text display of the remaining time in minutes and seconds.
  /// - Cupertino pickers for selecting minutes and seconds when the timer is not running.
  /// - Start and Stop buttons for controlling the timer.
  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_remaining.inHours.remainder(24));
    final minutes = twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = twoDigits(_remaining.inSeconds.remainder(60));
    Color timerColor;
    bool shouldBlink = _remaining.inSeconds < 10;
    if (shouldBlink) {
      timerColor = Colors.red;
      if (!_blinkController.isAnimating) {
        _blinkController.repeat(reverse: true);
      }
    } else if (_remaining.inSeconds < 30) {
      timerColor = Colors.orange;
      if (_blinkController.isAnimating) {
        _blinkController.stop();
        _blinkController.value = 1.0;
      }
    } else {
      timerColor = Colors.black;
      if (_blinkController.isAnimating) {
        _blinkController.stop();
        _blinkController.value = 1.0;
      }
    }
    final isStartEnabled = (_hours > 0 || _minutes > 0 || _seconds > 0) && !isRunning;
    return FancyGlassCard(
      padding: const EdgeInsets.all(32.0),
      margin: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 190,
                child: Center(
                  child: !showPicker
                      ? FancyGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: shouldBlink
                              ? FadeTransition(
                                  opacity: _blinkAnimation,
                                  child: Text(
                                    '$hours:$minutes:$seconds',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontFamily: Theme.of(context).platform == TargetPlatform.iOS ? 'Courier' : 'RobotoMono',
                                      color: timerColor,
                                      letterSpacing: Theme.of(context).platform == TargetPlatform.iOS ? -5.0 : null,
                                    ),
                                  ),
                                )
                              : Text(
                                  '$hours:$minutes:$seconds',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontFamily: Theme.of(context).platform == TargetPlatform.iOS ? 'Courier' : 'RobotoMono',
                                    color: timerColor,
                                    letterSpacing: Theme.of(context).platform == TargetPlatform.iOS ? -5.0 : null,
                                  ),
                                ),
                        )
                      : FancyGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(3, (i) {
                              final labels = ['Std', 'Min', 'Sek'];
                              final counts = [24, 60, 60];
                              final controllers = [_hourController, _minuteController, _secondController];
                              final onChanged = [
                                (int v) => setState(() { _hours = v; _updateTimeFromFields(); }),
                                (int v) => setState(() { _minutes = v; _updateTimeFromFields(); }),
                                (int v) => setState(() { _seconds = v; _updateTimeFromFields(); }),
                              ];
                              return Row(
                                children: [
                                  FancyPicker(
                                    label: labels[i],
                                    itemCount: counts[i],
                                    controller: controllers[i],
                                    onChanged: onChanged[i],
                                  ),
                                // if (i < 3) const SizedBox(width: 4),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IntrinsicWidth(
                    stepHeight: 60,
                    stepWidth: 60,
                    child: FancyButton(
                      backgroundColor: isRunning ? FancyButtonColor.red : FancyButtonColor.green,
                      leadingIcon: isRunning ? Icons.stop : Icons.play_arrow,
                      enabled: isRunning ? true : isStartEnabled,
                      onPressed: isRunning ? _stopTimer : (isStartEnabled ? _startTimer : null),
                      paddingHorizontal: 12,
                      iconTextSpacing: 0,
                      label: '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isRunning)...[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: List.generate(4, (i) {
                  final labels = ['+1m', '+10m', '+1h', '+12h'];
                  final increments = [60, 600, 3600, 43200];
                  final durations = [
                    const Duration(minutes: 1),
                    const Duration(minutes: 10),
                    const Duration(minutes: 60),
                    const Duration(hours: 12),
                  ];
                  final canAdd = (_remaining.inSeconds + increments[i] < 86400); // 86400 seconds in a day
                  return Row(
                    children: [
                      FancyButton(
                        label: labels[i],
                        onPressed: canAdd
                            ? () {
                                setState(() {
                                  _startTime += durations[i];
                                  _remaining += durations[i];
                                });
                              }
                            : null,
                        paddingHorizontal: 12,
                        enabled: canAdd,
                        backgroundColor: FancyButtonColor.grey,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ]
          else...[ // Buttons für 1m, 10m, 60m, 12h setzen
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: List.generate(4, (i) {
                  final labels = ['1m', '10m', '1h', '12h'];
                  final durations = [
                    const Duration(minutes: 1),
                    const Duration(minutes: 10),
                    const Duration(hours: 1),
                    const Duration(hours: 12),
                  ];
                  final d = durations[i];
                  return Row(
                    children: [
                      FancyButton(
                        label: labels[i],
                        onPressed: () {
                          setState(() {
                            _hours = d.inHours;
                            _minutes = d.inMinutes % 60;
                            _seconds = d.inSeconds % 60;
                            _updateTimeFromFields();
                            _hourController.jumpToItem(_hours);
                            _minuteController.jumpToItem(_minutes);
                            _secondController.jumpToItem(_seconds);
                          });
                        },
                        paddingHorizontal: 12,
                        backgroundColor: FancyButtonColor.grey,
                      ),
                      if (i < 3) const SizedBox(width: 8),
                    ],
                  );
                }),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
