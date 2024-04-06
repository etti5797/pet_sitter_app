import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:petsitter/in_app_chat/chats_page.dart';
import 'package:petsitter/main.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'NewMessageIndicator.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.data}");
}

class FirebaseMessagingAPI {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  String currentUserMail = '';

  Future<void> initCurrentUserMail() async {
    currentUserMail = await UserDataService().getUserEmail();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) {
      print("Message is null, returning");
      return;
    }

    print("Handling a message: ${message.data}");

    
    if (FirebaseMessagingAPI.scaffoldMessengerKey.currentState != null && 
          isSpecialWidgetActive == false) {
      String senderName = message.data['senderName'] ?? 'sender Name';
      String senderMail = message.data['senderMail'] ?? 'senderMail';
      String staticPhoto = message.data['staticPhoto'] ?? '';
      String photoUrl = message.data['photoUrl'] ?? '';

      final indicator = NewMessageIndicator(
        userName: senderName,
        userMail: senderMail,
        onTap: () {
          FirebaseMessagingAPI.scaffoldMessengerKey.currentState
              ?.hideCurrentSnackBar();
          navigatorKey.currentState?.pushNamed('/singleChat', arguments: {
            'currentUserMail': currentUserMail,
            'senderMail': senderMail,
            'senderName': senderName,
            'photoUrl': photoUrl,
            'staticImagePath': staticPhoto,
          });
          print('Tapped on new message indicator');
        },
      );
      //   final banner = NewMessageBanner(
      //   userName: 'senderName',
      //   onTap: () {
      //     // Handle tap event, e.g., navigate to chat screen
      //     // You can add your navigation logic here
      //     print('Tapped on new message banner');
      //   },
      // );

      //   FirebaseMessagingAPI.scaffoldMessengerKey.currentState!.showMaterialBanner(
      //       MaterialBanner(
      //   content: Text('New message received'),
      //   leading: Icon(Icons.message),
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         // Handle tap event, e.g., navigate to chat screen
      //         // You can add your navigation logic here
      //         print('Tapped on new message banner');
      //       },
      //       child: Text('View'),
      //     ),
      //   ],
      // ),
      //   );
      FirebaseMessagingAPI.scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: indicator,
          duration: Duration(seconds: 6),
        ),
      );
    } else {
      print("ScaffoldMessenger is not available");
    }
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.data}");
      handleMessage(message); // Handle message when app is in foreground
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app: ${message.data}");
      String senderMail = message.data['senderMail'] ?? 'senderMail';
      String senderName = message.data['senderName'] ?? 'sender Name';
      String staticPhoto = message.data['staticPhoto'] ?? '';
      String photoUrl = message.data['photoUrl'] ?? '';
      // Handle message when app is opened from a terminated state

      navigatorKey.currentState?.pushNamed('/singleChat', arguments: {
        'currentUserMail': currentUserMail,
        'senderMail': senderMail,
        'senderName': senderName,
        'photoUrl': photoUrl,
        'staticImagePath': staticPhoto,
      });
    });
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
      initCurrentUserMail();
      initPushNotifications();
    } else {
      print('User did not grant permission to receive notifications');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Notifications Disabled'),
            content: Text(
                'To receive notifications, please enable them in the app settings.'),
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

  static void showNewMessageOverlay() {
    final customBanner = MaterialBanner(
      content: Text('New message received'),
      leading: Icon(Icons.message),
      actions: [
        TextButton(
          onPressed: () {
            // Handle tap event, e.g., navigate to chat screen
            // You can add your navigation logic here
            print('Tapped on new message banner');
          },
          child: Text('View'),
        ),
      ],
    );

    final scaffoldMessenger = scaffoldMessengerKey.currentState;
    if (scaffoldMessenger != null) {
      final overlay = Overlay.of(scaffoldMessenger.context)!;
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: customBanner,
        ),
      );

      // Show the banner by inserting it into the overlay
      overlay.insert(overlayEntry);

      // Remove the banner after a certain duration
      Future.delayed(Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    } else {
      print("ScaffoldMessenger is not available");
      // Handle the case where ScaffoldMessenger is not available
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
