import 'package:flutter/material.dart';

class NewMessageIndicator extends StatelessWidget {
  final String userName;
  final VoidCallback onTap;

  const NewMessageIndicator({
    Key? key,
    required this.userName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.blue,
        child: Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '$userName sent a new message',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
