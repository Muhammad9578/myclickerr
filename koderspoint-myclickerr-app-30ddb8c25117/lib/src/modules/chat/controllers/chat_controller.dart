import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';
import 'package:photo_lab/src/modules/chat/models/models.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatController(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> getSupportChatStream(String userid, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons.toLowerCase())
        .collection(FirestoreConstants.chats)
        .doc(userid)
        .collection(FirestoreConstants.messages)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(
      String content,
      int type,
      String groupChatId,
      String currentUserId,
      String peerId,
      String roomId,
      String peerUserId,
      CustomOrder customorderdetail,
      String customorderdocumentid) {
    print("inside send message: ${firebaseFirestore.settings}");
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
        idFrom: currentUserId,
        idTo: peerId,
        //timestamp: Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch),
        timestamp: FieldValue.serverTimestamp(),
        content: content,
        roomId: roomId,
        type: type,
        customorderdocumentid: customorderdocumentid,
        customorderdetails: customorderdetail.toJson());
    //Map<String, dynamic> messageMap = messageChat.toJson();
    //messageMap['timestamp'] = FieldValue.serverTimestamp();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    }).then((value) {
      firebaseFirestore
          .collection(FirestoreConstants.pathRoomsCollection)
          .doc(roomId)
          .update({
        FirestoreConstants.lastMessage: content,
        FirestoreConstants.lastMessageType: type,
        FirestoreConstants.dateTime: DateTime.now().millisecondsSinceEpoch
      });
    });
    // print("peerUserId: before notification send: ${peerUserId}");
    sendNotification(prefs.getString(FirestoreConstants.userId)!, peerUserId);
  }

  void sendNotification(String fromUserId, String toUserId) async {
    try {
      Response response =
          await Dio().post(ApiClient.newMessageNotificationUrl, data: {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
      });
      if (response.statusCode == 200) {
        //final jsonData = response.data;
        // print(jsonData);
      }
    } catch (e) {
      // print(e);
    }
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
  static const customOrder = 3;
}
