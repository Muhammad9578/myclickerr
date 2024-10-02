import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myclicker_support/Src/Utils/Functions.dart';

import '../Utils/Constants.dart';

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
  static const customOrder = 3;
}

///////////////
///
///

///////////////////
///
///
class MessageChat {
  String sentby;

  var timestamp;
  String content;

  MessageChat(
      {required this.timestamp, required this.content, required this.sentby});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.sentby: sentby
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    var timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    String sentby = doc.get(FirestoreConstants.sentby);
    return MessageChat(
      sentby: sentby,
      timestamp: timestamp,
      content: content,
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String? roomId;

  ChatPageArguments(
      {required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      this.roomId});
}

class ChatRoom {
  String id;
  var dateTime;
  String lastMessage;
  int lastMessageType;
  int unreadCounter;
  int supportunreadCounter;
  List<String> users;

  ChatRoom(
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

  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
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

    return ChatRoom(
        id: doc.id,
        lastMessage: lastMessage,
        lastMessageType: lastMessageType,
        dateTime: dateTime,
        users: users,
        supportunreadCounter: supportunreadCounter,
        unreadCounter: 0);
  }
}

class PopupChoices {
  String title;
  IconData icon;

  PopupChoices({required this.title, required this.icon});
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
