import 'package:chattappe/pages/service/database.dart';
import 'package:chattappe/pages/service/shared_prefi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_pae.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  late Stream ChatRoomStream = Stream.empty(); // Initialize with an empty stream

  getthesharedpref() async {
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    ChatRoomStream = await DatabaseMethods().getCharooms();
    setState(() {});
  }

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: ChatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return ChatRoomListTileStatefulWidget(
              lastMessage: ds["lastMessage"],
              chatRoomId: ds.id,
              myUsername: myUserName!,
              time: ds["lastMessageSendTs"],
            );
          },
        )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  void initiateSearch(String value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
    } else {
      setState(() {
        search = true;
      });

      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        setState(() {
          queryResultSet.clear();
          tempSearchStore.clear();
          for (int i = 0; i < docs.docs.length; ++i) {
            queryResultSet.add(docs.docs[i].data());
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF553370),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                    child: TextField(
                      onChanged: (value) {
                        initiateSearch(value);
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search User",
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      : const Text(
                    "ChatUp",
                    style: TextStyle(
                      color: Color(0xffc199cd),
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        search = true; // Toggle search value
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3e2144),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: search
                          ? GestureDetector(
                        onTap: () {
                          setState(() {
                            search = false;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Color(0xffc199cd),
                        ),
                      )
                          : Icon(
                        Icons.search,
                        color: Color(0xffc199cd),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: search
                      ? MediaQuery.of(context).size.height / 1.19
                      : MediaQuery.of(context).size.height / 1.14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      search
                          ? ListView.builder(
                        padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                        primary: false,
                        shrinkWrap: true,
                        itemCount: tempSearchStore.length,
                        itemBuilder: (context, index) {
                          return buildResultCard(tempSearchStore[index]);
                        },
                      )
                          : ChatRoomList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          search = false; // Close the search field
        });

        // Create chat room
        var chatRoomId = getChatRoomIdbyUsername(myUserName!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        // Navigate to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: data["Name"],
              profileurl: data["photo"],
              username: data["username"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(data["photo"], height: 50, width: 50, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      data["username"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTileStatefulWidget extends StatefulWidget {
  final String chatRoomId;
  final String lastMessage;
  final String myUsername;
  final String time;

  ChatRoomListTileStatefulWidget({
    required this.chatRoomId,
    required this.lastMessage,
    required this.myUsername,
    required this.time,
  });

  @override
  _ChatRoomListTileStatefulWidgetState createState() => _ChatRoomListTileStatefulWidgetState();
}

class _ChatRoomListTileStatefulWidgetState extends State<ChatRoomListTileStatefulWidget> {
  String profilePicUrl = "";
  String name = "";

  @override
  void initState() {
    super.initState();
    getThisUserInfo();
  }

  void getThisUserInfo() async {
    String username = widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username.toUpperCase());
    setState(() {
      name = "${querySnapshot.docs[0]["Name"]}";
      profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profilePicUrl.isEmpty) {
      return CircularProgressIndicator(); // Show progress indicator while loading
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                profilePicUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w500),
                ),
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: Text(
                    widget.lastMessage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black45, fontSize: 15.0, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              widget.time,
              style: TextStyle(color: Colors.black45, fontSize: 10.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
  }
}
