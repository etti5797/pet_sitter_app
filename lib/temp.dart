// import 'package:flutter/material.dart';
// import 'package:country_state_cities/country_state_cities.dart';

// class CityDropdown extends StatefulWidget {
//   @override
//   _CityDropdownState createState() => _CityDropdownState();
// }

// class _CityDropdownState extends State<CityDropdown> {
//   String selectedCountryCode = 'US'; // Set the initial country code

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('City Dropdown'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Dropdown button to select a country
//             DropdownButton<String>(
//               value: selectedCountryCode,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedCountryCode = newValue!;
//                 });
//               },
//               items: countries
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),

//             // FutureBuilder to display the cities based on the selected country
//             FutureBuilder<List<City>>(
//               future: getCountryCities(selectedCountryCode),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   List<City> cities = snapshot.data!;
//                   return DropdownButton<String>(
//                     value: null, // Set the initial selected city to null
//                     onChanged: (String? newValue) {
//                       // Handle the selected city
//                     },
//                     items: cities
//                         .map<DropdownMenuItem<String>>((City city) {
//                       return DropdownMenuItem<String>(
//                         value: city.name,
//                         child: Text(city.name),
//                       );
//                     }).toList(),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

