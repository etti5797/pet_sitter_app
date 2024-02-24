// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'dart:developer' as developer;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signUp/signUpPage.dart';
import 'utils/utils.dart';
import 'homePages/designedHomePage.dart' as designedHomePage;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;
  // final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Text(
          'Pet Sitter',
          style: GoogleFonts.pacifico(
              fontSize: 50, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Utils().buildCircularImage('homePageImage.png', 350), 
            const SizedBox(height: 20),
            Text(
              'Welcome!\nConnecting between pet guardians\nand pet sitters',
              textAlign: TextAlign.center,
              style: GoogleFonts.amarante(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to Login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 160, 106),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const SizedBox(
                width: 360, // Set the desired width
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I have a PetSitter account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                    SizedBox(
                        width:
                            10), // Add some spacing between the icon and the text
                    Icon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUpPage()), // Navigate to SignUpPage
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 160, 106),
                padding: const EdgeInsets.symmetric(horizontal: 67),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Create your PetSitter account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
