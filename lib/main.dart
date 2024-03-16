import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signUp/signUpPage.dart';
import 'utils/utils.dart';
import 'homePages/designedHomePage.dart' as designedHomePage;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notifications/NotificationHandler.dart' as NotificationHandler;
import 'notifications/FMessageAPI.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessagingAPI().initNotifications();
  NotificationHandler.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Sitter',
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


