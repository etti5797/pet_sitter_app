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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String? countryValue;
  String? stateValue;
  String? cityValue;
  bool isSpecialUser = false;

  Future<void> _signUpWithGoogle() async {
    // Add your implementation for signing up with Google here
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                showStates: true,
                showCities: true,
                countrySearchPlaceholder: 'Country',
                stateSearchPlaceholder: 'State',
                citySearchPlaceholder: 'City',
                countryDropdownLabel: 'Country',
                stateDropdownLabel: 'State',
                cityDropdownLabel: 'City',
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value;
                  });
                },
                onCityChanged: (value) {
                  setState(() {
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
                  Text('I am a special user'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle sign-up button press
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _signUpWithGoogle();
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
