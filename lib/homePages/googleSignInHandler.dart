import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/signUp/signUpPage.dart';
import '../generalAppView.dart';

class GoogleSignInHandler {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> handleGoogleSignIn(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Show circular loading indicator while sign-in is in progress
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent users from dismissing the dialog
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(googleUser.email).get();
      if (!doc.exists) {
        _googleSignIn.signOut();
        Navigator.pop(context); // Dismiss loading indicator dialog
        showSignUpDialog(
            context, 'You need to sign up before signing in with Google.');
      } else {
        Navigator.pop(context); // Dismiss loading indicator dialog
        Navigator.push(context, MaterialPageRoute(builder: (context) => GeneralAppPage()));
        return true;
      }
    } catch (error) {
      _googleSignIn.signOut();
      print("Got error: ${error.toString()}");
      Navigator.pop(context); // Dismiss loading indicator dialog
      showSignUpDialog(context, 'Got error while signing in with Google');
    }
    return false;
    
    }

  void showSignUpDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to the signup screen
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
