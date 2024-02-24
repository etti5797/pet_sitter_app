import 'package:flutter/material.dart';

class RecentlyViewedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Recently Viewed'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recently Viewed Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Image.network(
            'YOUR_IMAGE_URL',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Recently Viewed Item 1'),
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Recently Viewed Item 2'),
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Recently Viewed Item 3'),
          ),
          // Add more ListTile widgets for additional recently viewed items
        ],
      ),
    );
  }
}
