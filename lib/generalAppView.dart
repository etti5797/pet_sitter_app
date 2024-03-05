import 'package:flutter/material.dart';
import 'package:petsitter/recently_viewed/recentlyViewedScreen.dart';
import 'package:petsitter/favoritesPage/favorites_screen.dart';
import 'package:petsitter/discover_sitters/exploreScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralAppPage extends StatefulWidget {
  final int initialIndex;

  GeneralAppPage({this.initialIndex = 0});

  @override
  _GeneralAppPageState createState() => _GeneralAppPageState();
}

class _GeneralAppPageState extends State<GeneralAppPage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    ExploreScreen(),
    RecentlyViewedScreen(),
    FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recently viewed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
