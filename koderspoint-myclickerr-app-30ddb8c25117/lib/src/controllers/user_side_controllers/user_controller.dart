import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/modules/chat/constants/firestore_constants.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends ChangeNotifier {
  final SharedPreferences prefs;
  String? userType;
  bool isLoading = false;

  UserController({required this.prefs});

  //User? _loggedInUser;
  int unreadNotificationCount = 0;

  void removeUser() {
    prefs.remove('logged_in_user');
  }

  void setUnreadNotificationCount(int count) {
    this.unreadNotificationCount = count;
    notifyListeners();
  }

  int getUnreadNotificationCount() {
    return unreadNotificationCount;
  }

// void setUser(User user, UserType usertype) {
//   // print("inside setUser user_provider usertype.name: ${usertype.name} ");
//   _loggedInUser = user;
//   prefs.setString('logged_in_user', jsonEncode(user.toJson()));
//   if (usertype.name == 'user') {
//     prefs.setString('userType', "1");
//   } else {
//     prefs.setString('userType', "2");
//   }
//   // prefs.setString('userType', usertype.name);
//   // notifyListeners();
// }
//
// getUserType() {
//   userType = prefs.getString('userType');
//   return userType;
// }
//
// User? getUser() {
//   if (_loggedInUser == null) {
//     String? json = prefs.getString('logged_in_user');
//     // print("json: $json");
//     if (json == null) {
//       return null;
//     }
//     User user = User.fromJson(jsonDecode(prefs.getString('logged_in_user')!),
//         fromSessionClass: true);
//     _loggedInUser = user;
//   }
//   return _loggedInUser;
// }

  void updateProfilefun(String name, String countryCode, String phone, skills,
      shortBio, dynamic data, context, User? loggedInUser) async {
    isLoading = true;
    notifyListeners();
    FormData formData = FormData.fromMap(data);
    Response response =
        await Dio().post(ApiClient.updateProfileUrl, data: formData);

    debugLog(response.data.toString());
    var jsonResponse = response.data;
    if (response.statusCode == 200) {
      bool status = jsonResponse['status'];
      if (status) {
        Toasty.success('Updated Successfully');
        User updatedUser = User.fromJson(jsonResponse['data']);
        isLoading = false;
        notifyListeners();

        SessionHelper.updateUser(
          updatedUser,
          // SessionHelper.userType == "1" ? UserType.user : UserType.photographer
        );
        updateToFirestore(name, loggedInUser);

        profileBasicInfoScreenRefreshController.requestRefresh();
        // print("SessionHelper.userType 2: ${SessionHelper.userType}");
        Navigator.pop(context);
      } else {
        isLoading = false;
        notifyListeners();
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      isLoading = false;
      notifyListeners();
      Toasty.error('Something went wrong');
    }
  }

  updateToFirestore(name, User? loggedInUser) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .get();
      // log('going to find user with this id: ${widget.targetUserId}');

      for (var doc in snapshot.docs) {
        if (loggedInUser!.id == (doc['userId'] ?? '')) {
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.pathUserCollection)
              .doc(doc.id)
              .update({FirestoreConstants.nickname: name});
        }
      }
    } catch (e) {}
  }





}
