import 'package:flutter/material.dart';

class ImageAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? staticImagePath;
  final double size;

  const ImageAvatar({
    Key? key,
    required this.photoUrl,
    required this.staticImagePath,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : AssetImage(staticImagePath!) as ImageProvider<Object>,
    );
  }
}