// import 'package:flutter/material.dart';
// import 'package:petsitter/tempFiles/favorites.dart';
// import 'package:petsitter/tempFiles/recentlyViewed.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bottom App Bar Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _currentIndex = 0;
//   final List<Widget> _screens = [
//     FavoritesScreen(),
//     RecentlyViewedScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bottom App Bar Example'),
//       ),
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.blue,
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Screen 1',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Screen 2',
//           ),
//         ],
//       ),
//     );
//   }
// }
