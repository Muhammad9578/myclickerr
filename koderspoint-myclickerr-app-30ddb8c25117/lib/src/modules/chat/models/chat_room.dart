import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';

import '../../../helpers/utils.dart';

class ChatRoom {
  String id;
  var dateTime;
  String lastMessage;
  int lastMessageType;
  int unreadCounter;
  List<String> users;

  ChatRoom(
      {required this.id,
      required this.dateTime,
      required this.lastMessage,
      required this.lastMessageType,
      required this.unreadCounter,
      required this.users});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.dateTime: dateTime,
      FirestoreConstants.lastMessageType: lastMessageType,
      FirestoreConstants.lastMessage: lastMessage,
      FirestoreConstants.users: users,
    };
  }

  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
    var dateTime;
    String lastMessage = '';
    int lastMessageType = 0;
    List<String> users = [];
    try {
      dateTime = doc.get(FirestoreConstants.dateTime);
    } catch (e) {}
    try {
      lastMessage = doc.get(FirestoreConstants.lastMessage);
    } catch (e) {}
    try {
      lastMessageType = doc.get(FirestoreConstants.lastMessageType);
    } catch (e) {}
    try {
      for (var element in List.from(doc[FirestoreConstants.users])) {
        users.add(element);
      }

      //users = doc.get(FirestoreConstants.users);
    } catch (e) {}

    return ChatRoom(
        id: doc.id,
        lastMessage: lastMessage,
        lastMessageType: lastMessageType,
        dateTime: dateTime,
        users: users,
        unreadCounter: 0);
  }
}

////////////////////
///
///

class ChatRoom1 {
  String id;
  var dateTime;
  String lastMessage;
  int lastMessageType;
  int unreadCounter;
  int supportunreadCounter;
  List<String> users;

  ChatRoom1(
      {required this.id,
      required this.dateTime,
      required this.lastMessage,
      required this.lastMessageType,
      required this.unreadCounter,
      required this.supportunreadCounter,
      required this.users});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.dateTime: dateTime,
      FirestoreConstants.lastMessageType: lastMessageType,
      FirestoreConstants.lastMessage: lastMessage,
      FirestoreConstants.users: users,
    };
  }

  factory ChatRoom1.fromDocument(DocumentSnapshot doc) {
    var dateTime;
    String lastMessage = '';
    int lastMessageType = 0;
    int supportunreadCounter = 0;
    List<String> users = [];
    try {
      dateTime = doc.get(FirestoreConstants.dateTime);
    } catch (e) {
      debugLog(e.toString());
    }
    try {
      supportunreadCounter = doc.get(FirestoreConstants.supportunreadCounter);
    } catch (e) {
      debugLog(e.toString());
    }
    try {
      lastMessage = doc.get(FirestoreConstants.lastMessage);
    } catch (e) {}
    try {
      lastMessageType = doc.get(FirestoreConstants.lastMessageType);
    } catch (e) {}
    try {
      for (var element in List.from(doc[FirestoreConstants.users])) {
        users.add(element);
      }

      //users = doc.get(FirestoreConstants.users);
    } catch (e) {}

    return ChatRoom1(
        id: doc.id,
        lastMessage: lastMessage,
        lastMessageType: lastMessageType,
        dateTime: dateTime,
        users: users,
        supportunreadCounter: supportunreadCounter,
        unreadCounter: 0);
  }
}
