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

bool isPetSitter = false;

class UserProfile extends StatefulWidget {
  UserProfile();

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  String name = '';
  String mail = '';
  String image = '';

  // @override
  // void initState() {
  //   super.initState();
  //   fetchUserData();
  // }

  Future<List<dynamic>> fetchUserData() async {
    name = await UserDataService().getUserName();
    mail = await UserDataService().getUserEmail();

    petSitterService.PetSitterService().getPetSitterByEmail(mail).then((value) {
      if (value != null) {
        isPetSitter = true;
      }
    });

    return [name, isPetSitter];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   // title: Text('Profile'),
      // ),
      body: FutureBuilder(
        // Replace with your actual data fetching logic
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
            if(!snapshot.data![1]){
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
                        child: Text(
                          snapshot.data![0],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            } else {
              return LoggedPetSitterProfile(petSitterId: mail);
            }
          }
        },
      ),
    );
  }
  
}
