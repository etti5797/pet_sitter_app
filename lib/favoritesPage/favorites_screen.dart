import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/favoritesPage/favorite_profile_card.dart'; // Import FavoriteProfileCard
import 'package:petsitter/services/CurrentUserDataService.dart'
    as currentUserDataService;
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  List<DocumentSnapshot<Map<String, dynamic>>> favoritePetSitters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'images/favorites.jpg',
              ),
              Positioned(
                // top: 0, // Adjust the value to set the distance from the top
                // left: 10,
                // right: 0,
                // bottom: 0,
                child: Center(
                  child: Align(
                    child: Text(
                      '\nFavorites',
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
              child:
                  FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
            future:
                currentUserDataService.UserDataService().getFavoriteDocuments(),
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
                return Text('No favorite pet sitters.');
              } else {
                favoritePetSitters = snapshot.data!;
                return ListView.builder(
                  itemCount: favoritePetSitters.length,
                  itemBuilder: (context, index) {
                    return FavoriteCard(
                      petSitterSnapshot: favoritePetSitters[index],
                      onRemove: () {
                        // Create a copy of the list and modify the copy
                        List<DocumentSnapshot<Map<String, dynamic>>>
                            updatedList = List.from(favoritePetSitters);
                        updatedList.removeAt(index);

                        // Update the state with the modified copy
                        setState(() {
                          favoritePetSitters = updatedList;
                        });
                      },
                    );
                  },
                );
              }
            },
          )),
        ],
      ),
    );
  }
}


// class FavoritesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adjust the sigmaX and sigmaY values for desired blur effect
//                 child: Image.asset(
//                   'images/favorites.PNG',
//                 ),
//               ),
//               Positioned.fill(
//                 child: Center(
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       '\n\n\n\n                   Favorites',
//                       style: GoogleFonts.lora(
//                         fontSize: 30,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
//               future: currentUserDataService.UserDataService().getFavoriteDocuments(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Text('No favorite pet sitters.');
//                 } else {
//                   return ListView.builder(
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       return FavoriteCard( // Use FavoriteProfileCard widget
//                         petSitterSnapshot: snapshot.data![index],
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
