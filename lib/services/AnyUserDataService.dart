import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'dart:math';

class AnyUserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserPushToken(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await _firestore
          .collection('users')
          .doc(email)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['pushToken'];
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching user push token: $e');
      return ''; // Handle errors as needed
    }
  }

}
