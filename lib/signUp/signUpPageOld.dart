// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'utils.dart';
// import 'package:country_state_city/country_state_city.dart' as country_state_city;
// import 'dart:convert';
// import 'package:http/http.dart' as http;


// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final _formKey = GlobalKey<FormState>();
//   String _name = '';
//   String _email = '';
//   String _password = '';

//   Future<void> _signUpWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser!.authentication;

//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential =
//           await _auth.signInWithCredential(credential);
//       final User? user = userCredential.user;

//       if (user != null) {
//         // Save user data to Firestore
//         await _firestore.collection('users').doc(user.uid).set({
//           'name': user.displayName,
//           'email': user.email,
//         });

//         // Navigate to home page or any other page
//         // after successful sign-up
//       }
//     } catch (e) {
//       // Handle sign-up with Google error
//       print('Sign-up with Google error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//   // var countryCities = country_state_city.getCountryCities('IL');
//   String selectedCountryCode = 'IL';

//     bool isSpecialUser = false; // Track if the checkbox is selected
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 201, 160, 106),
//         title: Text(
//           'Sign Up',
//           style: GoogleFonts.pacifico(
//               fontSize: 30, color: const Color.fromARGB(255, 255, 255, 255)),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Text(
//                 'Welcome!',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.amarante(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Utils().buildCircularImage('signUpPageImage.jpg', 100),
//               Text(
//                 'Fill your information to sign up',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.amarante(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _name = value!;
//                 },
//               ),
//               FutureBuilder<List<country_state_city.City>>(
//               future: country_state_city.getCountryCities(selectedCountryCode),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   List<country_state_city.City> cities = snapshot.data!;
//                   return DropdownButton<String>(
//                     value: null, // Set the initial selected city to null
//                     onChanged: (String? newValue) {
//                       // Handle the selected city
//                     },
//                     items: cities
//                         .map<DropdownMenuItem<String>>((country_state_city.City city) {
//                       return DropdownMenuItem<String>(
//                         value: city.name,
//                         child: Text(city.name),
//                       );
//                     }).toList(),
//                   );
//                 }
//               },
//             ),
//               SizedBox(height: 16.0),
//               Row(
//                 children: [
//                   Checkbox(
//                     value: isSpecialUser,
//                     onChanged: (value) {
//                       setState(() {
//                         isSpecialUser = value!;
//                       });
//                     },
//                     checkColor: Color.fromARGB(255, 162, 21, 21), // Set the color of the checkmark
//                   ),
//                   Text('I am a special user'),
//                 ],
//               ),
//               if (isSpecialUser)
//                 ElevatedButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           title: Text('Additional Questions'),
//                           content: Column(
//                             children: [
//                               TextFormField(
//                                 decoration: InputDecoration(labelText: 'Question 1'),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please answer the question';
//                                   }
//                                   return null;
//                                 },
//                                 onSaved: (value) {
//                                   // Save the answer to Firebase
//                                 },
//                               ),
//                               TextFormField(
//                                 decoration: InputDecoration(labelText: 'Question 2'),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please answer the question';
//                                   }
//                                   return null;
//                                 },
//                                 onSaved: (value) {
//                                   // Save the answer to Firebase
//                                 },
//                               ),
//                             ],
//                           ),
//                           actions: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                               child: Text('Cancel'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () {
//                                 // Perform form validation and saving here
//                                 if (_formKey.currentState!.validate()) {
//                                   _formKey.currentState!.save();
//                                   _signUpWithGoogle();
//                                 }
//                                 Navigator.of(context).pop();
//                               },
//                               child: Text('Submit'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   child: Text('Sign Up with Google'),
//                 ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     if (isSpecialUser) {
//                       // Check if the additional questions are answered
//                       bool _additionalQuestionsAnswered() {
//                         // Add your implementation here
//                         return true; // Replace with your logic
//                       }
//                       if (_additionalQuestionsAnswered()) {
//                         _signUpWithGoogle();
//                       } else {
//                         // Show an error message or prompt the user to answer the questions
//                       }
//                     } else {
//                       _signUpWithGoogle();
//                     }
//                   }
//                 },
//                 child: Text('Sign Up with Google'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// }
