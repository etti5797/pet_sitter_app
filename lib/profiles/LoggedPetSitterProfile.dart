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
  TextEditingController _firstNameEditingController = TextEditingController();
  TextEditingController _lastNameEditingController = TextEditingController();

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
    String name = petSitter!['name'];
    List<String> nameParts = name.split(' ');
    _firstNameEditingController.text = nameParts[0];
    _lastNameEditingController.text = nameParts.length > 1 ? nameParts[1] : '';

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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameEditingController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameEditingController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
              ],
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
                  String firstName = _firstNameEditingController.text;
                  String lastName = _lastNameEditingController.text;

                  if (firstName.isNotEmpty && lastName.isNotEmpty) {
                    String newName = '$firstName $lastName';
                    UserDataService().updateUserName(newName);
                    Navigator.of(context).pop();
                    setState(() {
                      _firstNameEditingController.text = firstName;
                      _lastNameEditingController.text = lastName;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GeneralAppPage(
                            initialIndex: 3, // Refresh the profile page
                          ),
                        ),
                      );
                    });
                  } else {
                    // Show an error message if first name or last name is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a full name.'),
                      ),
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
