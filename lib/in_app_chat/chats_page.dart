import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petsitter/notifications/NotificationHandler.dart';
import 'package:petsitter/services/CurrentUserDataService.dart';
import 'dart:math';
import '../services/AnyUserDataService.dart';
import 'InitialsAvatar.dart';
import 'ImageAvatar.dart';
import 'ProfileAvatarFromImage.dart';
import 'package:bubble/bubble.dart';
import 'package:petsitter/main.dart';

class ChatWidget extends StatefulWidget {
  final String userId; // Unique ID of the current user
  final String otherUserId; // Unique ID of the other user
  final String otherName;
  final String? photoUrl;
  final String? staticImagePath;

  ChatWidget({
    required this.userId,
    required this.otherUserId,
    required this.photoUrl,
    required this.staticImagePath,
    required this.otherName,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late CollectionReference _messagesCollection;
  late Future<String> userNameFuture;
  late Future<String> otherUserNameFuture;
  late String userName; // Instance variable to store user name
  late String otherUserName; // Instance variable to store other user name
  late Image? image;

  // String? photoUrl;
  // String? staticImagePath;
  // String? otherPhotoUrl;
  // String? otherStaticImagePath;

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isSpecialWidgetActive = true;
    _messagesCollection = FirebaseFirestore.instance.collection('messages');
    // userNameFuture = getUserName(widget.userId);
    userNameFuture = UserDataService().getUserName();
    // otherUserNameFuture = getUserName(widget.otherUserId);

    // Assign values to instance variables when futures are resolved
    userNameFuture.then((value) => userName = value);
    // otherUserNameFuture.then((value) => otherUserName = value);

  }

  @override
  void dispose() {
    // Set isSpecialWidgetActive to false when leaving SecondScreen
    isSpecialWidgetActive = false;
    super.dispose();
  }

  Future<String> getUserName(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.get('name') as String;
  }

  @override
  Widget build(BuildContext context) {
    String currentUserMail = widget.userId;
    String senderMail = widget.otherUserId;
    String? staticPhoto = widget.staticImagePath;
    String? photoUrl = widget.photoUrl;

    // Retrieve arguments
    if (widget.userId.isEmpty || widget.otherUserId.isEmpty) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      currentUserMail = args['currentUserMail']!;
      senderMail = args['senderMail']!;
      otherUserName = widget.otherName.isEmpty ? args['senderName']! : widget.otherName;
      staticPhoto = args['staticImagePath'];
      photoUrl = args['photoUrl'];
    }

    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      image = Image.network(widget.photoUrl!);
    } else if (widget.staticImagePath != null &&
        widget.staticImagePath!.isNotEmpty) {
      image = Image.asset(widget.staticImagePath!);
    } else if(photoUrl != null && photoUrl.isNotEmpty) {
      image = Image.network(photoUrl);
    } else if(staticPhoto != null && staticPhoto.isNotEmpty) {
      image = Image.asset(staticPhoto);
    } else {
      image = null;
    }

    if(!widget.otherName.isEmpty) {
      otherUserName = widget.otherName;
    } 

    otherUserNameFuture = getUserName(senderMail);
    
  
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Row(
          children: [
            ((photoUrl != null && photoUrl!.isNotEmpty) ||
                    (staticPhoto != null &&
                        staticPhoto!.isNotEmpty))
                ? ImageAvatar(
                    photoUrl: photoUrl,
                    staticImagePath: staticPhoto,
                    size: 52.0,
                  )
                : InitialsAvatar(
                    firstName: otherUserName.split(' ')[0],
                    lastName: otherUserName.split(' ')[1],
                    size: 52.0,
                  ),
            SizedBox(
                width: 10), // Add some spacing between the avatar and the title
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child:             Text(
              '${otherUserName}',
              style: GoogleFonts.pacifico(
                fontSize: 35,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),),

          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children : [
                    // Background
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('images/chatBackGround.jpg'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
    Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: userNameFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<String> userNameSnapshot) {
                if (userNameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    height: 50, // Specify the desired height
                    width: 50, // Specify the desired width
                    child: CircularProgressIndicator(),
                  );
                }
                if (userNameSnapshot.hasError) {
                  return Text('Error: ${userNameSnapshot.error}');
                }
                return FutureBuilder(
                  future: otherUserNameFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<String> otherUserNameSnapshot) {
                    if (otherUserNameSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        alignment: Alignment.center,
                        height: 50, // Specify the desired height
                        width: 50, // Specify the desired width
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (otherUserNameSnapshot.hasError) {
                      return Text('Error: ${otherUserNameSnapshot.error}');
                    }

                    otherUserName = otherUserNameSnapshot.data ?? 'Other User';

                    return StreamBuilder<QuerySnapshot>(
                      stream: _messagesCollection
                          .doc(currentUserMail)
                          .collection("chat")
                          .doc(senderMail)
                          .collection('private_messages')
                          .orderBy('timestamp', descending: true)
                          .limit(100)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            alignment: Alignment.center,
                            height: 50, // Specify the desired height
                            width: 50, // Specify the desired width
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView(
                          reverse:
                              true, // to show the latest messages at the bottom
                          padding: EdgeInsets.all(8.0),
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            bool isCurrentUser =
                                data['senderId'] == currentUserMail;
                            String senderName = isCurrentUser
                                ? userNameSnapshot.data ?? 'You'
                                : otherUserNameSnapshot.data ?? 'Other User';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  ChatBubble(
                                    message: data['message'],
                                    senderName: senderName,
                                    timestamp: (data['timestamp'] as Timestamp)
                                        .toDate(),
                                    isCurrentUser: isCurrentUser,
                                    image: image,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 2,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ), 
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    // Send message
                    _sendMessage(currentUserMail, senderMail, staticPhoto, photoUrl);
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  void _sendMessage(String currentUserMail, String senderMail, String? staticPhoto, String? photoUrl) async {
    String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      _textEditingController.clear();

      var time = DateTime.now();
      _messagesCollection
          .doc(currentUserMail)
          .collection("chat")
          .doc(senderMail)
          .collection('private_messages')
          .add({
        'senderId': currentUserMail,
        'receiverId': senderMail,
        'message': message,
        'timestamp': time,
      });

      _messagesCollection
          .doc(senderMail)
          .collection("chat")
          .doc(currentUserMail)
          .collection('private_messages')
          .add({
        'senderId': currentUserMail,
        'receiverId': senderMail,
        'message': message,
        'timestamp': time,
      });

      String helper;
      if (message.length > 20) {
        helper = ' ...';
      } else {
        helper = "";
      }

      FirebaseFirestore.instance
          .collection('chatsPage')
          .doc(currentUserMail + "," + senderMail)
          .set({
        'with': senderMail,
        'userId': currentUserMail,
        'lastMessage': message.substring(0, min(20, message.length)) +
            helper, // Take the first 30 characters or the entire message if it's shorter,
        'timestamp': time,
        //'name': recieverName, // "STAMPA ALEXANDRA
        'nameToBeDisplayed': otherUserName,
        'senderId': currentUserMail,
      });

      FirebaseFirestore.instance
          .collection('chatsPage')
          .doc(senderMail + "," + currentUserMail)
          .set({
        'with': currentUserMail,
        'userId': senderMail,
        'lastMessage': message.substring(0, min(20, message.length)) +
            helper, // Take the first 30 characters or the entire message if it's shorter,
        'timestamp': time,
        'nameToBeDisplayed': userName,
        'senderId': currentUserMail,
      });
    }

    String currentUserStaticPhoto = await UserDataService().getUserStaticImagePath();
    String currentUserPhotoUrl = await UserDataService().getUserPhotoUrl();

    String recipientToken =
        await AnyUserDataService().getUserPushToken(senderMail);

    if (recipientToken.isNotEmpty) {
      // Send push notification to the recipient (other user in the chat)
      // (recipientToken, senderName, currentUserMail, message
      sendPushNotification(recipientToken, userName, currentUserMail, currentUserStaticPhoto, currentUserPhotoUrl, message);
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final DateTime timestamp;
  final bool isCurrentUser;
  final Image? image;

  const ChatBubble({
    required this.message,
    required this.senderName,
    required this.timestamp,
    required this.isCurrentUser,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        isCurrentUser
            ? buildCurrentUserBubble(context)
            : buildOtherUserBubble(context),
      ],
    );
  }

  // Widget buildCurrentUserBubble(BuildContext context) {
  //   return Center(
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Center(
  //           child: Text(
  //             textAlign: TextAlign.center,
  //             '${DateFormat('dd-MM-yyyy\nHH:mm').format(timestamp)}',
  //             style: TextStyle(
  //               color: const Color.fromARGB(255, 0, 0, 0),
  //               fontSize: 10.0,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           decoration: BoxDecoration(
  //             color: Color.fromARGB(255, 201, 160, 106),
  //             borderRadius: BorderRadius.circular(8.0),
  //           ),
  //           padding: EdgeInsets.all(8.0),
  //           constraints: BoxConstraints(
  //             minWidth: MediaQuery.of(context).size.width *
  //                 0.4, // Minimum width of the bubble
  //             maxWidth: MediaQuery.of(context).size.width *
  //                 0.7, // Limiting width to 70% of screen width
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'You',
  //                 style: TextStyle(
  //                   color: Color.fromARGB(255, 0, 0, 0),
  //                   fontSize: 12.0,
  //                 ),
  //               ),
  //               SizedBox(height: 6.0),
  //               Text(
  //                 message,
  //                 style: TextStyle(
  //                   fontSize: 16.0,
  //                   color: Color.fromARGB(255, 0, 0, 0),
  //                 ),
  //                 softWrap: true, // Allow text to wrap
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

    Widget buildCurrentUserBubble(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCurrentUser ==
            false) // If the message is not from the current user (i.e. it's from the other user in the chat)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: image == null
                  ? InitialsAvatar(
                      firstName: senderName.split(' ')[0],
                      lastName: senderName.split(' ')[1],
                      size: 30.0,
                    )
                  : ProfileAvatarFromImage(
                      image: image!,
                      size: 30.0,
                    ),
            ),
          ),
        SizedBox(width: 5.0), // Adjust spacing between avatar and message

        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child:         Center(
          child: Text(
            textAlign: TextAlign.center,
            '${DateFormat('dd-MM-yyyy\nHH:mm').format(timestamp)}',
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 10.0,
            ),
          ),
        ),),
                        SizedBox(width: 1.0),
        Bubble(
              alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
    nip: isCurrentUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
    color: isCurrentUser ? Color.fromARGB(255, 201, 160, 106) : Color.fromARGB(255, 247, 222, 169),
          child:        Container(
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Color.fromARGB(255, 201, 160, 106)
                : Color.fromARGB(255, 247, 222, 169),
            borderRadius: BorderRadius.circular(8.0),
          ),
          // padding: EdgeInsets.all(8.0),
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width *
                0.4, // Minimum width of the bubble
            maxWidth: MediaQuery.of(context).size.width *
                0.7, // Limiting width to 70% of screen width
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0),
              Text(
                message,
                style: TextStyle(
                  fontSize: 20.0,
                  color: isCurrentUser
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : Colors.black,
                ),
                softWrap: true, // Allow text to wrap
              ),
            ],
          ),
        ),
        ),
      ],
    );
  }


// Widget buildOtherUserBubble(BuildContext context) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       SizedBox(width: 8.0), // Adjust spacing between avatar and message
//       ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.7,
//         ),
//         child: Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   if (isCurrentUser == false)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: image == null
//                           ? InitialsAvatar(
//                               firstName: senderName.split(' ')[0],
//                               lastName: senderName.split(' ')[1],
//                               size: 40.0,
//                             )
//                           : ProfileAvatarFromImage(
//                               image: image!,
//                             ),
//                     ),
//                   SizedBox(width: 8.0),
//                   Flexible(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: isCurrentUser
//                             ? Color.fromARGB(255, 201, 160, 106)
//                             : Color.fromARGB(255, 247, 222, 169),
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       padding: EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '$senderName',
//                             style: TextStyle(
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                               fontSize: 12.0,
//                             ),
//                           ),
//                           SizedBox(height: 6.0),
//                           Text(
//                             message,
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               color: isCurrentUser
//                                   ? const Color.fromARGB(255, 0, 0, 0)
//                                   : Colors.black,
//                             ),
//                             softWrap: true, // Allow text to wrap
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 6.0),
//               Center(
//                 child: Text(
//                   timestamp != null ? '${DateFormat('dd-MM-yyyy\nHH:mm').format(timestamp!)}' : '',
//                   style: TextStyle(
//                     color: const Color.fromARGB(255, 0, 0, 0),
//                     fontSize: 10.0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
// }

  Widget buildOtherUserBubble(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCurrentUser ==
            false) // If the message is not from the current user (i.e. it's from the other user in the chat)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: image == null
                  ? InitialsAvatar(
                      firstName: senderName.split(' ')[0],
                      lastName: senderName.split(' ')[1],
                      size: 30.0,
                    )
                  : ProfileAvatarFromImage(
                      image: image!,
                      size: 30.0,
                    ),
            ),
          ),
        SizedBox(width: 5.0), // Adjust spacing between avatar and message
        Bubble(
              alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
    nip: isCurrentUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
    color: isCurrentUser ? Color.fromARGB(255, 201, 160, 106) : Color.fromARGB(255, 247, 222, 169),
          child:        Container(
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Color.fromARGB(255, 201, 160, 106)
                : Color.fromARGB(255, 247, 222, 169),
            borderRadius: BorderRadius.circular(8.0),
          ),
          // padding: EdgeInsets.all(8.0),
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width *
                0.4, // Minimum width of the bubble
            maxWidth: MediaQuery.of(context).size.width *
                0.6, // Limiting width to 70% of screen width
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.0),
              Text(
                message,
                style: TextStyle(
                  fontSize: 20.0,
                  color: isCurrentUser
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : Colors.black,
                ),
                softWrap: true, // Allow text to wrap
              ),
            ],
          ),
        ),
        ),
        SizedBox(width: 1.0),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child:         Center(
          child: Text(
            textAlign: TextAlign.center,
            '${DateFormat('dd-MM-yyyy\nHH:mm').format(timestamp)}',
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 10.0,
            ),
          ),
        ),),

      ],
    );
  }
}
