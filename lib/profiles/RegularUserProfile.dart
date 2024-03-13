import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import 'package:petsitter/profiles/petSitterProfile.dart';
import '../pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/services/PetSitterService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petsitter/utils/utils.dart' as utils;
import 'package:petsitter/services/PetSitterService.dart' as petSitterService;
import 'package:petsitter/profiles/LoggedPetSitterProfile.dart';
import 'package:petsitter/generalAppView.dart';
import '../utils/connectivityUtil.dart';

late bool? isPetSitter = null;

class UserProfile extends StatefulWidget {
  UserProfile();

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  String name = '';
  String mail = '';
  String image = '';
  TextEditingController _firstNameEditingController = TextEditingController();
  TextEditingController _lastNameEditingController = TextEditingController();

  Future<List<dynamic>> fetchUserData() async {
    name = await UserDataService().getUserName();
    mail = await UserDataService().getUserEmail();

    var value = await petSitterService.PetSitterService().getPetSitterByEmail(mail);
      if (value != null) {
        isPetSitter = true;
      } else {
        isPetSitter = false;
      }
    
    List<String> nameParts = name.split(' ');
    _firstNameEditingController.text = nameParts[0];
    _lastNameEditingController.text = nameParts.length > 1 ? nameParts[1] : '';


    return [name, isPetSitter];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fetchUserData(),
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
              if (!snapshot.data![1]) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          utils.Utils().buildCircularImageLocal('images/userProfileImage.jpg', 300),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data![0],
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showEditNameDialog(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  // height: 500, // Provide a specific height
                  height: MediaQuery.of(context).size.height, // Use the full height of the screen
                  width: MediaQuery.of(context).size.width, // Use the full width of the screen
                  child: LoggedPetSitterProfile(petSitterId: mail),
                );
              }
            }
          },
        ),
      ),
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
                onPressed: () async {
                  bool isConnected = await ConnectivityUtil.checkConnectivity(context);
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
