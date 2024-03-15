import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesCollection = FirebaseFirestore.instance.collection('messages');
    userNameFuture = getUserName(widget.userId);
    otherUserNameFuture = getUserName(widget.otherUserId);
  }

  Future<String> getUserName(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.get('name') as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return Center(
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
                      return Center(
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
                      .limit(20)
                      .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
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
