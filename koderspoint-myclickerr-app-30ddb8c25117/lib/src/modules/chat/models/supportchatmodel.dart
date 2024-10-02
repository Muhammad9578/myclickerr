import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_constants.dart';

class SupportMessageChat {
  String sentby;

  var timestamp;
  String content;

  SupportMessageChat(
      {required this.timestamp, required this.content, required this.sentby});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.sentby: sentby
    };
  }

  factory SupportMessageChat.fromDocument(DocumentSnapshot doc) {
    var timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    String sentby = doc.get(FirestoreConstants.sentby);
    return SupportMessageChat(
      sentby: sentby,
      timestamp: timestamp,
      content: content,
    );
  }
}

class SupportChatScreenArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  SupportChatScreenArguments({
    required this.peerId,
    required this.peerAvatar,
    required this.peerNickname,
  });
}
