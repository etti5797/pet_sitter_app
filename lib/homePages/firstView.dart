import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Replace with your desired background color
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/first.jpeg'),
            SizedBox(height: 16),
            Text(
              'Find pet sitters around',
              style: GoogleFonts.abel(
                fontSize: 30,
                color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Find a pet sitters near you who has a background and meets your need!',
              textAlign: TextAlign.center,
              style: GoogleFonts.abel(
                fontSize: 18,
                color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Become a Sitter?',
              style: GoogleFonts.abel(
                fontSize: 30,
                color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Sign up to the app as a Pet Sitter then people will see you!',
              textAlign: TextAlign.center,
              style: GoogleFonts.abel(
                fontSize: 18,
                color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}