import 'package:flutter/material.dart';
import '../notifications/FMessageAPI.dart';
import 'TemporaryMessageOverlay.dart';


class TopSnackBar {
  static void show(BuildContext context, String message, Duration duration) {
    final overlay = Overlay.of(context)!;
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
        left: 0,
        right: 0,
        child: TemporaryMessageOverlay(
          message: message,
          duration: duration,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}



