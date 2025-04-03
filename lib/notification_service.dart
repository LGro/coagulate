// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  factory NotificationService() => _notificationService;
  NotificationService._internal();
  static final NotificationService _notificationService =
      NotificationService._internal();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    // TODO: Add indicator to check and re-activate if denied to settings page
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });

    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('app_icon'),
            iOS: DarwinInitializationSettings(
                requestAlertPermission: true,
                requestBadgePermission: true,
                requestSoundPermission: true)));
    _isInitialized = true;
  }

  Future<void> showNotification(int id, String title, String body,
      {String? payload}) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'coagulate_channel_id',
      'Coagulate Notifications',
      channelDescription: 'News from Coagulate contacts.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      ticker: 'ticker',
    );

    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());

    await flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }
}
