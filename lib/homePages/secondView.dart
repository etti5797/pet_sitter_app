import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/giveFeedback.jpg'),
          SizedBox(height: 16),
            Text(
              'Give feedback on your pet sitter',
              style: GoogleFonts.abel(
                fontSize: 30,
                color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Give feedback on pet sitters to share your experience and help others!',
              textAlign: TextAlign.center,
              style: GoogleFonts.abel(
                fontSize: 18,
                color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}