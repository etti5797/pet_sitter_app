import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/discover_sitters/petSitterProfile.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/services/PetSitterService.dart';

class FavoriteCard extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot;

  FavoriteCard({required this.petSitterSnapshot});

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
        // trailing: IconButton(
        //   icon: Icon(Icons.add_comment),
        //   onPressed: () {
        //     // Add feedback functionality here
        //     showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         final TextEditingController feedbackController = TextEditingController();

        //         return AlertDialog(
        //           title: Text('Feedback'),
        //           content: TextField(
        //             controller: feedbackController, // Add the controller to the TextField
        //             maxLength: 100,
        //             decoration: InputDecoration(
        //               hintText: 'Enter your feedback',
        //             ),
        //           ),
        //           actions: [
        //             ElevatedButton(
        //               onPressed: () async {
        //                 // Handle submit feedback here
        //                 String currentUserEmail = await UserDataService().getUserEmail();
        //                 String feedback = feedbackController.text; // Get the text from the controller
        //                 PetSitterService().addReview(email, feedback);
        //                 Navigator.of(context).pop();
        //               },
        //               child: Text('Submit'),
        //             ),
        //             ElevatedButton(
        //               onPressed: () {
        //                 // Handle cancel feedback here
        //                 Navigator.of(context).pop();
        //               },
        //               child: Text('Cancel'),
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //   },
        // ),
      ),
    ),
  );
}

}





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:petsitter/services/CurrentUserDataService.dart' as currentUserDataService;
// import 'package:petsitter/pet_sitters_images_handler/pickImageForPetSitter.dart';
// //import 'package:petsitter/feedbacks_handler/review_card.dart'; // Import ReviewCard
// import 'package:petsitter/discover_sitters/petSitterProfile.dart'; // Import PetSitterProfile

// class FavoriteProfileCard extends StatelessWidget {
//   final DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot;

//   FavoriteProfileCard({required this.petSitterSnapshot});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(8),
//         leading: CircleAvatar(
//           backgroundImage: NetworkImage(petSitterSnapshot['image']),
//           radius: 30,
//         ),
//         title: Text(
//           petSitterSnapshot['name'],
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(petSitterSnapshot['city']),
//         trailing: IconButton(
//           icon: Icon(Icons.delete),
//           onPressed: () {
//             currentUserDataService.UserDataService().removeFavoriteDocument(petSitterSnapshot.reference);
//           },
//         ),
//         onTap: () {
//           // Navigate to pet sitter profile screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PetSitterProfile(
//                 petSitterId: petSitterSnapshot.id,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
