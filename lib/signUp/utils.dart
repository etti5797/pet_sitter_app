import 'package:flutter/material.dart';

class Utils {
  static void showAdditionalQuestionsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Additional Questions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Question 1'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please answer Question 1';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Question 2'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please answer Question 2';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Question 3'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please answer Question 3';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle submit button press
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
