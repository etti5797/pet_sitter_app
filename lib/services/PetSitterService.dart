import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'dart:math';

class FunNameGenerator {
  static final List<String> adjectives = [
    "Happy",
    "Silly",
    "Cheerful",
    "Whimsical",
    "Jolly",
    "Bubbly",
    "Lively",
    "Giggly",
    "Playful",
    "Joyful",
    "Charming",
    "Zany",
    "Quirky",
    "Energetic",
    "Carefree",
    "Sprightly",
    "Merry",
    "Bouncy",
    "Peppy",
    "Vivacious",
  ];

  static final List<String> nouns = [
    "Puppy",
    "Kitty",
    "Penguin",
    "Panda",
    "Giraffe",
    "Tiger",
    "Elephant",
    "Monkey",
    "Dolphin",
    "Koala",
    "Llama",
    "Owl",
    "Bunny",
    "Fox",
    "Unicorn",
    "Dragon",
    "Mermaid",
    "Fairy",
    "Narwhal",
    "Robot",
  ];

  static String generateFunName() {
    final Random random = Random();
    final String adjective = adjectives[random.nextInt(adjectives.length)];
    final String noun = nouns[random.nextInt(nouns.length)];
    return '$adjective $noun';
  }
}



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

void addReview(String petSitterId, String reviewText, bool anonymous) async {
   String currentUserName = await UserDataService().getUserName();
  //petSitterId is his
  if (anonymous == true) {
    String funName = FunNameGenerator.generateFunName() + ' (Anonymous)';
    await _firestore
    .collection('petSitters')
    .doc(petSitterId)
    .collection('reviews')
    .add({
      'reviewerName': funName,
      'reviewText': reviewText,
      'timestamp': Timestamp.now(),
    });
  } else {
    await _firestore
    .collection('petSitters')
    .doc(petSitterId)
    .collection('reviews')
    .add({
      'reviewerName': currentUserName,
      'reviewText': reviewText,
      'timestamp': Timestamp.now(),
    });
  }
  // await _firestore
  //   .collection('petSitters')
  //   .doc(petSitterId)
  //   .collection('reviews')
  //   .add({
  //     'reviewerName': currentUserName,
  //     'reviewText': reviewText,
  //     'timestamp': Timestamp.now(),
  //   });
}

  Future<List<Map<String, dynamic>>> getReviews(String petSitterId) async {
    QuerySnapshot querySnapshot = await _firestore
      .collection('petSitters')
      .doc(petSitterId)
      .collection('reviews')
      .orderBy('timestamp', descending: true)
      .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

}
