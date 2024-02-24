import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petsitter/homePages/homePageWithLogin' as HomePageWithLogin;
import 'firstView.dart';
import 'secondView.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Text(
          'Pet Sitter',
          style: GoogleFonts.pacifico(
              fontSize: 50, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageIndicatorContainer(
              child: PageView(
                controller: _pageController,
                children: _screens,
              ),
              length: _screens.length,
              indicatorSelectorColor: Colors.blue,
              indicatorColor: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          Container(
            color: const Color.fromARGB(255, 201, 160, 106), // Set the desired color
            child: Row(
              children: [
                SizedBox(width: 20),
                Text('Continue to the app',
                    style: GoogleFonts.abel(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 170),
                IconButton(
                  icon: Icon(Icons.arrow_forward_rounded),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>HomePageWithLogin.HomePageWithLogin()),
                    );
                  },
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}

