import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petsitter/recently_viewed/recentlyViewedCard.dart';
import 'package:petsitter/services/CurrentUserDataService.dart'
    as currentUserDataService;
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
              future: currentUserDataService.UserDataService()
                  .getRecentlyViewedDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recently viewed pet sitters.');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot =
                          snapshot.data![index];
                      return RecentPetSitterCard(
                          petSitterSnapshot: petSitterSnapshot);
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
