// import 'package:flutter/material.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// class Utils {
//   static void showAdditionalQuestionsPopup(BuildContext context) {
//     TextEditingController genderController = TextEditingController();
//     TextEditingController phoneNumberController = TextEditingController();
//     List<String> selectedPets = [];

//     // Store the validated phone number
//     // PhoneNumber? validatedPhoneNumber;
//     String? validatedPhoneNumber;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Additional needed information'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Question 1: Gender
//               DropdownButtonFormField<String>(
//                 value: null,
//                 hint: Text('Select Gender'),
//                 onChanged: (value) {
//                   // Handle gender selection
//                 },
//                 items: ['Male', 'Female', 'Other']
//                     .map<DropdownMenuItem<String>>((String gender) {
//                   return DropdownMenuItem<String>(
//                     value: gender,
//                     child: Text(gender),
//                   );
//                 }).toList(),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select Gender';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 8.0),
//               // Question 2: Phone Number
//               TextFormField(
//                 controller: phoneNumberController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     print("please enter phone number");
//                     return 'Please enter Phone Number';
//                   } else if (!isValidIsraeliMobilePhoneNumber(value)) {
//                     print("Invalid Israeli mobile phone number");
//                     return 'Invalid Israeli mobile phone number';
//                   }
//                   print("null");
//                   return null;
//                 },
//               ),
//               SizedBox(height: 8.0),
//               // Question 3: Pets (Multi-select)
//               MultiSelectDialogField(
//                 items: ['Dogs', 'Cats']
//                     .map((pet) => MultiSelectItem<String>(pet, pet))
//                     .toList(),
//                 initialValue: selectedPets,
//                 onConfirm: (values) {
//                   selectedPets = values;
//                 },
//                 title: Text('Select Pets'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (Form.of(context)!.validate()) {
//                   // Handle submit button press
//                   // Access the answers using controllers:
//                   // genderController.text, phoneNumberController.text, selectedPets
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: Text('Submit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   static bool isValidIsraeliMobilePhoneNumber(String phoneNumber) {
//     // Regular expression to match Israeli mobile phone number format
//     RegExp regex = RegExp(r'^05[0-9]{8}$');
//     return regex.hasMatch(phoneNumber);
//   }
// }
