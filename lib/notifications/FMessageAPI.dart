import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:petsitter/in_app_chat/chatListPage.dart';
import 'package:petsitter/main.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import '../in_app_chat/chatListPage.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.data}");
}

class FirebaseMessagingAPI {
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) {
      return;
    }

    print("Handling a message: ${message.data}");

    navigatorKey.currentState!.pushNamed(
      ChatsListPage.route,
    );
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      handleMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initNotifications(BuildContext context) async {
    NotificationSettings settings = await fMessaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission to receive notifications');
      fMessaging.getToken().then((token) {
        if (token != null) {
          print("Firebase Messaging Token: $token");
          // Save the token to the database to the current user
          UserDataService().pushTokenToFirestore(token);
        }
      });
      initPushNotifications();
    } else {
      print('User did not grant permission to receive notifications');
        showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Notifications Disabled'),
            content: Text('To receive notifications, please enable them in the app settings.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  static Future<void> sendPushNotification(
      String token, String title, String body) async {}

// void _initFirebaseMessaging() {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     // Handle message when the app is in the foreground
//     print("Message received: ${message.data}");
//     // Display a local notification
//     showNotification(message.notification?.title, message.notification?.body);
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     // Handle message when the app is opened from a terminated state
//     print("Message opened app: ${message.data}");
//     // Navigate to a specific screen or handle data
//   });

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Handle message when the app is in the background or terminated state
//   print("Message received in background: ${message.data}");
// }
}
