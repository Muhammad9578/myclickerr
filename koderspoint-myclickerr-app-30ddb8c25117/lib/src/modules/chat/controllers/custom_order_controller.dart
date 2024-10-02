import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../network/api_client.dart';
import '../../../helpers/utils.dart';
import '../constants/firestore_constants.dart';
import 'chat_controller.dart';

class CustomOrderController extends ChangeNotifier {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  bool changeStatusLoading = false;

  CustomOrderController(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  void createCustomOrder({
    required context,
    required String roomid,
    required String groupChatId,
    required String photographerId,
    required String userId,
    // required String idToOrder,
    required double orderTotalPrice,
    required int orderTotalHours,
    required String orderDescription,
    required String orderStatus,
    required String orderCreatedTimestamp,
    required Map<String, dynamic> photographerDetails,
    required Function onSendMessage,
  }) {
    try {
      DocumentReference documentReference = firebaseFirestore
          .collection(FirestoreConstants.pathCustomOrderCollection)
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(orderCreatedTimestamp);

      CustomOrder customOrder = CustomOrder(
          roomid: roomid,
          photographerId: photographerId,
          userId: userId,
          orderPhotographerDetails: photographerDetails,
          orderCreatedTimestamp: orderCreatedTimestamp,
          orderDescription: orderDescription,
          orderStatus: orderStatus,
          orderTotalHours: orderTotalHours,
          orderTotalPrice: orderTotalPrice);

      // CustomOrder1 customOrder1 = CustomOrder1(
      //     roomid: roomid,
      //     photographerId: photographerId,
      //     userId: userId,
      //     orderPhotographerDetails: photographerDetails,
      //     orderCreatedTimestamp: orderCreatedTimestamp,
      //     orderDescription: orderDescription,
      //     orderStatus: orderStatus,
      //     orderTotalHours: orderTotalHours,
      //     orderTotalPrice: orderTotalPrice);

      //saving new order in fire-store doc
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          customOrder.toJson(),
        );
      }).then((value) {
        Toasty.success('Custom Order created successfully.');
        setStatusLoader(false);
        // print("Order created successfully: $value");
        onSendMessage('You have a new custom order request.',
            TypeMessage.customOrder, customOrder, orderCreatedTimestamp);

        sendCustomOrderNotificationToUser(
            int.parse(customOrder.userId.toString()),
            customOrder.photographerId,
            'created');
        Future.delayed(Duration(milliseconds: 200), () {
          Navigator.pop(context);
        });
      }).onError((error, stackTrace) {
        // print(
        // "Error in creating custom order, stackTrace: $stackTrace \n Error: ${error}"
        // );
      });
    } catch (e) {
      throw 'Error';
    }
  }

  Stream<QuerySnapshot> getCustomOrder(
      {required String groupChatId, required int limit}) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathCustomOrderCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.orderCreatedTimestamp, descending: true)
        // .limit(limit)
        .snapshots();
  }

  updateCustomOrderStatus(
      {required documentReference,
      required groupChatId,
      required orderStatus}) {
    firebaseFirestore
        .collection(FirestoreConstants.pathCustomOrderCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(documentReference)
        .update({FirestoreConstants.orderStatus: orderStatus}).then((value) {
      setStatusLoader(false);
      Toasty.error('Success');

      // print("order status updated : $documentReference");
    }).catchError((error) {
      setStatusLoader(false);
      Toasty.error('Some error occured.');

      // print("Failed to update order status: $documentReference");
    });
  }

  sendCustomOrderNotificationToPhotographer(
      int userId, photographerId, status) async {
    // print('hi');
    try {
      Response response = await Dio().post(
          '${ApiClient.sendCustomOrderNotificationToPhotographerUrl}',
          data: {
            'user_id': userId.toString(),
            'photographer_id': photographerId.toString(),
            'status': status
          });
      // print(response.data.toString());
      debugLog(response.data);
      if (response.statusCode == 200) {
        var json = response.data;
        debugLog(json);
        bool status = json['status'];
        //String message = json['message'];
        if (status) {
        } else {
          // throw Exception(message);
        }
      } else {
        // error case
        // throw Exception('Status code: ${response.statusCode}');
      }
    } on Exception catch (e) {
      // print(e);
    }
  }

  sendCustomOrderNotificationToUser(int userId, photographerId, status) async {
    // print('hi');
    try {
      Response response = await Dio()
          .post('${ApiClient.sendCustomOrderNotificationToUserUrl}', data: {
        'user_id': userId.toString(),
        'photographer_id': photographerId.toString(),
        'status': status
      });
      // print(response.data.toString());
      debugLog(response.data);
      if (response.statusCode == 200) {
        var json = response.data;
        debugLog(json);
        bool status = json['status'];
        //String message = json['message'];
        if (status) {
        } else {
          // throw Exception(message);
        }
      } else {
        // error case
        // throw Exception('Status code: ${response.statusCode}');
      }
    } on Exception catch (e) {
      // print(e);
    }
  }

  setStatusLoader(val) {
    changeStatusLoading = val;
    notifyListeners();
  }
}
