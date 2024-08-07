import 'package:flutter/material.dart';
import 'package:petsitter/profiles/petSitterProfile.dart';

class PetSitterCard extends StatefulWidget {
  final String name;
  final String petType; // Add folderName property
  final String city;
  final String email;
  final String imagePath;
  final String? photoUrl;

  PetSitterCard({Key? key, required this.name, required this.petType, required this.city,
   required this.email, required this.imagePath, required this.photoUrl})
      : super(key: key);

  @override
  _PetSitterCardState createState() => _PetSitterCardState();
}

class _PetSitterCardState extends State<PetSitterCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 232, 192, 164).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetSitterProfile(petSitterId: widget.email, 
                onRemove: null,
              ))
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.photoUrl != null && widget.photoUrl!.isNotEmpty ? NetworkImage(widget.photoUrl!) : Image.asset(widget.imagePath).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.city,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
