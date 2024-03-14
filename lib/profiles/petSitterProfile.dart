import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import '../pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/services/PetSitterService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PetSitterProfile extends StatefulWidget {
  final String petSitterId; // this is email
  final VoidCallback? onRemove;

  PetSitterProfile({required this.petSitterId, required this.onRemove});

  @override
  _PetSitterProfileState createState() => _PetSitterProfileState();
}

class _PetSitterProfileState extends State<PetSitterProfile> {
  bool isFavorite = false;
  var reviews = [];
  var favorites = [];
  var _petSitterData;

  Future<void> toggleFavoriteStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(user.email);
        DocumentSnapshot userData = await userRef.get();
        var favoritesData = userData.get('favorites');
        if (userData.exists) {
          List<dynamic> userFavorites =
              favoritesData != null ? List.from(favoritesData) : [];
          DocumentReference petSitterReference = FirebaseFirestore.instance
              .collection('petSitters')
              .doc(widget.petSitterId);
          if (userFavorites.contains(petSitterReference)) {
            userFavorites.remove(petSitterReference);
            if (widget.onRemove != null) {
              widget.onRemove!();
            }
          } else {
            if (widget.petSitterId != user.email) {
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
    return FutureBuilder(
      future: fetchPetSitterData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        _petSitterData = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 201, 160, 106),
            title: Text(
              'Pet Sitter Profile',
              style: GoogleFonts.pacifico(
                fontSize: 30,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            centerTitle: true,
          ),
          body: Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image and Name
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage(_petSitterData!['image']),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _petSitterData['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            IconButton(
                              icon: FutureBuilder<bool>(
                                future: UserDataService()
                                    .isPetSitterFavorite(widget.petSitterId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Icon(Icons.favorite_border);
                                  } else if (snapshot.hasError) {
                                    return Icon(Icons.favorite_border);
                                  } else {
                                    final isPetSitterFavorite =
                                        snapshot.data ?? false;
                                    return Icon(
                                      isPetSitterFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isPetSitterFavorite
                                          ? Colors.red
                                          : null,
                                    );
                                  }
                                },
                              ),
                              onPressed: () {
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                                toggleFavoriteStatus();
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_petSitterData['sumRate'] != null &&
                          _petSitterData['sumReview'] != null &&
                          _petSitterData['sumRate'] > 0 &&
                          _petSitterData['sumReview'] > 0) ...[
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingBar.builder(
                                initialRating: (_petSitterData['sumRate'] / _petSitterData['sumReview']).toDouble(),
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 30,
                                ignoreGestures: true, // Disable user interaction
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (value) => null,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_petSitterData['sumReview']} reviews',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingBar.builder(
                                initialRating: 0,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemSize: 30,
                                ignoreGestures: true, // Disable user interaction
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (value) => null,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '0 reviews',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Tab Controller
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Tab Bar
                      TabBar(
                        tabs: [
                          Tab(text: 'Information'),
                          Tab(text: 'Feedbacks'),
                        ],
                      ),
                      // Tab Bar View
                      Container(
                        height: 230, // Set a fixed height
                        child: TabBarView(
                          children: [
                            // Information Tab
                            Container(
                              child: ListView(
                                padding: EdgeInsets.all(16),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center the location horizontally
                                    children: [
                                      Icon(Icons.location_on),
                                      Text(
                                        _petSitterData['city'],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    textAlign: TextAlign.center,
                                    'Responsibilities: ${_petSitterData['pets'].join(', ')}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                            // Feedbacks Tab
                            Container(
                              padding: EdgeInsets.all(16),
                              child: SingleChildScrollView(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Show contact info button at the bottom
                FloatingActionButton(
                  onPressed: () {
                    showContactInfo(context, _petSitterData['email'],
                        _petSitterData['phoneNumber']);
                    addToRecentlyViewed();
                  },
                  child: Text('Show contact info'),
                ),
              ],
            ),
          ),
        );
      },
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
    var petSitter =
        await PetSitterService().getPetSitterByIdentifier(widget.petSitterId);
    var reviewsSnapshot = await FirebaseFirestore.instance
        .collection('petSitters')
        .doc(widget.petSitterId)
        .collection('reviews')
        .orderBy('timestamp',
            descending: true) // Order by timestamp in descending order
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
