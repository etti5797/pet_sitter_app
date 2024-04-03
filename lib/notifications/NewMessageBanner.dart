import 'package:flutter/material.dart';

class NewMessageBanner extends StatelessWidget {
  final String userName;
  final VoidCallback onTap;

  const NewMessageBanner({
    Key? key,
    required this.userName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text('$userName sent a new message'),
      leading: Icon(Icons.message),
      actions: [
        TextButton(
          onPressed: onTap,
          child: Text('View'),
        ),
      ],
    );
  }
}
