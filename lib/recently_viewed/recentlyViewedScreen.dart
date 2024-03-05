import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsitter/recently_viewed/recentlyViewedCard.dart';
import 'package:petsitter/services/CurrentUserDataService.dart' as currentUserDataService;
import 'package:google_fonts/google_fonts.dart';

class RecentlyViewedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'images/recentlyViewedImage.jpeg'), // Replace 'your_image.png' with the actual image path
              Positioned.fill(
                child: Center(
                  child: Text(
                    'Recently\nViewed',
                    style: GoogleFonts.lora(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Align the text to the center
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
              future: currentUserDataService.UserDataService().getRecentlyViewedDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    height: 50, // Specify the desired height
                    width: 50, // Specify the desired width
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recently viewed pet sitters.');
                } else {
                  // Filter out duplicate entries based on email
                  final viewedEmails = <String>{};
                  final uniqueData = <DocumentSnapshot<Map<String, dynamic>>>[];
                  for (final document in snapshot.data!) {
                    final email = document['email'] as String;
                    if (!viewedEmails.contains(email)) {
                      uniqueData.add(document);
                      viewedEmails.add(email);
                    }
                  }
                  return ListView.builder(
                    itemCount: uniqueData.length,
                    itemBuilder: (context, index) {
                      return RecentPetSitterCard(
                        petSitterSnapshot: uniqueData[index],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
