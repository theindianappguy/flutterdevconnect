import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  /* searchByName(String searchField) async {
    return await Firestore.instance.collection("users").where("userName",
        isEqualTo: searchField.toLowerCase()).getDocuments();
  }*/

  searchByName(String searchField) {
    return Firestore.instance
        .collection('users')
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  getChatRoomsByUserName(String userName) {
    return Firestore.instance
        .collection('chatRooms')
        .where('users', arrayContains: userName)
        .getDocuments();
  }
}
