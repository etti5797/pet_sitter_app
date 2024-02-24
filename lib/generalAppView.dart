import 'package:flutter/material.dart';
import 'package:petsitter/tempFiles/favorites.dart';
import 'package:petsitter/tempFiles/recentlyViewed.dart';


class GeneralAppPage extends StatefulWidget {
  @override
  _GeneralAppPageState createState() => _GeneralAppPageState();
}

class _GeneralAppPageState extends State<GeneralAppPage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    FavoritesScreen(),
    RecentlyViewedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Bottom App Bar Example'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
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
