import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_service.dart';
import 'settings_service.dart';
import '../firebase_options.dart';
import '../routes/app_routes.dart';
import '../model/task_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

// ─── IMPORTANT: Must be a top-level function ────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized before using any Firebase service in background
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  dev.log(
    'NotificationService: Background msg: ${message.notification?.title}',
    name: 'fcm',
  );

  // Show a local notification for background messages so user sees them
  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(
    const InitializationSettings(android: androidSettings),
  );
  final notification = message.notification;
  if (notification != null) {
    await plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  // ─── Create Android notification channels ─────────────────────────────────
  static const _highImportanceChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important Firebase notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const _taskReminderChannel = AndroidNotificationChannel(
    'task_reminders',
    'Task Reminders',
    description: 'Notifications for scheduled tasks',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    dev.log('NotificationService: Initializing', name: 'fcm');

    // Initialize Timezones
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.toString()));

    try {
      // 1. Create notification channels (Android 8+)
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        await androidPlugin?.createNotificationChannel(_highImportanceChannel);
        await androidPlugin?.createNotificationChannel(_taskReminderChannel);

        // Request notification permission (Android 13+)
        await androidPlugin?.requestNotificationsPermission();

        // Request exact alarm permission (Android 12+ for scheduled notifications)
        await androidPlugin?.requestExactAlarmsPermission();
      }

      // 2. Request FCM permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      dev.log(
        'NotificationService: Permission status: ${settings.authorizationStatus}',
        name: 'fcm',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 3. Initialize Local Notifications
        const androidSettings = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        const iosSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        const initSettings = InitializationSettings(
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
          onDidReceiveBackgroundNotificationResponse:
              _onBackgroundNotificationResponse,
        );

        // 4. Force FCM to deliver foreground messages as heads-up notifications
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 5. Setup FCM Listeners
        _setupFCMListeners();

        // 6. Setup Auth Listener to save token on login
        _setupAuthListener();

        // 7. Get and save current token
        await _updateToken();

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          dev.log('NotificationService: Token refreshed', name: 'fcm');
          _updateToken(token: newToken);
        });

        // 8. Check if app was opened from a terminated state notification
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          dev.log(
            'NotificationService: App opened from terminated state via notification',
            name: 'fcm',
          );
          _handleNotificationPayload(jsonEncode(initialMessage.data));
        }
      } else {
        dev.log(
          'NotificationService: Permissions NOT granted: ${settings.authorizationStatus}',
          name: 'fcm',
        );
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
    // Foreground Messages — Firebase doesn't show heads-up by default, we do it manually
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log(
        'NotificationService: Foreground msg: ${message.notification?.title}',
        name: 'fcm',
      );
      _showLocalNotification(message);
    });

    // Background/Terminated → user tapped the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log(
        'NotificationService: Notification tapped from background: ${message.data}',
        name: 'fcm',
      );
      _handleNotificationPayload(jsonEncode(message.data));
    });
  }

  void _handleNotificationPayload(String payload) {
    dev.log('NotificationService: Handling payload: $payload', name: 'fcm');
    AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  }

  Future<void> _updateToken({String? token}) async {
    try {
      final finalToken = token ?? await _firebaseMessaging.getToken();
      final user = FirebaseAuth.instance.currentUser;

      if (finalToken != null && user != null) {
        dev.log(
          'NotificationService: Saving FCM token for ${user.uid}',
          name: 'fcm',
        );
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

    final appSettings = _ref.read(settingsServiceProvider);
    if (!appSettings.pushNotificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      _highImportanceChannel.id,
      _highImportanceChannel.name,
      channelDescription: _highImportanceChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: appSettings.vibrationEnabled,
      playSound: appSettings.soundEnabled,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: appSettings.soundEnabled,
        presentBadge: true,
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
    final appSettings = _ref.read(settingsServiceProvider);
    if (!appSettings.taskRemindersEnabled) return;

    final scheduleDate = DateTime.fromMillisecondsSinceEpoch(task.scheduleTime);
    if (scheduleDate.isBefore(DateTime.now())) {
      dev.log(
        'NotificationService: Schedule time is in the past, skipping',
        name: 'fcm',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _taskReminderChannel.id,
      _taskReminderChannel.name,
      channelDescription: _taskReminderChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: appSettings.vibrationEnabled,
      playSound: appSettings.soundEnabled,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await _localNotifications.zonedSchedule(
      task.id.hashCode,
      'Task Reminder: ${task.title}',
      task.description.isNotEmpty ? task.description : 'Your task is due soon!',
      tz.TZDateTime.from(scheduleDate, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'id': task.id, 'type': 'task_reminder'}),
    );

    dev.log(
      'NotificationService: Scheduled notification for task ${task.id} at $scheduleDate (${tz.local.name})',
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

// Top-level callback for background notification taps — must be top-level
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse details) {
  dev.log(
    'NotificationService: Background notification tapped: ${details.payload}',
    name: 'fcm',
  );
}
