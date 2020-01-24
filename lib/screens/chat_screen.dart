import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser LoggedInuser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String MessageTxt;
  final msgtxtController = TextEditingController();

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
                 final messages = snapshot.data.documents.reversed;
                 List<MessageBubble> messageWidgets =[];
                 for(var message in messages){
                   final timenow = message.data['time'];
                   final msgText = message.data['text'];
                   final msgSender = message.data['Sender'];
                   final currentUser = LoggedInuser.email;
                   final msgWidget = MessageBubble(msgText: msgText,msgSender: msgSender,isMe: currentUser == msgSender,time:timenow);
                   messageWidgets.add(msgWidget);
                   messageWidgets.sort((a,b) => b.time.compareTo(a.time));
                 }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.all(10.0),
                    children: messageWidgets,

                  ),
                );
               }
              },
             ),
            Container(
              color: Colors.lightBlueAccent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextField(
                        controller: msgtxtController,
                        onChanged: (value) {
                          MessageTxt = value ;
                        },
                        decoration: InputDecoration(hintStyle: TextStyle(color: Colors.black),hintText: '  Type your message here....',),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.lightBlueAccent,
                    child: RaisedButton(
                      onPressed: () {
                        msgtxtController.clear();
                        _firestore.collection('messages').add({
                          'Sender': LoggedInuser.email,
                          'text': MessageTxt,
                          'time' : DateTime.now(),
                        });
                      },
                      child: Icon(
                        Icons.arrow_forward,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

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

class MessageBubble extends StatelessWidget {
  MessageBubble({this.msgText,this.msgSender,this.isMe,this.time});

  final String msgText;
  final String msgSender;
  final bool isMe;
  final Timestamp time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text('$msgSender ',style: TextStyle(fontSize: 12.0)),
          Material(
              borderRadius: BorderRadius.circular(30.0),
              elevation: 5.0,
              color: isMe? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Text('$msgText',style: TextStyle(fontSize: 20.0,color: isMe? Colors.white : Colors.black),),
          ),
    ),
        ],
      ),
  );

  }
}

