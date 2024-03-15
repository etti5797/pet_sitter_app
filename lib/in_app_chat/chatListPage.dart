import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsitter/in_app_chat/chats_page.dart';

class ChatsListPage extends StatefulWidget {
  final String userId;

  ChatsListPage({required this.userId});

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  late CollectionReference _messagesCollection;
  late List<DocumentSnapshot> _chats;

  @override
  void initState() {
    super.initState();
    _messagesCollection = FirebaseFirestore.instance.collection('messages');
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      QuerySnapshot snapshot = await _messagesCollection.doc(widget.userId).collection('chat').get();
      setState(() {
        _chats = snapshot.docs;
      });
    } catch (error) {
      print('Error loading chats: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: _chats != null
          ? _chats.isEmpty
              ? Center(
                  child: Text('No chats yet'),
                )
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (BuildContext context, int index) {
                    String otherUserId = _chats[index].id;
                    return ListTile(
                      title: FutureBuilder(
                        future: getUserName(otherUserId),
                        builder: (BuildContext context, AsyncSnapshot<String> userNameSnapshot) {
                          if (userNameSnapshot.connectionState == ConnectionState.waiting) {
                            return Text('Loading...');
                          }
                          if (userNameSnapshot.hasError) {
                            return Text('Error: ${userNameSnapshot.error}');
                          }
                          return Text(userNameSnapshot.data ?? 'Unknown User');
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatWidget(
                              userId: widget.userId,
                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userSnapshot.get('name') as String;
    } catch (error) {
      print('Error fetching user name: $error');
      return 'Unknown User';
    }
  }
}
