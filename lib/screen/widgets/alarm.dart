import 'package:timer/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:timer/widgets/button3d.dart';
import 'package:timer/widgets/fancy_snackbar.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'dart:async';

import 'package:timer/widgets/glass_card.dart';

import 'package:flutter/cupertino.dart';

/// AlarmWidget - Allows user to set an alarm time
class AlarmWidget extends StatefulWidget {
  const AlarmWidget({super.key});

  @override
  State<AlarmWidget> createState() => _AlarmWidgetState();
}

class _AlarmWidgetState extends State<AlarmWidget> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _alarmSet = false;
  Timer? _timer;
  bool _alarmTriggered = false;


  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _checkAlarm);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


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

  void _pickTime() async {
    Duration initialDuration = Duration(hours: _selectedTime.hour, minutes: _selectedTime.minute);
    Duration? pickedDuration;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
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
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    // Use pickedDuration if set, otherwise keep previous
    if (pickedDuration != null) {
      final picked = TimeOfDay(hour: pickedDuration!.inHours % 24, minute: pickedDuration!.inMinutes % 60);
      if (picked != _selectedTime) {
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
  }

  

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32.0),
        margin: const EdgeInsets.all(16.0),
        child: Column(
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
                label: 'Alarmzeit einstellen',
                enabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
