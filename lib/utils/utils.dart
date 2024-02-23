import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Utils {
  Widget buildCircularImage(String fileName, double radius) {
    return FutureBuilder<String>(
      future: downloadFile(fileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Container(
            width: radius,
            height: radius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(snapshot.data!),
              ),
            ),
          );
        }
      },
    );
  }

  Future<String> downloadFile(String fileName) async {
    try {
      var ref = firebase_storage.FirebaseStorage.instance.ref(fileName);

      var downloadUrl = await ref.getDownloadURL();
      // developer.log('Download URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      // developer.log('Error downloading file: $e');
      rethrow;
    }
  }
}
