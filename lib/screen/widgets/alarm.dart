import 'package:timer/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:timer/widgets/button3d.dart';
import 'package:timer/widgets/fancy_snackbar.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'dart:async';

import 'package:timer/widgets/glass_card.dart';

import 'package:flutter/cupertino.dart';

/// AlarmWidget - Allows user to set an alarm time
/// Provides functionality to:
/// - Pick an alarm time using a Cupertino-style time picker
/// - Set and display the alarm time
/// - Trigger an alarm notification and sound when the set time is reached
class AlarmWidget extends StatefulWidget {
  const AlarmWidget({super.key});

  @override
  State<AlarmWidget> createState() => _AlarmWidgetState();
}

/// State class for AlarmWidget
/// Manages the alarm time selection, setting, and triggering logic.  
/// Uses a periodic timer to check if the current time matches the set alarm time,
/// and triggers a notification and sound when the alarm goes off.
class _AlarmWidgetState extends State<AlarmWidget> {
  void _resetAlarm() {
    setState(() {
      _alarmSet = false;
      _alarmTriggered = false;
      _selectedTime = TimeOfDay.now();
    });
  }
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _alarmSet = false;
  Timer? _timer;
  bool _alarmTriggered = false;


  ///  Initializes the periodic timer to check for alarm triggering.  
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _checkAlarm);
  }

  /// Disposes the timer.
  /// This method is called when the widget is removed from the widget tree.
  /// It ensures that all resources are released properly.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  /// Checks if the current time matches the set alarm time.
  /// If the alarm is set and not yet triggered, it compares the current time
  /// with the selected alarm time. If they match, it triggers the alarm sound
  /// and displays a notification snackbar.
  void _checkAlarm(Timer timer) {
    if (!_alarmSet || _alarmTriggered) return;
    final now = TimeOfDay.now();
    if (now.hour == _selectedTime.hour && now.minute == _selectedTime.minute) {
      setState(() {
        _alarmTriggered = true;
      });
      FlutterRingtonePlayer().playAlarm();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final contextToUse = context;
        ScaffoldMessenger.of(contextToUse).showSnackBar(
          FancySnackbar.build(
            'Alarm: ${_selectedTime.format(contextToUse)}',
            type: FancySnackbarType.info,
          ),
        );
      });
    }
  }

  /// Opens a Cupertino-style time picker to select the alarm time.
  /// Updates the selected time and sets the alarm when the user confirms their choice.
  void _pickTime() async {
    Duration initialDuration = Duration(hours: _selectedTime.hour, minutes: _selectedTime.minute);
    Duration pickedDuration = initialDuration;
    bool okPressed = false;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onVerticalDragStart: (_) {
            okPressed = false;
            Navigator.of(context).pop();
          },
          child: Container(
            height: 330,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: initialDuration,
                    minuteInterval: 1,
                    onTimerDurationChanged: (Duration newDuration) {
                      pickedDuration = newDuration;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      child: const Text('Abbrechen'),
                      onPressed: () {
                        okPressed = false;
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('OK'),
                      onPressed: () {
                        okPressed = true;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
    // Always update if OK was pressed
    if (okPressed) {
      final picked = TimeOfDay(hour: pickedDuration.inHours % 24, minute: pickedDuration.inMinutes % 60);
      setState(() {
        _selectedTime = picked;
        _alarmSet = true;
        _alarmTriggered = false;
      });
      if (mounted) {
        await scheduleAlarmNotification(context, picked, 'Alarm', 'Dieser Alarm wurde für ${picked.format(context)} eingestellt.');
      }
    }
  }

  

  /// Builds the UI for the AlarmWidget.
  /// Displays the current alarm status and a button to set the alarm time.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32.0),
        margin: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    _alarmSet
                        ? 'Alarm gesetzt für: ${_selectedTime.format(context)}'
                        : 'Kein Alarm gesetzt',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                if (_alarmTriggered)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: Text('Alarm ausgelöst!', style: TextStyle(fontSize: 18, color: Colors.red))),
                  ),
                const SizedBox(height: 32),
                IntrinsicWidth(
                  stepHeight: 60,
                  child: Button3D(
                    onPressed: _pickTime,
                    label: _alarmSet ? 'Alarm ändern' : 'Alarmzeit einstellen',
                    enabled: true,
                  ),
                ),
              ],
            ),
            if (_alarmSet)
              Positioned(
                bottom: 0,
                right: 0,
                child: IntrinsicWidth(
                  stepHeight: 48,
                  stepWidth: 48,
                  child: Button3D(
                    enabled: true,
                    onPressed: _resetAlarm,
                    leadingIcon: Icons.restore,
                    label: '',
                    paddingHorizontal: 0,
                    isAlert: true,
                    iconTextSpacing: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
