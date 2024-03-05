import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/services/CurrentUserDataService.dart'
    as currentUserDataService;
import 'package:petsitter/discover_sitters/petSitterProfile.dart';
import 'package:petsitter/favoritesPage/favorites_screen.dart';
import 'package:petsitter/generalAppView.dart';

class FavoriteCard extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> petSitterSnapshot;
  final VoidCallback? onRemove; // Add the onRemove callback

  FavoriteCard({required this.petSitterSnapshot, this.onRemove});

  @override
  _FavoriteCardState createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  bool isFavorite = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: CircleAvatar(
          backgroundImage: AssetImage(widget.petSitterSnapshot['image']),
          radius: 30,
        ),
        title: Text(
          widget.petSitterSnapshot['name'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.petSitterSnapshot['city']),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () async {
            // Handle favorite toggle logic here
            if (!isFavorite) {
              await currentUserDataService.UserDataService()
                  .addFavoriteDocuments(widget.petSitterSnapshot.reference);
            } else {
              await currentUserDataService.UserDataService()
                  .removeFavoriteDocument(widget.petSitterSnapshot.reference);
            }
            setState(() {
              isFavorite = !isFavorite;
              //Navigator.pop(context);
              Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => GeneralAppPage(initialIndex: 2,)));
            });
            // Trigger the onRemove callback
            // if (widget.onRemove != null) {
            //   widget.onRemove!();
            // }
          },
        ),
        onTap: () {
          // Navigate to pet sitter profile screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetSitterProfile(
                petSitterId: widget.petSitterSnapshot.id,
                onRemove: () {
                  // Trigger the onRemove callback from PetSitterProfile
                  if (widget.onRemove != null) {
                    widget.onRemove!();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
