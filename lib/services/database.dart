import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class DatabaseMethods {
  Future<void> addData(userData) async {
    Firestore.instance.collection("users").add(userData).catchError((e) {
      print(e);
    });
  }

  getData() async {
    return Firestore.instance.collection("users").snapshots();
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .getDocuments();
  }

  Future<QuerySnapshot> getRecentUsers() async {
    return await Firestore.instance.collection("users").limit(10).getDocuments();
  }

  Future<bool> addChatRoom(chatRoom, String chatRoomId) async {
    QuerySnapshot blockedSnapshot = await isUserBlocked(chatRoomId);
    print("${blockedSnapshot.toString()} this what we have");
    if (blockedSnapshot.documents.length == 0) {
      Firestore.instance
          .collection("chatRooms")
          .document(chatRoomId)
          .setData(chatRoom)
          .catchError((e) {
        print(e);
      });
      return true;
    } else {
      print("cannot send message");
      return false;
    }
  }

  Future<void> removeChatRoom(String chatRoomId) async {
    Firestore.instance.collection("chatRooms").document(chatRoomId).delete();
    Firestore.instance
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  removeChat({String chatRoomId, String chatId}) {
    Firestore.instance
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .document(chatId)
        .delete();
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  Future<void> addMessage(
      String chatRoomId, messageData, String messageId, chatRoomUpdate) async {
    ///
    Firestore.instance
        .collection("chatRooms")
        .document(chatRoomId)
        .setData(chatRoomUpdate, merge: true)
        .catchError((e) {
      print(e);
    });

    ///
    Firestore.instance
        .collection("chatRooms")
        .document(chatRoomId)
        .collection("chats")
        .document(messageId)
        .setData(messageData)
        .catchError((e) {
      print(e + "ho  ku nahi raha be");
    });
  }

  Future<void> blockUser({@required String userName, @required blockInfo}) {
    return Firestore.instance.collection("blockInfo").add(blockInfo);
  }

  Future<QuerySnapshot> isUserBlocked(String chatId) {
    print("this is the id we are checking at is UserBlocked + $chatId");
    return Firestore.instance
        .collection("blockInfo")
        .where('id', isEqualTo: chatId)
        .getDocuments();
  }

  getUserChats(String itIsMyName) async {
    return Firestore.instance
        .collection("chatRooms")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }
}
