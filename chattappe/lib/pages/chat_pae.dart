import 'package:chattappe/pages/service/database.dart';
import 'package:chattappe/pages/service/shared_prefi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

import 'home.dart';

class ChatPage extends StatefulWidget {
  final String name, profileurl, username;
  ChatPage({required this.name, required this.profileurl, required this.username});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  late String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  late Stream<QuerySnapshot> messageStream;

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  Future<void> getthesharedpref() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    chatRoomId = getChatRoomIdbyUsername(widget.username, myUserName!);
    await getAndSetMessages();
    setState(() {});
  }

  String getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget ChatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0),
              ),
              color: sendByMe ? Color.fromARGB(255, 234, 236, 240) : Color.fromARGB(255, 211, 228, 243),
            ),
            child: Text(
              message,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
          ),
        )
      ],
    );
  }

  Widget ChatMessage() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages"));
        }
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 90.0, top: 130),
          itemCount: snapshot.data!.docs.length,
          reverse: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            return ChatMessageTile(
              ds["message"],
              myUserName == ds["sendBy"],
            );
          },
        );
      },
    );
  }

  void addMessage(bool sendClicked) {
    if (messageController.text.isNotEmpty) {
      String message = messageController.text;
      messageController.clear();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mna").format(now);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods().addMessage(chatRoomId!, messageId!, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = "";
        }
      });
    }
  }

  Future<void> getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ChatMessage(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                      child: Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xffc199cd)),
                    ),
                    SizedBox(width: 90.0),
                    Text(
                      widget.name,
                      style: TextStyle(color: Color(0xffc199cd), fontSize: 22.0, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                alignment: Alignment.bottomCenter,
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.black45),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            addMessage(true);
                          },
                          child: Icon(Icons.send_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
