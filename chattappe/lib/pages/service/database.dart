import 'package:chattappe/pages/service/shared_prefi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(id).set(userInfoMap);
    } catch (e) {
      print("Error adding user details: $e");
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserByEmail(String email) async {
    try {
      return await FirebaseFirestore.instance.collection("users").where("E-mail", isEqualTo: email).get();
    } catch (e) {
      print("Error getting user by email: $e");
      return FirebaseFirestore.instance.collection("users").where("E-mail", isEqualTo: "").get(); // Return an empty query snapshot
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> search(String username) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .where("SearchKey", isGreaterThanOrEqualTo: username.toUpperCase())
          .where("SearchKey", isLessThan: username.toUpperCase() + 'z')
          .get();
    } catch (e) {
      print("Error searching for user: $e");
      return FirebaseFirestore.instance
          .collection("users")
          .where("SearchKey", isEqualTo: "")
          .get(); // Return an empty query snapshot
    }
  }
  Future<void> createChatRoom(String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).get();
    if (!snapshot.exists) {
      await FirebaseFirestore
          .instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }
  Future addMessage(String chatRoomId,String messageId, Map<String,dynamic> messageInfoMap)async{
    return FirebaseFirestore.
    instance.collection("chatrooms").
    doc(chatRoomId).collection("chats").
    doc(messageId).set(messageInfoMap);

  }
  Future<void> updateLastMessageSend(String chatRoomId, Map<String, dynamic> lastMessageInfoMap) async {
    try {
      final docRef = FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update(lastMessageInfoMap);
      } else {
        print("Document $chatRoomId does not exist.");
        // Handle the case where the document does not exist
      }
    } catch (e) {
      print("Error updating last message: $e");
    }
  }
  Future<Stream<QuerySnapshot>>getChatRoomMessages(chatRoomId)async{
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).collection("chats").orderBy("time",descending: true,).snapshots();

  }
  Future<QuerySnapshot>getUserInfo(String username)async{
    return await FirebaseFirestore.
    instance.collection("users").
    where("username",
        isEqualTo: username).get();

  }
  Future<Stream<QuerySnapshot>>getCharooms()async{
    String? myUsername=await SharedPreferenceHelper().getUserName();
    return
      FirebaseFirestore.instance.
      collection("chatrooms").
      orderBy("time",descending: true,).
      where("users",arrayContains: myUsername!)
      .snapshots();

  }
}
