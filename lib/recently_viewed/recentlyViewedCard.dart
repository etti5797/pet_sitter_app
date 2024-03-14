import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/profiles/petSitterProfile.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/services/PetSitterService.dart';
import '../utils/connectivityUtil.dart';


class RecentPetSitterCard extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot;

  RecentPetSitterCard({required this.petSitterSnapshot});

  @override
  _RecentPetSitterCardState createState() => _RecentPetSitterCardState();
}

class _RecentPetSitterCardState extends State<RecentPetSitterCard> {
  late String petSitterName;
  late List<String> petTypes;
  late String email;
  bool isAnonymous = false;

  @override
  void initState() {
    super.initState();
    petSitterName = widget.petSitterSnapshot['name'];
    petTypes = List<String>.from(widget.petSitterSnapshot['pets']);
    email = widget.petSitterSnapshot['email'];
  }

  @override
  Widget build(BuildContext context) {
    String allPets = getPetTypeFromList(petTypes);
    String cityName = widget.petSitterSnapshot['city'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetSitterProfile(
              petSitterId: email,
              onRemove: () {},
            ),
          ),
        );
      },
      child: Card(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          contentPadding: EdgeInsets.all(5),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage:
                Image.asset(widget.petSitterSnapshot['image']).image,
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
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.comment_outlined),
            onPressed: () {
              // Add feedback functionality here
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController feedbackController =
                      TextEditingController();

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text('Feedback'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: feedbackController,
                              maxLength: 100,
                              maxLines: 3, // Enable multiline input
                              decoration: InputDecoration(
                                hintText: 'Enter your feedback',
                              ),
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isAnonymous,
                                  onChanged: (value) {
                                    setState(() {
                                      isAnonymous = value!;
                                    });
                                  },
                                ),
                                Text('Anonymous'),
                              ],
                            ),
                          ],
                        ),
                        actions: [
ElevatedButton(
  onPressed: () async {
    // Handle submit feedback here
    bool isConnected =
        await ConnectivityUtil.checkConnectivity(context);
    if (isConnected) {
      String currentUserEmail =
          await UserDataService().getUserEmail();
      String feedback =
          feedbackController.text.trim(); // Trim whitespace
      if (feedback.isNotEmpty) { // Check if feedback is not empty
        PetSitterService().addReview(
            email, feedback, isAnonymous);
        isAnonymous = false;
        setState(() {
          feedbackController.clear();
        });
        Navigator.of(context).pop();
      } else {
        // Show a message indicating that feedback cannot be empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Feedback cannot be empty! Enter some text."),
          ),
        );
      }
    }
  },
  child: Text('Submit'),
),

                          ElevatedButton(
                            onPressed: () {
                              // Handle cancel feedback here
                              isAnonymous = false;
                              setState(() {
                                feedbackController.clear();
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


// class RecentPetSitterCard extends StatelessWidget {
//   final DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot;

//   RecentPetSitterCard({required this.petSitterSnapshot});

//   var petSitterName;
//   var petTypes;
//   var email;

// @override
// Widget build(BuildContext context) {
//   petSitterName = petSitterSnapshot['name'];
//   petTypes = List<String>.from(petSitterSnapshot['pets']);
//   email = petSitterSnapshot['email'];
//   String allPets = getPetTypeFromList(petTypes);
//   String cityName = petSitterSnapshot['city'];

//   return GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PetSitterProfile(petSitterId: email,
//           onRemove: () {
            
//           },),
//         ),
//       );
//     },
//     child: Card(
//       elevation: 1, // Adjust the elevation value to make the card less prominent
//       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Adjust the margin values to reduce the card size
//       child: ListTile(
//         contentPadding: EdgeInsets.all(5),
//         leading: CircleAvatar(
//           radius: 30,
//           backgroundImage: Image.asset(petSitterSnapshot['image']).image,
//           // backgroundImage: loadRandomImage(allPets).image,
//         ),
//         title: Text(
//           petSitterName,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 2),
//             Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.grey),
//                 SizedBox(width: 4),
//                 Text(
//                   cityName,
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//             // TODO (Hiba): discuss with the team if we should display the pet types in the card
//             // SizedBox(height: 4),
//             // Wrap(
//             //   spacing: 4,
//             //   children: petTypes.map<Widget>((responsibility) {
//             //     return Chip(
//             //       label: Text(responsibility),
//             //       backgroundColor: Colors.blue,
//             //       labelStyle: TextStyle(color: Colors.white),
//             //     );
//             //   }).toList(),
//             // ),
//           ],
//         ),
//         trailing: IconButton(
//           icon: Icon( Icons.comment_outlined/*Icons.add_comment*/),    
//           onPressed: () {
//             // Add feedback functionality here
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 final TextEditingController feedbackController = TextEditingController();

//                 return AlertDialog(
//                   title: Text('Feedback'),
//                   content: TextField(
//                     controller: feedbackController, // Add the controller to the TextField
//                     maxLength: 100,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your feedback',
//                     ),
//                   ),
//                   actions: [
//                     ElevatedButton(
//                       onPressed: () async {
//                         // Handle submit feedback here
//                         bool isConnected = await ConnectivityUtil.checkConnectivity(context);
//                         if(isConnected){
//                         String currentUserEmail = await UserDataService().getUserEmail();
//                         String feedback = feedbackController.text; // Get the text from the controller
//                         PetSitterService().addReview(email, feedback, true);
//                         Navigator.of(context).pop();
//                         }
//                       },
//                       child: Text('Submit'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Handle cancel feedback here
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('Cancel'),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     ),
//   );
// }

// }
