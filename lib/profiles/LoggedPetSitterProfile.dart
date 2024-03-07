import 'dart:developer';
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
import 'package:petsitter/generalAppView.dart';

class LoggedPetSitterProfile extends StatefulWidget {
  final String petSitterId;

  LoggedPetSitterProfile({required this.petSitterId});

  @override
  _LoggedPetSitterProfileState createState() => _LoggedPetSitterProfileState();
}

class _LoggedPetSitterProfileState extends State<LoggedPetSitterProfile> {
  var reviews = [];
  var _petSitterData;
  TextEditingController _nameEditingController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   _nameEditingController.text = _petSitterData['name'];
  // }

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
                            Row(
                              children: [
                                Text(
                                  _petSitterData['name'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showEditNameDialog(context);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(width: 6),
                          ],
                        ),
                      ),
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
                        height: 200, // Set a fixed height
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
        .get();

    reviews = reviewsSnapshot.docs.map((doc) => doc.data()).toList();
    _nameEditingController.text = petSitter!['name'];

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

  void showEditNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextFormField(
            controller: _nameEditingController,
            decoration: InputDecoration(labelText: 'New Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the new name logic here
                String newName = _nameEditingController.text;
                
                // Check if the name contains a space
                if (newName.contains(' ')) {
                  List<String> nameParts = newName.split(' ');
                  String firstName = nameParts[0];
                  String lastName = nameParts[1];
                  
                  // Check if both first name and last name are provided
                  if (firstName.isNotEmpty && lastName.isNotEmpty) {
                    UserDataService().updateUserName(newName);
                    Navigator.of(context).pop();
                    setState(() {
                      _nameEditingController.text = newName;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneralAppPage(
                          initialIndex: 3,
                        ),
                      ),
                    ); // Refresh the profile page
                  } else {
                    // Show an error message if either first name or last name is missing
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Invalid Name'),
                          content: Text('Please provide both first name and last name.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // Show an error message if the name doesn't contain a space
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Invalid Name'),
                        content: Text('Please provide both first name and last name separated by a space.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
