import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser LoggedInuser;
  final _firestore = Firestore.instance;
  String MessageTxt;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

  }
  void getCurrentUser()async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        LoggedInuser = user;
        print(LoggedInuser.email);
      }
     }
      catch(e){
      print(e);
    }
  }
  void getMessageStream()async {
   await for( var snapshot in _firestore.collection('messages').snapshots()){
     for(var message in snapshot.documents){
       print(message.data);
     }
   }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Center(child: Text('⚡️Chat')),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
               if(snapshot.hasData){
                  final messages = snapshot.data.documents;
                  List<Text> messageWidgets =[];
                for(var message in messages){
                  final msgText = message.data['text'];
                  final msgSender = message.data['Sender'];
                  final msgWidget = Text('$msgText from $msgSender');
                  messageWidgets.add(msgWidget);
                }
                return Column(
                  children: messageWidgets,

                );
               }
              },
             ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        MessageTxt = value ;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'Sender': LoggedInuser.email,
                        'text': MessageTxt,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
