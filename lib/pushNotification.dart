import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request iOS permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token
      String? token = await _fcm.getToken();
      print('User granted permission, FCM Token: $token');
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message: ${message.notification?.title} - ${message.notification?.body}');
    });
  }
}
