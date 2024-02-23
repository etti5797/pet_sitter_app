import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/utils.dart';
// import 'package:country_state_city/country_state_city.dart' as country_state_city;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:csc_picker/csc_picker.dart';
import '../signUp/utils.dart' as signUpUtils;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
        });

        // Navigate to home page or any other page
        // after successful sign-up
      }
    } catch (e) {
      // Handle sign-up with Google error
      print('Sign-up with Google error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  String? address = "";

    bool isSpecialUser = false; // Track if the checkbox is selected
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Text(
          'Sign Up',
          style: GoogleFonts.pacifico(
              fontSize: 30, color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Welcome!',
                textAlign: TextAlign.center,
                style: GoogleFonts.amarante(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Utils().buildCircularImage('signUpPageImage.jpg', 100),
              Text(
                'Fill your information to sign up',
                textAlign: TextAlign.center,
                style: GoogleFonts.amarante(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
                CSCPicker(
                  ///Enable disable state dropdown [OPTIONAL PARAMETER]
                  showStates: true,
                  
                  /// Enable disable city drop down [OPTIONAL PARAMETER]
                  showCities: true,

                  ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
                  flagState: CountryFlag.DISABLE,

                  ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
                  dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border:
                      Border.all(color: Colors.grey.shade300, width: 1)),

                  ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
                  disabledDropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey.shade300,
                      border:
                      Border.all(color: Colors.grey.shade300, width: 1)),

                  ///placeholders for dropdown search field
                  countrySearchPlaceholder: "Country",
                  stateSearchPlaceholder: "State",
                  citySearchPlaceholder: "City",

                  ///labels for dropdown
                  countryDropdownLabel: "*Country",
                  stateDropdownLabel: "*State",
                  cityDropdownLabel: "*City",

                  ///Default Country
                  defaultCountry: CscCountry.Israel,

                  ///Disable country dropdown (Note: use it with default country)
                  disableCountry: false,

                  ///Country Filter [OPTIONAL PARAMETER]
                  countryFilter: [CscCountry.Israel],

                  ///selected item style [OPTIONAL PARAMETER]
                  selectedItemStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),

                  ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                  dropdownHeadingStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),

                  ///DropdownDialog Item style [OPTIONAL PARAMETER]
                  dropdownItemStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),

                  ///Dialog box radius [OPTIONAL PARAMETER]
                  dropdownDialogRadius: 10.0,

                  ///Search bar radius [OPTIONAL PARAMETER]
                  searchBarRadius: 10.0,

                  ///triggers once country selected in dropdown
                  onCountryChanged: (value) {
                    setState(() {
                      ///store value in country variable
                      countryValue = value;
                    });
                  },

                  ///triggers once state selected in dropdown
                  onStateChanged: (value) {
                    setState(() {
                      ///store value in state variable
                      stateValue = value;
                    });
                  },

                  ///triggers once city selected in dropdown
                  onCityChanged: (value) {
                    setState(() {
                      ///store value in city variable
                      cityValue = value;
                    });
                  },
                ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: isSpecialUser,
                    onChanged: (value) {
                      setState(() {
                        isSpecialUser = value!;
                        if (isSpecialUser) {
                          signUpUtils.Utils.showAdditionalQuestionsPopup(context);
                        }
                      });
                    },
                  ),
                  Text('I am a pet sitter'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (isSpecialUser) {
                      // Check if the additional questions are answered
                      bool _additionalQuestionsAnswered() {
                        // Add your implementation here
                        return true; // Replace with your logic
                      }
                      if (_additionalQuestionsAnswered()) {
                        _signUpWithGoogle();
                      } else {
                        // Show an error message or prompt the user to answer the questions
                      }
                    } else {
                      _signUpWithGoogle();
                    }
                  }
                },
                child: Text('Sign Up with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
