import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'petSitterCard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:country_state_city/country_state_city.dart'
    as country_state_city;
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCity = ''; // Variable to hold the selected city
  String selectedDistrict = ''; // Variable to hold the selected district


  @override
void initState() {
  super.initState();
  _getUserCity().then((city) {
    setState(() {
      selectedCity = city;
    });
  });
}





  Future<String> _getUserCity() async {
    return UserDataService().getUserCity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Find Pet Sitters Nearby You!',
          style: GoogleFonts.lora(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FutureBuilder<Widget>(
              //   future: _buildCityDropdown(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircularProgressIndicator();
              //     }
              //     if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     }
              //     return snapshot.data!;
              //   },
              // ),
              _buildCityAutocomplete(),
              SizedBox(height: 16),
              _buildPetSitterCards(), // Method to build the pet sitter cards
            ],
          ),
        ),
      ),
    );
  }

  Future<List<country_state_city.City>> _fetchCities(String pattern) async {
    return country_state_city.getCountryCities('IL').then(
      (cities) {
        return cities
            .where((city) =>
                city.name.toLowerCase().startsWith(pattern.toLowerCase()))
            .toList();
      },
    );
  }

  Widget _buildCityAutocomplete() {
    return FutureBuilder<List<country_state_city.City>>(
      future: _fetchCities(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No cities found.');
        } else {
          return AutoCompleteTextField<country_state_city.City>(
            key: GlobalKey(),
            clearOnSubmit: false,
            suggestions: snapshot.data!,
            itemBuilder: (context, suggestion) {
              final city = suggestion as country_state_city.City;
              return ListTile(
                title: Text(city.name),
              );
            },
            itemSorter: (a, b) => (a as country_state_city.City)
                .name
                .compareTo((b as country_state_city.City).name),
            itemFilter: (suggestion, input) =>
                (suggestion as country_state_city.City)
                    .name
                    .toLowerCase()
                    .contains(input.toLowerCase()),
            itemSubmitted: (suggestion) {
              setState(() {
                selectedCity = (suggestion as country_state_city.City).name;

              });
            },
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: selectedCity, // Display the selected city
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 1), // Adjust horizontal padding
              isDense: true, // Reduce overall height
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          );
        }
      },
    );
  }

// Future<Widget> _buildCityDropdown() async{
//   List<String> cities = await country_state_city.getCountryCities('IL')
//     .then((cities) => cities.map((city) => city.name).toList());
//   return Center(
//     child: SizedBox(
//       width: 280,
//       height: 35.0,
//       child: DropdownButtonFormField(
//         value: selectedCity,
//         items: cities.map((city) {
//           return DropdownMenuItem(
//             value: city,
//             child: Text(city),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             selectedCity = value!;
//           });
//         },
//         decoration: InputDecoration(
//           labelText: 'Select your city',
//           prefixIcon: Icon(Icons.search),
//           contentPadding: EdgeInsets.symmetric(horizontal: 1), // Adjust horizontal padding
//           isDense: true, // Reduce overall height
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//           ),
//         ),
//       ),
//     ),
//   );
// }

Widget _buildPetSitterCards() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
      .collection('city_district_mapping')
      .orderBy('city')
      .where('city', isEqualTo: selectedCity)
      .snapshots(),

    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
        
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      var districtData = snapshot.data?.docs;
      if (districtData == null || districtData.isEmpty) {
        return Text('no pet sitters near your area.');
      }

      var district = districtData[0]['district'];

      return StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('petSitters')
          .orderBy('district')
          .where('district', isEqualTo: district)
          .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var petSitters = snapshot.data?.docs;
          if (petSitters == null || petSitters.isEmpty) {
            return Text('no pet sitters near your area.');
          }

          return GridView.builder(
            //scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: petSitters.length,
            itemBuilder: (context, index) {
              var petSitter = petSitters[index];
              var petSitterPets = petSitter['pets'];
              String petType = getPetTypeFromList(petSitterPets);
              return PetSitterCard(
                name: petSitter['name'],
                petType: petType,
                city: petSitter['city'],
                email: petSitter['email'],
                imagePath: petSitter['image'],
              // details: petSitter['details'],
            );
          },
        );
      },
    );
  }
  );
}
}