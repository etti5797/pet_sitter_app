import 'package:flutter/material.dart';
import 'package:petsitter/homePages/homePageWithLogin';
import 'package:petsitter/recently_viewed/recentlyViewedScreen.dart';
import 'package:petsitter/favoritesPage/favorites_screen.dart';
import 'package:petsitter/discover_sitters/exploreScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petsitter/profiles/RegularUserProfile.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'utils/connectivityUtil.dart';

class GeneralAppPage extends StatefulWidget {
  final int initialIndex;

  GeneralAppPage({this.initialIndex = 0});

  @override
  _GeneralAppPageState createState() => _GeneralAppPageState();
}

class _GeneralAppPageState extends State<GeneralAppPage> {
  int _currentIndex = 0;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final List<Widget> _screens = [
    ExploreScreen(),
    RecentlyViewedScreen(),
    FavoritesScreen(),
    UserProfile(),
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
            onPressed: () async {
              await _googleSignIn.signOut();
              await UserDataService().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomePageWithLogin()));
            },
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: ConnectivityUtil.checkConnectivity(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a loading indicator while checking connectivity
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error if necessary
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == true) {
            // Return the app content when there is internet
            return _screens[_currentIndex];
          } else {
            // Return a widget indicating no internet
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
