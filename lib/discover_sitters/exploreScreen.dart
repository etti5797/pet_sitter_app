import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/utils/connectivityUtil.dart';
import 'petSitterCard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:country_state_city/country_state_city.dart'
    as country_state_city;
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/pet_sitters_images_handler/petSitterPetsFound.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCity = ''; // Variable to hold the selected city
  String selectedDistrict = ''; // Variable to hold the selected district
  bool isConnected = false;
  String selectedPetType = 'Dogs and Cats';
  String selectedGender = 'Any';

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
      resizeToAvoidBottomInset: false,
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
              _buildCityAutocomplete(),
              SizedBox(height: 16),
              _buildFilters(),
              SizedBox(height: 16),
              isConnected
                  ? _buildPetSitterCards()
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<country_state_city.City>> _fetchCities(String pattern) async {
    isConnected = await ConnectivityUtil.checkConnectivity(context);
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
              contentPadding: EdgeInsets.symmetric(horizontal: 1),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedPetType,
            onChanged: (newValue) => setState(() => selectedPetType = newValue!),
            items: [
              DropdownMenuItem(
                value: 'Dogs',
                child: Text('Dogs'),
              ),
              DropdownMenuItem(
                value: 'Cats',
                child: Text('Cats'),
              ),
              DropdownMenuItem(
                value: 'Dogs and Cats',
                child: Text('Dog and Cats'),
              ),
              // ... Similar checks for 'Birds' and 'Others'
            ],
            decoration: InputDecoration(
              labelText: 'Pet Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedGender,
            onChanged: (newValue) => setState(() => selectedGender = newValue!),
            items: [
              DropdownMenuItem(
                value: 'Male',
                child: Text('Male'),
              ),
              DropdownMenuItem(
                value: 'Female',
                child: Text('Female'),
              ),
              DropdownMenuItem(
                value: 'Any',
                child: Text('Any'),
              ),
            ],
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            ),
          ),
        ),
      ],
    );
  }


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

            var petSittersHelper = snapshot.data?.docs;
            if (petSittersHelper == null || petSittersHelper.isEmpty) {
              return Text('no pet sitters near your area.');
            }

            // For Hiba and Etti: This is where you filter the pet sitters based on the selected filters 
            var petSitters = petSittersHelper.where((petSitter) {
              var petSitterData = petSitter.data();
              var petSitterPets = petSitterData['pets'];
              var petSitterGender = petSitterData['gender'];
              return (selectedPetType.isEmpty ||
                      petSitterPets.contains(selectedPetType) || selectedPetType == "Dogs and Cats") &&
                  (selectedGender.isEmpty ||
                      petSitterGender == selectedGender || selectedGender == "Any");
            }).map((petSitter) {
              return petSitter.data();
            }).toList();

            if (petSitters.isEmpty) {
              return Text(
                  'no pet sitters matching your filters near your area.');
            }

            return GridView.builder(
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
                  photoUrl: petSitter['photoUrl'],
                );
              },
            );
          },
        );
      },
    );
  }
}