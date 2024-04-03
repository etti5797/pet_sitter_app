import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homePages/designedHomePage.dart' as designedHomePage;
import 'notifications/NotificationHandler.dart' as NotificationHandler;
import 'notifications/FMessageAPI.dart';
import 'package:overlay_support/overlay_support.dart';
import 'in_app_chat/chats_page.dart';

// final navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessagingAPI().initNotifications();
  NotificationHandler.initialize();
  runApp(
    OverlaySupport(
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/singleChat': (context) => ChatWidget(userId: '', otherUserId: '', photoUrl: '', staticImagePath: '', otherName: ''),
      },
      title: 'Pet Sitter',
      scaffoldMessengerKey: FirebaseMessagingAPI.scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 201, 160, 106)),
        useMaterial3: true,
      ),
      // home: const HomePage(title: 'Pet Sitter Home Page'),
      home: designedHomePage.HomePage(),
    );
  }
}
