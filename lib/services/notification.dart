import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timer/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

Future<void> scheduleAlarmNotification(BuildContext context, TimeOfDay alarmTime, String title, String descrption) async {
  await requestExactAlarmPermission();
  final now = DateTime.now();
  var alarmDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    alarmTime.hour,
    alarmTime.minute,
  ).add(const Duration(seconds: 1));
  if (alarmDateTime.isBefore(now)) {
    alarmDateTime = alarmDateTime.add(const Duration(days: 1));
  }
  // Verwende die globale NotificationService-Instanz
  final plugin = NotificationService.instance.plugin;
  await plugin.zonedSchedule(
      0,
      title,
      descrption,
      tz.TZDateTime.from(alarmDateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}