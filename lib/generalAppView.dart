import 'package:flutter/material.dart';
import 'package:petsitter/tempFiles/favorites.dart';
import 'package:petsitter/tempFiles/recentlyViewed.dart';
import 'package:petsitter/discover_sitters/exploreScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralAppPage extends StatefulWidget {
  @override
  _GeneralAppPageState createState() => _GeneralAppPageState();
}

class _GeneralAppPageState extends State<GeneralAppPage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    ExploreScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Text(
          'Pet Sitter',
          style: GoogleFonts.pacifico(
              fontSize: 50, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Perform logout action here
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Screen 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Screen 2',
          ),
        ],
      ),
    );
  }
}
