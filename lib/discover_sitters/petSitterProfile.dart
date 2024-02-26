import 'package:flutter/material.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';
import '../pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/services/PetSitterService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/feedbacks_handler/reviewCard.dart';


class PetSitterProfile extends StatefulWidget {
  final String petSitterId;

  PetSitterProfile({required this.petSitterId});

  @override
  _PetSitterProfileState createState() => _PetSitterProfileState();
}

class _PetSitterProfileState extends State<PetSitterProfile> {
  bool isFavorite = false;
  var reviews = [];

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
                      // Heart icon
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
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
