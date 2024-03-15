import 'package:flutter/material.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'package:petsitter/utils/utils.dart' as utils;
import 'package:petsitter/services/PetSitterService.dart' as petSitterService;
import 'package:petsitter/profiles/LoggedPetSitterProfile.dart';
import 'package:petsitter/generalAppView.dart';
import '../utils/connectivityUtil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

late bool? isPetSitter = null;

class UserProfile extends StatefulWidget {
  UserProfile();

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool isLoading = false;
  String name = '';
  String mail = '';
  String image = '';
  String photoUrl = '';

  TextEditingController _firstNameEditingController = TextEditingController();
  TextEditingController _lastNameEditingController = TextEditingController();

  Future<List<dynamic>> fetchUserData() async {
    name = await UserDataService().getUserName();
    mail = await UserDataService().getUserEmail();
    photoUrl = await UserDataService().getUserPhotoUrl();

    var value =
        await petSitterService.PetSitterService().getPetSitterByEmail(mail);
    if (value != null) {
      isPetSitter = true;
    } else {
      isPetSitter = false;
    }

    List<String> nameParts = name.split(' ');
    _firstNameEditingController.text = nameParts[0];
    _lastNameEditingController.text = nameParts.length > 1 ? nameParts[1] : '';

    return [name, isPetSitter];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              if (!snapshot.data![1]) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              isLoading
                                  ? CircularProgressIndicator()
                                  : CircleAvatar(
                                      radius: 100,
                                      backgroundImage: photoUrl.isNotEmpty
                                          ? NetworkImage(photoUrl)
                                          : AssetImage(
                                                  'images/userProfileImage.jpg')
                                              as ImageProvider<Object>?,
                                      // AssetImage(_petSitterData!['image']),
                                    ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 25.0,
                                ),
                                onPressed: () {
                                  _pickAndUploadProfilePicture();
                                  // Add your logic for changing the picture here
                                },
                              ),
                            ],
                          ),
                          // utils.Utils().buildCircularImageLocal(
                          //     'images/userProfileImage.jpg', 300),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data![0],
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showEditNameDialog(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  // height: 500, // Provide a specific height
                  height: MediaQuery.of(context)
                      .size
                      .height, // Use the full height of the screen
                  width: MediaQuery.of(context)
                      .size
                      .width, // Use the full width of the screen
                  child: LoggedPetSitterProfile(petSitterId: mail),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void showEditNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameEditingController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameEditingController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool isConnected =
                    await ConnectivityUtil.checkConnectivity(context);
                String firstName = _firstNameEditingController.text;
                String lastName = _lastNameEditingController.text;

                if (firstName.isNotEmpty && lastName.isNotEmpty) {
                  String newName = '$firstName $lastName';
                  UserDataService().updateUserName(newName);
                  Navigator.of(context).pop();
                  setState(() {
                    _firstNameEditingController.text = firstName;
                    _lastNameEditingController.text = lastName;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneralAppPage(
                          initialIndex: 3, // Refresh the profile page
                        ),
                      ),
                    );
                  });
                } else {
                  // Show an error message if first name or last name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a full name.'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to pick and upload profile picture
  Future<void> _pickAndUploadProfilePicture() async {
    setState(() {
      isLoading = true;
    });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (mounted && pickedFile == null) {
      setState(() {
        isLoading = false;
      });
    }
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? profilePictureUrl =
          await UserDataService().uploadProfilePicture(imageFile);
      if (profilePictureUrl != null) {
        // Update profile picture URL in Firestore
        await UserDataService().updatePhotoUrl(profilePictureUrl);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
