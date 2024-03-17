import 'package:flutter/material.dart';

class TemporaryMessageOverlay extends StatelessWidget {
  final String message;
  final Duration duration;

  const TemporaryMessageOverlay({
    Key? key,
    required this.message,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
