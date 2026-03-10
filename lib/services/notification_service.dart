import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_service.dart';
import 'settings_service.dart';
import '../routes/app_routes.dart';
import '../model/task_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> initialize() async {
    dev.log('NotificationService: Initializing', name: 'fcm');

    // Initialize Timezones
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));

    try {
      // 1. Request Permissions
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true);

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        dev.log('NotificationService: Permissions granted', name: 'fcm');

        // 2. Initialize Local Notifications for Foreground
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings();
        const InitializationSettings initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (details) {
            dev.log(
              'NotificationService: Local notification tapped',
              name: 'fcm',
            );
            if (details.payload != null) {
              _handleNotificationPayload(details.payload!);
            }
          },
        );

        // 3. Setup FCM Listeners
        _setupFCMListeners();

        // 4. Setup Auth Listener to save token on login
        _setupAuthListener();

        // 5. Get and Save Token if already logged in
        await _updateToken();

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _updateToken(token: newToken);
        });
      }
    } catch (e) {
      dev.log('NotificationService: Init error: $e', name: 'fcm', error: e);
    }
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        dev.log(
          'NotificationService: Auth changed (Login), updating token',
          name: 'fcm',
        );
        _updateToken();
      }
    });
  }

  void _setupFCMListeners() {
    // Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log(
        'NotificationService: Foreground msg: ${message.notification?.title}',
        name: 'fcm',
      );
      _showLocalNotification(message);
    });

    // Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log(
        'NotificationService: Notification click: ${message.data}',
        name: 'fcm',
      );
      _handleNotificationPayload(jsonEncode(message.data));
    });
  }

  void _handleNotificationPayload(String payload) {
    // Basic navigation logic - can be expanded based on data
    dev.log('NotificationService: Handling payload: $payload', name: 'fcm');
    AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  }

  Future<void> _updateToken({String? token}) async {
    try {
      final finalToken = token ?? await _firebaseMessaging.getToken();
      final user = FirebaseAuth.instance.currentUser;

      if (finalToken != null && user != null) {
        dev.log('NotificationService: Saving token: $finalToken', name: 'fcm');
        await _ref
            .read(databaseServiceProvider)
            .saveFCMToken(user.uid, finalToken);
      }
    } catch (e) {
      dev.log('NotificationService: Token update error: $e', name: 'fcm');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final settings = _ref.read(settingsServiceProvider);
    if (!settings.pushNotificationsEnabled) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: settings.vibrationEnabled,
          playSound: settings.soundEnabled,
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: settings.soundEnabled,
      ),
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> scheduleTaskNotification(TaskModel task) async {
    final settings = _ref.read(settingsServiceProvider);
    if (!settings.taskRemindersEnabled) return;

    final scheduleDate = DateTime.fromMillisecondsSinceEpoch(task.scheduleTime);
    if (scheduleDate.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled tasks',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: settings.vibrationEnabled,
      playSound: settings.soundEnabled,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    await _localNotifications.zonedSchedule(
      task.id.hashCode,
      'Task Reminder: ${task.title}',
      task.description,
      tz.TZDateTime.from(scheduleDate, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'id': task.id, 'type': 'task_reminder'}),
    );

    dev.log(
      'NotificationService: Scheduled notification for task ${task.id} at $scheduleDate',
      name: 'fcm',
    );
  }

  Future<void> cancelTaskNotification(String taskId) async {
    await _localNotifications.cancel(taskId.hashCode);
    dev.log(
      'NotificationService: Cancelled notification for task $taskId',
      name: 'fcm',
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log(
    'NotificationService: Background msg: ${message.messageId}',
    name: 'fcm',
  );
}
