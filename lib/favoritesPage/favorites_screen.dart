import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/favoritesPage/favorite_profile_card.dart'; // Import FavoriteProfileCard
import 'package:petsitter/services/CurrentUserDataService.dart' as currentUserDataService;
import 'package:google_fonts/google_fonts.dart';


class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'images/favorites.PNG'), 
              Positioned.fill(
                child: Center(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\n\n\n\n                   Favorites',
                      style: GoogleFonts.lora(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
              future: currentUserDataService.UserDataService().getFavoriteDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No favorite pet sitters.');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return FavoriteCard( // Use FavoriteProfileCard widget
                        petSitterSnapshot: snapshot.data![index],
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
