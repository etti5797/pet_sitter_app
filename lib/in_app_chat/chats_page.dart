import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../utils/connectivityUtil.dart';


class ChatWidget extends StatefulWidget {
  final String userId; // Unique ID of the current user
  final String otherUserId; // Unique ID of the other user

  ChatWidget({required this.userId, required this.otherUserId});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late CollectionReference _messagesCollection;
  late Future<String> userNameFuture;
  late Future<String> otherUserNameFuture;
  late String userName; // Instance variable to store user name
  late String otherUserName; // Instance variable to store other user name

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesCollection = FirebaseFirestore.instance.collection('messages');
    userNameFuture = getUserName(widget.userId);
    otherUserNameFuture = getUserName(widget.otherUserId);

     // Assign values to instance variables when futures are resolved
    userNameFuture.then((value) => userName = value);
    otherUserNameFuture.then((value) => otherUserName = value);
  }

  Future<String> getUserName(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.get('name') as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 160, 106),
        title: Text(
          'Chat',
           style: GoogleFonts.pacifico(
                fontSize: 30,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
        ),
        centerTitle: true,
      ),
      
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: userNameFuture,
              builder: (BuildContext context, AsyncSnapshot<String> userNameSnapshot) {
                if (userNameSnapshot.connectionState == ConnectionState.waiting) {
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
                  builder: (BuildContext context, AsyncSnapshot<String> otherUserNameSnapshot) {
                    if (otherUserNameSnapshot.connectionState == ConnectionState.waiting) {
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

                    return StreamBuilder<QuerySnapshot>(
                      stream: _messagesCollection.doc(widget.userId).collection("chat").doc(widget.otherUserId)
                      .collection('private_messages')
                      .orderBy('timestamp', descending: true)
                      .limit(100)
                      .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                          alignment: Alignment.center,
                          height: 50, // Specify the desired height
                          width: 50, // Specify the desired width
                          child: CircularProgressIndicator(),
                        );
                        }

                        return ListView(
                          reverse: true, // to show the latest messages at the bottom
                          padding: EdgeInsets.all(8.0),
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            bool isCurrentUser = data['senderId'] == widget.userId;
                            String senderName = isCurrentUser
                                ? userNameSnapshot.data ?? 'You'
                                : otherUserNameSnapshot.data ?? 'Other User';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Bubble(
                                    message: data['message'],
                                    senderName: senderName,
                                    timestamp: (data['timestamp'] as Timestamp).toDate(),
                                    isCurrentUser: isCurrentUser,
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
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Send message
                    _sendMessage();

                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      _textEditingController.clear();

      var time = DateTime.now();
      _messagesCollection.doc(widget.userId).collection("chat").doc(widget.otherUserId).collection('private_messages').add({
        'senderId': widget.userId,
        'receiverId': widget.otherUserId,
        'message': message,
        'timestamp': time,
      });

      _messagesCollection.doc(widget.otherUserId).collection("chat").doc(widget.userId).collection('private_messages').add({
        'senderId': widget.userId,
        'receiverId': widget.otherUserId,
        'message': message,
        'timestamp': time,
      });

      String helper;
      if (message.length > 80) {
        helper = ' ...';
      } else {
        helper = "";
      }

      FirebaseFirestore.instance.collection('chatsPage').doc(widget.userId + "," + widget.otherUserId).set({
        'with': widget.otherUserId,
        'userId': widget.userId,
        'lastMessage': message.substring(0, min(80, message.length)) + helper, // Take the first 30 characters or the entire message if it's shorter,
        'timestamp': time,
        //'name': recieverName, // "STAMPA ALEXANDRA
        'nameToBeDisplayed': otherUserName,
      });

      FirebaseFirestore.instance.collection('chatsPage').doc(widget.otherUserId + "," + widget.userId).set({
        'with': widget.userId,
        'userId': widget.otherUserId,
        'lastMessage': message.substring(0, min(80, message.length)) + helper, // Take the first 30 characters or the entire message if it's shorter,
        'timestamp': time,
        'nameToBeDisplayed': userName,
      });
    }
  }
}


class Bubble extends StatelessWidget {
  final String message;
  final String senderName;
  final DateTime timestamp;
  final bool isCurrentUser;

  const Bubble({
    required this.message,
    required this.senderName,
    required this.timestamp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isCurrentUser ? Color.fromARGB(255, 201, 160, 106) : Color.fromARGB(255, 247, 222, 169),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.all(8.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Limiting width to 70% of screen width
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$senderName  ${DateFormat('dd-MM-yyyy HH:mm').format(timestamp)}',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: isCurrentUser ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
                ),
                softWrap: true, // Allow text to wrap
              ),
            ],
          ),
        ),
      ],
    );
  }

}
void showSignUpDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign In Error'),
          content: Text(message),
          actions: [
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
