import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectivityUtil {
  static Future<bool> checkConnectivity(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetSnackBar(context);
      return false;
    }
    return true;
  }


  static Future<bool> checkConnectivityForGoogleAuth(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  static void showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No internet connection.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showNoInternetForGoogleAuthSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No internet connection. Unable to authenticate with Google.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
