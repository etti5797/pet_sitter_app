import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final double size;

  const InitialsAvatar({
    required this.firstName,
    required this.lastName,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    // Extract first letters
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0] : '';

    // Combine initials
    String initials = '$firstInitial$lastInitial';

    // Determine background color based on initials
    Color backgroundColor = Colors.blue; // Default color
    // You can implement logic to assign a color based on initials

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4, // Adjust font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
