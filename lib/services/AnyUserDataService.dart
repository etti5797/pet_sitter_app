import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<String> getUserPhotoUrl(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await _firestore
          .collection('users')
          .doc(email)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['photoUrl'];
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching user image: $e');
      return ''; // Handle errors as needed
    }
  }

  Future<String> getUserStaticImagePath(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await _firestore
          .collection('users')
          .doc(email)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['image'];
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching user image: $e');
      return ''; // Handle errors as needed
    }
  }

}
