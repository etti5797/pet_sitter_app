import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:petsitter/pet_sitters_images_handler/pickImageForPetSitter.dart';
import 'package:petsitter/profiles/petSitterProfile.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/services/PetSitterService.dart';
import '../utils/connectivityUtil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
            backgroundImage: widget.petSitterSnapshot.data()!.containsKey('photoUrl') && widget.petSitterSnapshot['photoUrl'] != ''
                                      ? NetworkImage(widget.petSitterSnapshot['photoUrl'])
                                      : AssetImage(widget.petSitterSnapshot['image']) as ImageProvider<Object>?,
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
              showFeedbackDialog(context);
            },
          ),
        ),
      ),
    );
  }

void showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final TextEditingController feedbackController = TextEditingController();
      double rating = 0;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(
              child: Text(
                'Leave a review',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Rating*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Center(
                  child: RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30, // Adjust the size as per your requirement
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (newRating) {
                      setState(() {
                        rating = newRating;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Feedback*',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: feedbackController,
                    maxLength: 100,
                    maxLines: 3, // Enable multiline input
                    decoration: InputDecoration(
                      hintText: 'Enter your feedback',
                      border: InputBorder.none, // Remove the default border
                      contentPadding: EdgeInsets.all(8), // Adjust padding
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0.0), // Adjust the left padding as per your requirement
                  child: Row(
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
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // Handle submit feedback here
                  bool isConnected = await ConnectivityUtil.checkConnectivity(context);
                  if (isConnected) {
                    String currentUserEmail = await UserDataService().getUserEmail();
                    String feedback = feedbackController.text.trim(); // Trim whitespace
                    if (feedback.isNotEmpty && rating > 0) {
                      // Check if feedback is not empty
                      PetSitterService().addReview(email, feedback, isAnonymous, rating);
                      isAnonymous = false;
                      setState(() {
                        feedbackController.clear();
                      });
                      Navigator.of(context).pop();
                    } else {
                      if(rating == 0)
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Rating cannot be empty!"),
                          ),
                        );
                      }
                      else
                      {
                        // Show a message indicating that feedback cannot be empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Feedback cannot be empty! Enter some text."),
                          ),
                        );
                      }
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
}

}
