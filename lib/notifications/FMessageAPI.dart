import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:petsitter/in_app_chat/chatListPage.dart';
import 'package:petsitter/main.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import '../in_app_chat/chatListPage.dart';
import 'TopSnackBar.dart';
import 'NewMessageIndicator.dart';
import 'NewMessageBanner.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.data}");
}

class FirebaseMessagingAPI {
    static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) {
      print("Message is null, returning");
      return;
    }

    print("Handling a message: ${message.data}");
    // scaffoldMessengerKey.currentState!.showSnackBar(
    //               SnackBar(
    //           content: Text('New message received'),
    //         ),);

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

    if (FirebaseMessagingAPI.scaffoldMessengerKey.currentState != null) {
      final scaffoldMessenger = FirebaseMessagingAPI.scaffoldMessengerKey.currentState;

      // FirebaseMessagingAPI.scaffoldMessengerKey.currentState!.showSnackBar(
      //   SnackBar(
      //     content: Text('New message received'),
      //     behavior: SnackBarBehavior.fixed,
      //     // margin: EdgeInsets.only(top: 0.0), // Set the top position to 0
      //     duration: Duration(seconds: 3),
      //   ),
      // );

      String senderName = message.data['senderName'] ?? 'senderName';
      final indicator = NewMessageIndicator(
      userName: 'senderName',
      onTap: () {
        // Handle tap event, e.g., navigate to chat screen
        // You can add your navigation logic here
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
      // Handle the case where ScaffoldMessenger is not available
    }

    //TODO: need to navigate to the relevant chat...
    // navigatorKey.currentState!.pushNamed(
    //   ChatsListPage.route,
    // );
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
    // Handle message when app is opened from a terminated state
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
