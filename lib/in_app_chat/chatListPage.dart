import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petsitter/in_app_chat/chats_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String? userEmail = _auth.currentUser?.email;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'images/chatsPage.jpg',
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Chats',
                      style: GoogleFonts.lora(
                        fontSize: 50,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatsPage')
                  .where('userId', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final chats = snapshot.data!.docs;
                chats.sort((a, b) {
                  Timestamp timestampA = a['timestamp'];
                  Timestamp timestampB = b['timestamp'];
                  return timestampB.compareTo(timestampA);
                });
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data() as Map<String, dynamic>;
                    final withUserName = chat['nameToBeDisplayed'];
                    final withUserEmail = chat['with'];
                    final lastMessage = chat['lastMessage'];
                    final timestamp = (chat['timestamp'] as Timestamp).toDate();

                    return BubbleListItem(
                      userName: withUserName,
                      lastMessage: lastMessage,
                      timestamp: timestamp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatWidget(
                              userId: userEmail!,
                              otherUserId: withUserEmail,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleListItem extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final DateTime timestamp;
  final VoidCallback onTap;

  const BubbleListItem({
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      subtitle: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 247, 222, 169), // Background color of the bubble
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: $userName',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              lastMessage,
              style: TextStyle(color: Colors.black, fontSize: 20.0),
            ),
            SizedBox(height: 4.0),
            Text(
              DateFormat('dd-MM-yyyy HH:mm').format(timestamp),
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
// import 'package:petsitter/in_app_chat/chats_page.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ChatsListPage extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? userEmail = _auth.currentUser?.email;
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Image.asset(
//                 'images/chatsPage.jpg', // Adjust the path to your image
//                 fit: BoxFit.cover, // Adjust the fit as per your requirement
//               ),
//               Positioned.fill(
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 20, top: 20), // Adjust the padding as desired
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Chats',
//                       style: GoogleFonts.lora(
//                         fontSize: 50,
//                         color: Color.fromARGB(255, 255, 255, 255),
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chatsPage')
//                   .where('userId', isEqualTo: userEmail) // Get current user's ID
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return CircularProgressIndicator();
//                 }
//                 final chats = snapshot.data!.docs;
//                 chats.sort((a, b) {
//                   Timestamp timestampA = a['timestamp'];
//                   Timestamp timestampB = b['timestamp'];
//                   return timestampB.compareTo(timestampA);
//                 });
//                 return ListView.builder(
//                   itemCount: chats.length,
//                   itemBuilder: (context, index) {
//                     final chat = chats[index].data() as Map<String, dynamic>;
//                     final withUserName = chat['nameToBeDisplayed'];
//                     final withUserEmail = chat['with'];
//                     final lastMessage = chat['lastMessage'];
//                     final timestamp = (chat['timestamp'] as Timestamp).toDate();

//                     return ListTile(
//                       title: Text(withUserName),
//                       subtitle: Text(lastMessage),
//                       trailing: Text(DateFormat('dd-MM-yyyy HH:mm').format(timestamp)),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChatWidget(
//                               userId: userEmail!, // Pass the current user's ID
//                               otherUserId: withUserEmail,
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }