import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserCity() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.email).get();

        if (userDoc.exists) {
          // Adjust this based on your Firestore document structure
          String userCity = userDoc['city']; // Replace 'city' with the actual field name in your Firestore document
          return userCity;
        }
      }

      return 'Unknown'; // Default value if user or user data not found
    } catch (e) {
      print('Error fetching user city: $e');
      return 'Error'; // Handle errors as needed
    }
  }


  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getRecentlyViewedDocuments() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await _firestore.collection('users').doc(currentUser.email).get();

        if (userSnapshot.exists) {
          List<DocumentReference> recentlyViewedReferences = List<DocumentReference>.from(
              userSnapshot.data()?['recentlyViewed'] ?? <DocumentReference>[]);

          List<DocumentSnapshot<Map<String, dynamic>>> recentlyViewedDocuments = [];

          for (DocumentReference reference in recentlyViewedReferences) {
            DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get() as DocumentSnapshot<Map<String, dynamic>>;
            recentlyViewedDocuments.add(documentSnapshot);
          }

          return recentlyViewedDocuments;
        }
      }
    } catch (e) {
      print('Error fetching recently viewed documents: $e');
    }

    return [];
  }

  Future<void> addRecentlyViewedDocument(DocumentReference documentReference) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await _firestore.collection('users').doc(currentUser.email).get();

        if (userSnapshot.exists) {
          List<DocumentReference> recentlyViewedReferences = List<DocumentReference>.from(
              userSnapshot.data()?['recentlyViewed'] ?? <DocumentReference>[]);
          recentlyViewedReferences.add(documentReference);

          await _firestore.collection('users').doc(currentUser.email).update({
            'recentlyViewed': recentlyViewedReferences,
          });
        }
      }
    } catch (e) {
      print('Error adding recently viewed document: $e');
    }
  }
}
