import 'package:flutter/material.dart';

class ProfileAvatarFromImage extends StatelessWidget {
  final Image image;
  final double size;

  const ProfileAvatarFromImage({
    Key? key,
    required this.image,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: image.image,
    );
  }
}