import 'package:flutter/material.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import '../pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/services/PetSitterService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PetSitterProfile extends StatefulWidget {
  final String petSitterId; // this is email

  PetSitterProfile({required this.petSitterId});

  @override
  _PetSitterProfileState createState() => _PetSitterProfileState();
}
//bool isFavorite = false;
class _PetSitterProfileState extends State<PetSitterProfile> {
  bool isFavorite = false;
  var reviews = [];
  var favorites = [];
  

  Future<bool> isPetSitterFavorite() async {
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
        .doc(widget.petSitterId);
        return userFavorites.contains(petSitterReference);
      }
    }
    return false;
  } catch (e) {
    print('Error checking favorite status: $e');
    return false;
  }
}

Future<void> toggleFavoriteStatus() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.email);
      DocumentSnapshot userData = await userRef.get();
      var favoritesData = userData.get('favorites');
      if (userData.exists) {
        List<dynamic> userFavorites = favoritesData != null ? List.from(favoritesData) : [];
        DocumentReference petSitterReference = FirebaseFirestore.instance
        .collection('petSitters')
        .doc(widget.petSitterId);
        if (userFavorites.contains(petSitterReference)) {
          userFavorites.remove(petSitterReference);
        } else {
          if(widget.petSitterId != user.email)
          {
            userFavorites.insert(0, petSitterReference);
          }
          if (userFavorites.length > 25) {
            userFavorites.removeLast();
          }
          
        }
        await userRef.update({'favorites': userFavorites});
      }
    }
  } catch (e) {
    print('Error toggling favorite status: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Text(
          'Pet Sitter Information',
          style: GoogleFonts.pacifico(
              fontSize: 30, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchPetSitterData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {

            final petSitterData = snapshot.data as Map<String, dynamic>;

            var petTypes = List<String>.from(petSitterData['pets']);
            String allPets = getPetTypeFromList(petTypes);

            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(petSitterData['image']),
                  // Display image
                  // Image(
                  //   image: loadRandomImage(allPets).image,
                  //   Image.asset(randomImagePath);
                  // ),
                  SizedBox(height: 16),
                  Row(
                    children: [

                      IconButton(
                          icon: FutureBuilder<bool>(
                            future: isPetSitterFavorite(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Icon(Icons.favorite_border); // Placeholder icon while loading
                              } else if (snapshot.hasError) {
                                return Icon(Icons.favorite_border); // Placeholder icon if there's an error
                              } else {
                                final isPetSitterFavorite = snapshot.data ?? false;
                                return Icon(
                                  isPetSitterFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isPetSitterFavorite ? Colors.red : null,
                                );
                              }
                            },
                          ),
                          onPressed: () {
                            setState(() {
                              toggleFavoriteStatus();
                            });
                          },
                        ),

                      // Heart icon
                      // IconButton(
                      //   icon: Icon(
                      //     isFavorite ? Icons.favorite : Icons.favorite_border,
                      //     color: isFavorite ? Colors.red : null,
                      //   ),
                      //   onPressed: () {
                      //     setState(() {
                      //       isFavorite = !isFavorite;
                      //     });
                      //    // UserDataService().getFavoriteDocuments();
                      //    if(isFavorite == false)
                      //    {
                      //     addToFavorites();
                      //    }
                      //    else
                      //    {
                      //      removeFromFavorites();
                      //    }
                      //   },
                      // ),
                      SizedBox(width: 8),
                      Text(
                        petSitterData['name'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Display name and city with location icon
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      Text(
                        petSitterData['city'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Display pets
                  Text(
                    'Responsibilities: ${petSitterData['pets'].join(', ')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16), 
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        reviews.length,
                        (index) {
                          final review = reviews[index];
                          return ReviewCard(review: review);
                        },
                      ),
                    ),
                  ),
                  // Show contact info button
                  ElevatedButton(
                    onPressed: () {
                      showContactInfo(context, petSitterData['email'],
                          petSitterData['phoneNumber']);
                      addToRecentlyViewed();
                    },
                    child: Text('Show contact info'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void addToRecentlyViewed() {
    DocumentReference petSitterReference = FirebaseFirestore.instance
        .collection('petSitters')
        .doc(widget.petSitterId);
    UserDataService().addRecentlyViewedDocument(petSitterReference);
  }

    void addToFavorites() {
    DocumentReference petSitterReference = FirebaseFirestore.instance
        .collection('petSitters')
        .doc(widget.petSitterId);
    UserDataService().addFavoriteDocuments(petSitterReference);
  }

    void removeFromFavorites() {
    DocumentReference petSitterReference = FirebaseFirestore.instance
        .collection('petSitters')
        .doc(widget.petSitterId);
    UserDataService().removeFavoriteDocument(petSitterReference);
  }

  Future<Map<String, dynamic>?> fetchPetSitterData() async {
    var petSitter = await PetSitterService().getPetSitterByIdentifier(widget.petSitterId);
    var reviewsSnapshot = await FirebaseFirestore.instance
        .collection('petSitters')
        .doc(widget.petSitterId)
        .collection('reviews')
        .get();

    reviews = reviewsSnapshot.docs.map((doc) => doc.data()).toList();
    
    return petSitter;
  }

  void showContactInfo(BuildContext context, String email, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contact Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: $email'),
              Text('Phone Number: $phoneNumber'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
