import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/discover_sitters/petSitterProfile.dart';

class RecentPetSitterCard extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot;

  RecentPetSitterCard({required this.petSitterSnapshot});

  var petSitterName;
  var petTypes;
  var email;

@override
Widget build(BuildContext context) {
  petSitterName = petSitterSnapshot['name'];
  petTypes = List<String>.from(petSitterSnapshot['pets']);
  email = petSitterSnapshot['email'];
  String allPets = getPetTypeFromList(petTypes);
  String cityName = petSitterSnapshot['city'];

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PetSitterProfile(petSitterId: email),
        ),
      );
    },
    child: Card(
      elevation: 1, // Adjust the elevation value to make the card less prominent
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Adjust the margin values to reduce the card size
      child: ListTile(
        contentPadding: EdgeInsets.all(5),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: Image.asset(petSitterSnapshot['image']).image,
          // backgroundImage: loadRandomImage(allPets).image,
        ),
        title: Text(
          petSitterName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  cityName,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            // TODO (Hiba): discuss with the team if we should display the pet types in the card
            // SizedBox(height: 4),
            // Wrap(
            //   spacing: 4,
            //   children: petTypes.map<Widget>((responsibility) {
            //     return Chip(
            //       label: Text(responsibility),
            //       backgroundColor: Colors.blue,
            //       labelStyle: TextStyle(color: Colors.white),
            //     );
            //   }).toList(),
            // ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_comment),
          onPressed: () {
            // Add feedback functionality here
          },
        ),
      ),
    ),
  );
}

}
