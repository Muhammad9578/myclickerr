import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_lab/src/helpers/constants.dart';

import '../constants/firestore_constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_constants.dart';

class CustomOrder {
  String photographerId;
  String roomid;
  String? userId;
  double orderTotalPrice;
  int orderTotalHours;
  String orderDescription;
  Map<String, dynamic>? orderPhotographerDetails;
  String orderStatus;
  String orderCreatedTimestamp;
  String? groupChatId;
  String? documentReference;

  CustomOrder({
    required this.photographerId,
    required this.userId,
    required this.roomid,
    required this.orderCreatedTimestamp,
    required this.orderDescription,
    required this.orderStatus,
    this.orderPhotographerDetails,
    this.groupChatId,
    this.documentReference,
    required this.orderTotalHours,
    required this.orderTotalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFromOrder: this.photographerId,
      FirestoreConstants.idToOrder: this.userId,
      FirestoreConstants.roomid: this.roomid,
      FirestoreConstants.orderTotalPrice: this.orderTotalPrice,
      FirestoreConstants.orderTotalHours: this.orderTotalHours,
      FirestoreConstants.orderDescription: this.orderDescription,
      FirestoreConstants.orderStatus: this.orderStatus,
      FirestoreConstants.orderPhotographer: this.orderPhotographerDetails,
      FirestoreConstants.orderCreatedTimestamp: this.orderCreatedTimestamp,
    };
  }

  factory CustomOrder.fromDocument(DocumentSnapshot doc) {
    String photographerId = doc.get(FirestoreConstants.idFromOrder);
    String roomid = doc.get(FirestoreConstants.roomid);

    double orderTotalPrice = doc.get(FirestoreConstants.orderTotalPrice);
    int orderTotalHours = doc.get(FirestoreConstants.orderTotalHours);
    String orderDescription = doc.get(FirestoreConstants.orderDescription);
    String orderCreatedTimestamp =
        doc.get(FirestoreConstants.orderCreatedTimestamp);

    String orderStatus;
    if (doc.get(FirestoreConstants.orderStatus).runtimeType == bool) {
      orderStatus = 'Withdrawn';
    } else {
      orderStatus = doc.get(FirestoreConstants.orderStatus);
    }

    bool contains = (doc.data() as Map<String, dynamic>)
        .containsKey(FirestoreConstants.orderPhotographer);
    Map<String, dynamic>? orderPhotographer;
    if (contains) {
      if (doc.get(FirestoreConstants.orderPhotographer) != null) {
        orderPhotographer = doc.get(FirestoreConstants.orderPhotographer);
      } else {
        orderPhotographer = null;
      }
    }

    contains = (doc.data() as Map<String, dynamic>)
        .containsKey(FirestoreConstants.idToOrder);
    String? userId;
    if (contains) {
      if (doc.get(FirestoreConstants.idToOrder) != null) {
        userId = doc.get(FirestoreConstants.idToOrder);
      } else {
        userId = null;
      }
    }

    return CustomOrder(
      photographerId: photographerId,
      roomid: roomid,
      userId: userId,
      orderCreatedTimestamp: orderCreatedTimestamp,
      orderDescription: orderDescription,
      orderStatus: orderStatus,
      orderPhotographerDetails: orderPhotographer,
      orderTotalHours: orderTotalHours,
      orderTotalPrice: orderTotalPrice,
    );
  }

  factory CustomOrder.fromMap(Map<String, dynamic> map) {
    return CustomOrder(
      photographerId: map[FirestoreConstants.idFromOrder],
      roomid: map[FirestoreConstants.roomid],
      userId: map[FirestoreConstants.idToOrder],
      orderCreatedTimestamp: map[FirestoreConstants.orderCreatedTimestamp],
      orderDescription: map[FirestoreConstants.orderDescription],
      orderStatus: map[FirestoreConstants.orderStatus],
      orderPhotographerDetails: map[FirestoreConstants.orderPhotographer],
      orderTotalHours: map[FirestoreConstants.orderTotalHours],
      orderTotalPrice: map[FirestoreConstants.orderTotalPrice],
    );
  }
}
