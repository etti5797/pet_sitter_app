import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petsitter/in_app_chat/chats_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petsitter/services/AnyUserDataService.dart';
import 'InitialsAvatar.dart';
import 'ImageAvatar.dart';

import 'package:flutter/material.dart';

String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

class ChatsListPage extends StatefulWidget {
  static const route = '../in_app_chat/chatsListPage';

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  late TextEditingController _searchController;
  late String _userEmail;
  List<DocumentSnapshot> _originalChats = [];
  List<DocumentSnapshot> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 201, 160, 106),
            title: Text(
              'Chats',
              style: GoogleFonts.pacifico(
                  fontSize: 50, color: const Color.fromARGB(255, 255, 255, 255)),
            ),
            centerTitle: true,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatsPage')
                  .where('userId', isEqualTo: _userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final List<DocumentSnapshot> chats = snapshot.data!.docs;
                final List<DocumentSnapshot> sortedChats = List.from(chats);
                sortedChats.sort((a, b) {
                  Timestamp timestampA = a['timestamp'];
                  Timestamp timestampB = b['timestamp'];
                  return timestampB.compareTo(timestampA);
                });

                _originalChats = sortedChats;

                return _buildChatList(sortedChats);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<DocumentSnapshot> chats) {
    _filteredChats = _searchController.text.isEmpty
        ? _originalChats
        : _originalChats.where((chat) {
            final withUserName = chat['nameToBeDisplayed'] as String;
            return withUserName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
          }).toList();

    return _filteredChats.isEmpty
        ? Center(
            child: Text('No chats found'),
          )
        : ListView.builder(
            itemCount: _filteredChats.length,
            itemBuilder: (context, index) {
              final chat = _filteredChats[index].data() as Map<String, dynamic>;
              final withUserName = chat['nameToBeDisplayed'];
              final withUserEmail = chat['with'];
              final lastMessage = chat['lastMessage'];
              final timestamp = (chat['timestamp'] as Timestamp).toDate();
              final lastUserId = chat['senderId'];

              return FutureBuilder<String>(
                future: AnyUserDataService().getUserPhotoUrl(withUserEmail),
                builder: (context, photoUrlSnapshot) {
                  if (photoUrlSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    ); // Placeholder while loading
                  }
                  if (photoUrlSnapshot.hasError) {
                    return Text('Error: ${photoUrlSnapshot.error}');
                  }
                  final photoUrl = photoUrlSnapshot.data;

                  return FutureBuilder<String>(
                    future: AnyUserDataService().getUserStaticImagePath(withUserEmail),
                    builder: (context, staticImagePathSnapshot) {
                      if (staticImagePathSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        ); // Placeholder while loading
                      }
                      if (staticImagePathSnapshot.hasError) {
                        return Text(
                            'Error: ${staticImagePathSnapshot.error}');
                      }
                      final staticImagePath = staticImagePathSnapshot.data;

                      return BubbleListItem(
                        userName: withUserName,
                        photoUrl: photoUrl,
                        staticImagePath: staticImagePath,
                        lastMessage: lastMessage,
                        timestamp: timestamp,
                        lastUserName: lastUserId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatWidget(
                                userId: _userEmail,
                                otherUserId: withUserEmail,
                                photoUrl: photoUrl,
                                staticImagePath: staticImagePath,
                                otherName: withUserName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      _filteredChats.clear();

      if (searchText.isEmpty) {
        _filteredChats.addAll(_originalChats);
      } else {
        _filteredChats.addAll(_originalChats.where((chat) {
          final withUserName = chat['nameToBeDisplayed'] as String;
          return withUserName.toLowerCase().contains(searchText.toLowerCase());
        }));
      }
    });
  }
}



// String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

// class ChatsListPage extends StatelessWidget {
//   static const route = '../in_app_chat/chatsListPage';
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     String? userEmail = _auth.currentUser?.email;
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Column(
//         children: [
//           AppBar(
//             automaticallyImplyLeading: false,
//             backgroundColor: const Color.fromARGB(255, 201, 160, 106),
//             title: Text(
//               'Chats',
//               style: GoogleFonts.pacifico(
//                   fontSize: 50, color: const Color.fromARGB(255, 255, 255, 255)),
//             ),
//             centerTitle: true,
//           ),
          
//           // Stack(
//           //   children: [
//           //     Image.asset(
//           //       'images/chatsPage.jpg',
//           //       fit: BoxFit.cover,
//           //     ),
//           //     Positioned.fill(
//           //       child: Padding(
//           //         padding: EdgeInsets.only(left: 20, top: 20),
//           //         child: Align(
//           //           alignment: Alignment.topLeft,
//           //           child: Text(
//           //             'Chats',
//           //             style: GoogleFonts.lora(
//           //               fontSize: 50,
//           //               color: Color.fromARGB(255, 255, 255, 255),
//           //               fontWeight: FontWeight.bold,
//           //             ),
//           //             textAlign: TextAlign.center,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chatsPage')
//                   .where('userId', isEqualTo: userEmail)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
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
//                     final lastUserId = chat['senderId'];

//                     return FutureBuilder<String>(
//                       future:
//                           AnyUserDataService().getUserPhotoUrl(withUserEmail),
//                       builder: (context, photoUrlSnapshot) {
//                         if (photoUrlSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator(),
//                           ); // Placeholder while loading
//                         }
//                         if (photoUrlSnapshot.hasError) {
//                           return Text('Error: ${photoUrlSnapshot.error}');
//                         }
//                         final photoUrl = photoUrlSnapshot.data;

//                         return FutureBuilder<String>(
//                           future: AnyUserDataService()
//                               .getUserStaticImagePath(withUserEmail),
//                           builder: (context, staticImagePathSnapshot) {
//                             if (staticImagePathSnapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return Center(
//                                 child: CircularProgressIndicator(),
//                               ); // Placeholder while loading
//                             }
//                             if (staticImagePathSnapshot.hasError) {
//                               return Text(
//                                   'Error: ${staticImagePathSnapshot.error}');
//                             }
//                             final staticImagePath =
//                                 staticImagePathSnapshot.data;

//                             return BubbleListItem(
//                               userName: withUserName,
//                               photoUrl: photoUrl,
//                               staticImagePath: staticImagePath,
//                               lastMessage: lastMessage,
//                               timestamp: timestamp,
//                               lastUserName: lastUserId,
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ChatWidget(
//                                       userId: userEmail!,
//                                       otherUserId: withUserEmail,
//                                       photoUrl: photoUrl,
//                                       staticImagePath: staticImagePath,
//                                       otherName: withUserName,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Expanded(
//           //   child: StreamBuilder<QuerySnapshot>(
//           //     stream: FirebaseFirestore.instance
//           //         .collection('chatsPage')
//           //         .where('userId', isEqualTo: userEmail)
//           //         .snapshots(),
//           //     builder: (context, snapshot) {
//           //       if (!snapshot.hasData) {
//           //         return Container(
//           //           alignment: Alignment.center,
//           //           height: 50, // Specify the desired height
//           //           width: 50, // Specify the desired width
//           //           child: CircularProgressIndicator(),
//           //         );
//           //       }
//           //       final chats = snapshot.data!.docs;
//           //       chats.sort((a, b) {
//           //         Timestamp timestampA = a['timestamp'];
//           //         Timestamp timestampB = b['timestamp'];
//           //         return timestampB.compareTo(timestampA);
//           //       });
//           //       return ListView.builder(
//           //         itemCount: chats.length,
//           //         itemBuilder: (context, index) {
//           //           final chat = chats[index].data() as Map<String, dynamic>;
//           //           final withUserName = chat['nameToBeDisplayed'];
//           //           final withUserEmail = chat['with'];
//           //           final lastMessage = chat['lastMessage'];
//           //           final timestamp = (chat['timestamp'] as Timestamp).toDate();

//           //           final staticImagePath = AnyUserDataService().getUserStaticImagePath(withUserEmail);
//           //           final photoUrl = AnyUserDataService().getUserPhotoUrl(withUserEmail);
//           //           // final staticImagePath =  chat['staticImagePath'] == null ? null : chat['staticImagePath'] as String;
//           //           // final photoUrl = chat['photoUrl'] == null ? null : chat['photoUrl'] as String;

//           //           return BubbleListItem(
//           //             userName: withUserName,
//           //             photoUrl: photoUrl,
//           //             staticImagePath: staticImagePath,
//           //             lastMessage: lastMessage,
//           //             timestamp: timestamp,
//           //             onTap: () {
//           //               Navigator.push(
//           //                 context,
//           //                 MaterialPageRoute(
//           //                   builder: (context) => ChatWidget(
//           //                     userId: userEmail!,
//           //                     otherUserId: withUserEmail,
//           //                     photoUrl: photoUrl,
//           //                     staticImagePath: staticImagePath,
//           //                     otherName: withUserName,
//           //                   ),
//           //                 ),
//           //               );
//           //             },
//           //           );
//           //         },
//           //       );
//           //     },
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

class BubbleListItem extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final String? staticImagePath;
  final String lastMessage;
  final DateTime timestamp;
  final String lastUserName;
  final VoidCallback onTap;

  const BubbleListItem({
    required this.userName,
    required this.photoUrl,
    required this.staticImagePath,
    required this.lastMessage,
    required this.timestamp,
    required this.lastUserName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: (photoUrl == null && staticImagePath == null)
          ? InitialsAvatar(
              firstName: userName.split(' ')[0],
              lastName: userName.split(' ')[1],
              size: 55.0,)
          : ImageAvatar(
              photoUrl: photoUrl,
              staticImagePath: staticImagePath,
              size: 55.0,
            ),

      title: Text(
        '$userName',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
                    if (userEmail == lastUserName)
            Icon(
              Icons.done,
              color: Colors.grey,
              size: 20.0,
            ),
          Text(
            lastMessage,
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
          ],),

          SizedBox(height: 4.0),
          Text(
            DateFormat('dd-MM-yyyy HH:mm').format(timestamp),
            style: TextStyle(color: Colors.grey),
          ),
        ],
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