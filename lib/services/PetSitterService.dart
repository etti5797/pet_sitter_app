import 'package:cloud_firestore/cloud_firestore.dart';

class PetSitterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getPetSitterByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('petSitters')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the first document found (there should be at most one)
        return querySnapshot.docs.first;
      } else {
        // No pet sitter found with the provided email
        return null;
      }
    } catch (e) {
      print('Error fetching pet sitter: $e');
      return null; // Handle errors as needed
    }
  }

  Future<Map<String, dynamic>?> getPetSitterByIdentifier(String identifier) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot =
          await _firestore.collection('petSitters').doc(identifier).get();

      if (petSitterSnapshot.exists) {
        // Pet Sitter found
        return petSitterSnapshot.data();
      } else {
        // No pet sitter found with the provided identifier
        return null;
      }
    } catch (e) {
      print('Error fetching pet sitter: $e');
      return null; // Handle errors as needed
    }
  }

}
