import 'dart:developer' as dev;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    dev.log(
      'NotificationService: Initializing Firebase Messaging',
      name: 'fcm',
    );

    try {
      // Request user permission for notifications
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      dev.log(
        'NotificationService: User notification permission status: ${settings.authorizationStatus}',
        name: 'fcm',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        dev.log('NotificationService: Notifications authorized', name: 'fcm');

        // Get APNs token for iOS
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          dev.log('NotificationService: APNs token obtained', name: 'fcm');
        }

        // Get FCM token
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          dev.log(
            'NotificationService: FCM token obtained: $fcmToken',
            name: 'fcm',
          );
          // TODO: Send this token to your backend for targeted notifications
        }

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          dev.log(
            'NotificationService: Foreground message received - Title: ${message.notification?.title}',
            name: 'fcm',
          );
          _handleForegroundMessage(message);
        });

        // Handle background message for iOS
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          dev.log(
            'NotificationService: Message opened from background - Title: ${message.notification?.title}',
            name: 'fcm',
          );
          _handleMessageOpenedApp(message);
        });

        // Set background message handler
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        // Check for initial message (when app is launched from notification)
        RemoteMessage? initialMessage = await _firebaseMessaging
            .getInitialMessage();
        if (initialMessage != null) {
          dev.log('NotificationService: Initial message received', name: 'fcm');
          _handleMessageOpenedApp(initialMessage);
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        dev.log(
          'NotificationService: Notifications provisionally authorized',
          name: 'fcm',
        );
      } else {
        dev.log(
          'NotificationService: Notifications permission denied',
          name: 'fcm',
        );
      }
    } catch (e) {
      dev.log(
        'NotificationService: Error initializing FCM: $e',
        name: 'fcm',
        error: e,
      );
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    dev.log(
      'NotificationService: Handling foreground message - ${message.messageId}',
      name: 'fcm',
    );

    // Show snackbar or toast notification
    if (message.notification != null) {
      final notification = message.notification!;
      _showNotificationDialog(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    dev.log(
      'NotificationService: Handling message opened - ${message.messageId}',
      name: 'fcm',
    );

    // Handle navigation based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      _routeToScreen(data['type'], data);
    }
  }

  void _showNotificationDialog({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    // This will be called when a notification arrives while the app is in foreground
    // The actual UI update will be handled by the app's main context
    dev.log(
      'NotificationService: Would show notification - Title: $title, Body: $body',
      name: 'fcm',
    );
  }

  void _routeToScreen(String type, Map<String, dynamic> data) {
    // Handle navigation based on notification type
    // This can be extended to handle different notification types
    dev.log('NotificationService: Routing to screen type: $type', name: 'fcm');
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      dev.log('NotificationService: Subscribed to topic: $topic', name: 'fcm');
    } catch (e) {
      dev.log(
        'NotificationService: Error subscribing to topic: $e',
        name: 'fcm',
        error: e,
      );
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      dev.log(
        'NotificationService: Unsubscribed from topic: $topic',
        name: 'fcm',
      );
    } catch (e) {
      dev.log(
        'NotificationService: Error unsubscribing from topic: $e',
        name: 'fcm',
        error: e,
      );
    }
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      dev.log('NotificationService: Retrieved FCM token', name: 'fcm');
      return token;
    } catch (e) {
      dev.log(
        'NotificationService: Error retrieving FCM token: $e',
        name: 'fcm',
        error: e,
      );
      return null;
    }
  }
}

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log(
    'NotificationService: Background message handler called - ${message.messageId}',
    name: 'fcm',
  );

  // Handle the background message
  if (message.notification != null) {
    final notification = message.notification!;
    dev.log(
      'NotificationService: Background notification - Title: ${notification.title}',
      name: 'fcm',
    );
  }
}
