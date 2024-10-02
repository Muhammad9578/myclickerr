import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';

class MessageChat {
  String idFrom;
  String idTo;
  var timestamp;
  String content;
  String? roomId;
  int type;
  String customorderdocumentid;
  Map<String, dynamic> customorderdetails;

  MessageChat({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.roomId,
    required this.type,
    required this.customorderdocumentid,
    required this.customorderdetails,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
      FirestoreConstants.customorderdocumentid: customorderdocumentid,
      FirestoreConstants.roomId: roomId,
      FirestoreConstants.customorderdetail: customorderdetails
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    Map<String, dynamic> customorderdetail =
        doc.get(FirestoreConstants.customorderdetail);
    String customorderdocumentid =
        doc.get(FirestoreConstants.customorderdocumentid);
    var timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    String? roomId;
    try {
      roomId = doc.get(FirestoreConstants.roomId);
    } catch (e) {}
    int type = doc.get(FirestoreConstants.type);
    return MessageChat(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type,
        roomId: roomId,
        customorderdocumentid: customorderdocumentid,
        customorderdetails: customorderdetail);
  }
}
