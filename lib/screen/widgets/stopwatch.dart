import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:timer/widgets/fancy_button.dart';
import 'package:timer/widgets/fancy_glasscard.dart';
//import 'package:timer/screen/widgets/ticker.dart';

/// Stopwatch Widget - Simple Stopwatch with Start, Stop, and Reset
/// Provides a basic stopwatch functionality with:
/// - Start, Stop, and Reset controls
/// - Elapsed time display in minutes, seconds, and milliseconds
class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

/// State class for StopwatchWidget
/// Manages the stopwatch logic, UI updates, and user interactions.
class _StopwatchWidgetState extends State<StopwatchWidget> {
  // Liste der Zwischenzeiten
  final List<Duration> _splits = [];
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  bool isRunning = false;
  final ScrollController _splitScrollController = ScrollController();

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

  /// Starts the stopwatch and updates the UI accordingly.
  /// This method is called when the user presses the start button.
  /// It initializes the ticker and begins tracking elapsed time.
  /// If the stopwatch is already running, it does nothing.
  void _start() {
    if (!isRunning) {
      setState(() {
        isRunning = true;
        _stopwatch.start();
        if (!_ticker.isActive) {
          _ticker.start();
        }
      });
    }
  }

  /// Stops the stopwatch and updates the UI accordingly.
  /// This method is called when the user presses the stop button.
  /// It halts the ticker and stops tracking elapsed time.
  /// If the stopwatch is already stopped, it does nothing.
  void _stop() {
    setState(() {
      isRunning = false;
      _stopwatch.stop();
    });
  }

  /// Resets the stopwatch to zero and updates the UI accordingly.
  /// This method is called when the user presses the reset button.
  /// It clears the elapsed time and prepares the stopwatch for a new start.
  /// The reset can only be performed when the stopwatch is not running.
  void _reset() {
    if (!isRunning) {
      setState(() {
        _stopwatch.reset();
        _elapsed = Duration.zero;
        _splits.clear();
      });
    }
  }

  /// Disposes of the stopwatch and releases any resources.
  /// This method is called when the widget is removed from the widget tree.
  /// It ensures that the ticker is properly disposed of and the stopwatch is stopped.
  /// This helps to prevent memory leaks and other issues.
  /// Overrides the dispose method of the State class.
  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  
  /// Builds the UI for the StopwatchWidget.
  /// Displays the elapsed time and control buttons.
  /// The UI consists of a GlassCard containing:
  /// - A text display of the elapsed time in minutes, seconds, and milliseconds.
  /// - Start, Stop, and Reset buttons for controlling the stopwatch.
  /// The buttons are enabled or disabled based on the current state of the stopwatch.
  ///   - Start button: enabled when the stopwatch is stopped.
  ///   - Stop button: enabled when the stopwatch is running.
  ///   - Reset button: enabled when the stopwatch is stopped and has elapsed time.
  ///     - If the stopwatch is running, the reset button is disabled.
  ///   - Split button: enabled when the stopwatch is running.
  ///     - If the stopwatch is stopped, the split button is disabled.
  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    final hours = twoDigits(_elapsed.inHours);
    final minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsed.inSeconds.remainder(60));
    final millis = threeDigits(_elapsed.inMilliseconds % 1000);

    return FancyGlassCard(
      padding: const EdgeInsets.all(32.0),
      margin: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_splits.isNotEmpty) ...[
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    controller: _splitScrollController,
                    itemCount: _splits.length,
                    itemBuilder: (context, idx) {
                      final d = _splits[idx];
                      final hrs = twoDigits(d.inHours);
                      final min = twoDigits(d.inMinutes.remainder( 60));
                      final sec = twoDigits(d.inSeconds.remainder(60));
                      final ms = threeDigits(d.inMilliseconds % 1000);
                      Duration diff = idx == 0 ? d : d - _splits[idx - 1];
                      final diffHrs = twoDigits(diff.inHours);
                      final diffMin = twoDigits(diff.inMinutes.remainder(60));
                      final diffSec = twoDigits(diff.inSeconds.remainder(60));
                      final diffMs = threeDigits(diff.inMilliseconds % 1000);
                      return Text(
                        '${idx + 1}: $hrs:$min:$sec.$ms (+$diffHrs:$diffMin:$diffSec.$diffMs)',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: Platform.isIOS ? 'Courier' : 'RobotoMono',
                          letterSpacing: Platform.isIOS ? -1.0 : 0.0,
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 180),
              ],
              SizedBox(height: 16),
              Center(
                child: FancyGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Text(
                    '$hours:$minutes:$seconds.$millis',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: Platform.isIOS ? 'Courier' : 'RobotoMono',
                      letterSpacing: Platform.isIOS ? -5.0 : 0.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              IntrinsicWidth(
                stepWidth: 60,
                stepHeight: 60,
                child: FancyButton(
                  enabled: true,
                  backgroundColor: isRunning ? FancyButtonColor.red : FancyButtonColor.green,
                  leadingIcon: isRunning ? Icons.stop : Icons.play_arrow,
                  paddingHorizontal: 12,
                  iconTextSpacing: 0,
                  onPressed: isRunning ? _stop : _start,
                  label: ''
                ),
              ),
            ],
          ),

          /// Reset und Split Buttons
          if (!isRunning && _elapsed != Duration.zero)
            Positioned(
              bottom: 0,
              right: 0,
              child: IntrinsicWidth(
                stepHeight: 48,
                stepWidth: 48,
                child: FancyButton(
                  enabled: true,
                  onPressed: _reset,
                  leadingIcon: Icons.restore,
                  label: '',
                  paddingHorizontal: 0,
                  backgroundColor: FancyButtonColor.red,
                  iconTextSpacing: 0,
                ),
              ),
            ),
          if (isRunning)
            Positioned(
              bottom: 0,
              left: 0,
              child: IntrinsicWidth(
                stepHeight: 48,
                stepWidth: 48,
                child: FancyButton(
                  leadingIcon: Icons.timer,
                  paddingHorizontal: 0,
                  iconTextSpacing: 0,
                  label: '',
                  onPressed: () {
                    setState(() {
                      _splits.add(_elapsed);
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_splitScrollController.hasClients) {
                        _splitScrollController.animateTo(
                          _splitScrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  },
                  enabled: true,
                  backgroundColor: FancyButtonColor.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
