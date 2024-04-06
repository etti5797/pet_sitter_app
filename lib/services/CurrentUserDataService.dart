import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserDataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userEmail = ''; //in order not to get the email from the database every time
  String userName = ''; //in order not to get the name from the database every time
  String userImage = '';
  String userPhotoUrl = '';
  String staticImagePath = '';

    //every cached field should be cleared when the user logs out
    Future<void> signOut() async {
      _auth.signOut();
      userEmail = '';
      userName = '';
      userImage = '';
      userPhotoUrl = '';
      cleanPushToken();
    }

    Future<void> cleanPushToken() async {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.email).update({
          'pushToken': '',
        });
      }
    }

    Future<String> getUserName() async {
    try {
      if(userName.isNotEmpty && userName != 'Unknown'){
        return userName;
      }

      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.email).get();

        if (userDoc.exists) {
          // Adjust this based on your Firestore document structure
          String userName = userDoc['name']; // Replace 'city' with the actual field name in your Firestore document
          return userName;
        }
      }

      return 'Unknown'; // Default value if user or user data not found
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error'; // Handle errors as needed
    }
  }

      Future<void> updateUserName(String newName) async {
      try {
        User? user = _auth.currentUser;

        if (user != null) {
          await _firestore
              .collection('users')
              .doc(user.email)
              .update({'name': newName});
          userName = newName;
          if(await isPetSitter()){
            await _firestore
              .collection('petSitters')
              .doc(user.email)
              .update({'name': newName});
          }
        }
      } catch (e) {
        print('Error updating user name: $e');
        //TODO: if was any error need to show a message to the user
      }
    }

  Future<bool> isPetSitter() async {
    try {
      bool isPetSitter = false; 
      String email = await getUserEmail();

      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('petSitters').doc(user.email).get();

        if (userDoc.exists) {
          isPetSitter = true;
        }
      }

      return isPetSitter; // Default value if user or user data not found
    } catch (e) {
      print('Error fetching user city: $e');
      return false; // Handle errors as needed
    }
  }

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

    Future<String> getUserEmail() async {
    try {
      if(userEmail.isNotEmpty){
        return userEmail;
      }

      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.email).get();

        if (userDoc.exists) {
          // Adjust this based on your Firestore document structure
          String userName = userDoc['email']; // Replace 'city' with the actual field name in your Firestore document
          return userName;
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

        // Get the email of the new document reference
        String? newDocEmail = (await documentReference.get()).get('email') as String?;

        // Remove any existing reference with the same email as the new document
        for (int i = 0; i < recentlyViewedReferences.length; i++) {
          String? refEmail = (await recentlyViewedReferences[i].get()).get('email') as String?;
          if (refEmail == newDocEmail) {
            recentlyViewedReferences.removeAt(i);
            break; // Exit the loop after removing the first matching reference
          }
        }

        // Insert the new document reference at the beginning of the list
        if( newDocEmail!= currentUser.email)
        {
          recentlyViewedReferences.insert(0, documentReference);
        }
        

        //Limit the list to a certain number of items, if desired
        if (recentlyViewedReferences.length > 10) {
          recentlyViewedReferences.removeLast();
        }

        await _firestore.collection('users').doc(currentUser.email).update({
          'recentlyViewed': recentlyViewedReferences,
        });
      }
    }
  } catch (e) {
    print('Error adding recently viewed document: $e');}
}


Future<void> addFavoriteDocuments(DocumentReference documentReference) async {
  try {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('users').doc(currentUser.email).get();

      if (userSnapshot.exists) {
        List<DocumentReference> favoritedReferences = List<DocumentReference>.from(
            userSnapshot.data()?['favorites'] ?? <DocumentReference>[]);

        // Get the email of the new document reference
        String? newDocEmail = (await documentReference.get()).get('email') as String?;

        // Remove any existing reference with the same email as the new document
        for (int i = 0; i < favoritedReferences.length; i++) {
          String? refEmail = (await favoritedReferences[i].get()).get('email') as String?;
          if (refEmail == newDocEmail) {
            favoritedReferences.removeAt(i);
            break; // Exit the loop after removing the first matching reference
          }
        }

        // Insert the new document reference at the beginning of the list
        if( newDocEmail!= currentUser.email)
        {
          favoritedReferences.insert(0, documentReference);
        }
        

        //Limit the list to a certain number of items, if desired
        if (favoritedReferences.length > 30) {
          favoritedReferences.removeLast();
        }

        await _firestore.collection('users').doc(currentUser.email).update({
          'favorites': favoritedReferences,
        });
      }
    }
  } catch (e) {
    print('Error adding favorite document: $e');}
}



  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getFavoriteDocuments() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await _firestore.collection('users').doc(currentUser.email).get();

        if (userSnapshot.exists) {
          List<DocumentReference> favoriteReferences = List<DocumentReference>.from(
              userSnapshot.data()?['favorites'] ?? <DocumentReference>[]);
              
          List<DocumentSnapshot<Map<String, dynamic>>> favoritesDocuments = [];

          for (DocumentReference reference in favoriteReferences) {
            DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get() as DocumentSnapshot<Map<String, dynamic>>;
            favoritesDocuments.add(documentSnapshot);
          }

          return favoritesDocuments;
        }
      }
    } catch (e) {
      print('Error fetching favorite viewed documents: $e');
    }

    return [];
  }

  


  Future<void> removeFavoriteDocument(DocumentReference documentReference) async {
  try {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('users').doc(currentUser.email).get();

      if (userSnapshot.exists) {
        List<DocumentReference> favoritedReferences = List<DocumentReference>.from(
            userSnapshot.data()?['favorites'] ?? <DocumentReference>[]);

        // Get the email of the document reference to be removed
        String? docToRemoveEmail = (await documentReference.get()).get('email') as String?;

        // Find and remove the document reference with the matching email
        for (int i = 0; i < favoritedReferences.length; i++) {
          String? refEmail = (await favoritedReferences[i].get()).get('email') as String?;
          if (refEmail == docToRemoveEmail) {
            favoritedReferences.removeAt(i);
            break; // Exit the loop after removing the first matching reference
          }
        }

        // Update the user's favorites list in Firestore
        await _firestore.collection('users').doc(currentUser.email).update({
          'favorites': favoritedReferences,
        });
      }
    }
  } catch (e) {
    print('Error removing favorite document: $e');
  }
}

  Future<bool> isPetSitterFavorite(String petSitterId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();
        if (userData.exists) {
          List<dynamic> userFavorites = [];
          // var userData = snapshot.data;
          if (userData['favorites'] != null) {
            var favoritesData = userData['favorites'];
            if (favoritesData != null && favoritesData is List<dynamic>) {
              userFavorites = favoritesData;
            }
          }
          DocumentReference petSitterReference = FirebaseFirestore.instance
              .collection('petSitters')
              .doc(petSitterId);
          return userFavorites.contains(petSitterReference);
        }
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    // Upload profile picture to Firebase Storage
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String filePath = 'profile_pictures/$userId.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  
  //   Future<void> _pickAndUploadProfilePicture() async {
  //   // Allow user to pick a profile picture and upload it
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     File imageFile = File(pickedFile.path);
  //     String? profilePictureUrl = await _uploadProfilePicture(imageFile);
  //     if (profilePictureUrl != null) {
  //       setState(() {
  //         _userProfile!.profilePictureUrl = profilePictureUrl;
  //       });
  //       // Update profile picture URL in Firebase Authentication
  //       await FirebaseAuth.instance.currentUser!.updatePhotoURL(profilePictureUrl);
  //     }
  //   }
  // }

  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update the photo URL in Firestore
        await _firestore.collection('users').doc(currentUser.email).update({
          'photoUrl': photoUrl,
        });
        if(await isPetSitter()){
        await _firestore.collection('petSitters').doc(currentUser.email).update({
          'photoUrl': photoUrl,
        });
        }
        userPhotoUrl = photoUrl;
      }
    } catch (e) {
      print('Error updating photo URL: $e');
    }
  }
  
  Future<String> getUserPhotoUrl() async {
    try {
      if(userPhotoUrl.isNotEmpty){
        return userPhotoUrl;
      }
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(currentUser.email).get();
        if (userData.exists) {
          return userData.get('photoUrl');
        }
      }
      return '';
    } catch (e) {
      print('Error getting photo URL: $e');
      return '';
    }
  }

  Future<String> getUserStaticImagePath() async {
    try {
      if(staticImagePath.isNotEmpty){
        return staticImagePath;
      }
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(currentUser.email).get();
        if (userData.exists) {
          return userData.get('image');
        }
      }
      return '';
    } catch (e) {
      print('Error getting image: $e');
      return '';
    }
  }
  
  Future<void> pushTokenToFirestore(String token) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.email).update({
          'pushToken': token,
        });
      }
    } catch (e) {
      print('Error updating push token: $e');
    }
  }
  
}