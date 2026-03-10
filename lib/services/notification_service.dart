import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_service.dart';

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

    try {
      // 1. Request Permissions
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
    });
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

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data.toString(),
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
