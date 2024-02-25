import 'package:flutter/material.dart';
import 'pickImageForPetSitter.dart';
import 'package:petsitter/services/PetSitterService.dart';
import 'package:google_fonts/google_fonts.dart';

class PetSitterProfile extends StatelessWidget {
  final String petSitterId;

  PetSitterProfile({required this.petSitterId});

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
            // TODO: Extract pet sitter data from snapshot
            final petSitterData = snapshot.data as Map<String, dynamic>;

            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image
                  Image(
                    image: loadRandomImage('cats').image,
                  ),
                  SizedBox(height: 16),
                  // Display name and city with location icon
                  Row(
                    children: [
                      Text(
                        petSitterData['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
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
                    'Pets: ${petSitterData['pets'].join(', ')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Show contact info button
                  ElevatedButton(
                    onPressed: () {
                      showContactInfo(context, petSitterData['email'], petSitterData['phoneNumber']);
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

  Future<dynamic> fetchPetSitterData() {
    var petSitter = PetSitterService().getPetSitterByIdentifier(petSitterId);

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
