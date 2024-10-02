import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_lab/src/models/event_category.dart';
import 'package:photo_lab/src/models/photographer.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSidePhotographerController extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  List<Photographer>? allPhotographer;
  int totalPhotographerPages = 1;
  int currentLoadingPage = 1;
  bool isLoadingMore = false;

  final RefreshController hirePhotographerScreenRefreshController =
      RefreshController(initialRefresh: false);

  UserSidePhotographerController({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  void getAllPhotographers(
      int userId, double latitude, double longitude, context) async {
    try {
      debugLog(
          "inside fetchData, userId = $userId \nlatitude:$latitude , longitude:$longitude");
      UserController userProvider =
          Provider.of<UserController>(context, listen: false);
      UserBookingController userBookingProvider =
          Provider.of<UserBookingController>(context, listen: false);

      List<Photographer> photographers = [];
      var data = {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude
      };
      Response response;
      try {
        response = await Dio().post(
            "${ApiClient.userHomeUrl}?page=$currentLoadingPage",
            data: data);
      } on DioError catch (e) {
        debugLog(e.message);

        hirePhotographerScreenRefreshController.refreshCompleted();
        Toasty.error('Network Error: ${e.message}');
        return null;
      }

      hirePhotographerScreenRefreshController.refreshCompleted();
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        debugLog(response.data.toString());
        bool status = jsonResponse['status'];

        if (status) {
          //***************** for Photographer **********************
          var dataArray = jsonResponse['data']['data'] as List<dynamic>;
          photographers.clear();
          for (var item in dataArray) {
            photographers.add(Photographer.fromJson(item));
          }
          if (currentLoadingPage == 1 && allPhotographer != null) {
            allPhotographer!.clear();
            allPhotographer = photographers;
          } else if (allPhotographer == null) {
            allPhotographer = photographers;
          } else {
            allPhotographer!.addAll(photographers);
          }

          //***************** for market categories **********************
          var categoriesArray = jsonResponse['categories'] as List<dynamic>;
          categoriesData.clear();
          print("categoriesArray.length: ${categoriesArray.length}");
          // if (categoriesArray.length == 0) {
          //   categoriesArray = [
          //     {
          //       "id": 0,
          //       "category_name": "Event Type",
          //       "status": 1,
          //       "created_at": "2022-12-31T12:25:31.000000Z",
          //       "updated_at": "2022-12-31T12:25:31.000000Z"
          //     },
          //     {
          //       "id": 1,
          //       "category_name": "Wedding",
          //       "status": 1,
          //       "created_at": "2022-12-31T12:25:31.000000Z",
          //       "updated_at": "2022-12-31T12:25:31.000000Z"
          //     },
          //     {
          //       "id": 2,
          //       "category_name": "Engagement",
          //       "status": 1,
          //       "created_at": "2022-12-31T17:01:43.000000Z",
          //       "updated_at": "2022-12-31T17:01:43.000000Z"
          //     },
          //     {
          //       "id": 3,
          //       "category_name": "Bachelor party",
          //       "status": 1,
          //       "created_at": "2022-12-31T17:01:52.000000Z",
          //       "updated_at": "2022-12-31T17:01:52.000000Z"
          //     },
          //     {
          //       "id": 4,
          //       "category_name": "Wedding shower",
          //       "status": 1,
          //       "created_at": "2022-12-31T17:02:10.000000Z",
          //       "updated_at": "2022-12-31T17:02:10.000000Z"
          //     },
          //     {
          //       "id": 5,
          //       "category_name": "PreWedding",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:51:41.000000Z",
          //       "updated_at": "2023-01-04T17:51:41.000000Z"
          //     },
          //     {
          //       "id": 6,
          //       "category_name": "Wedding reception",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:52:52.000000Z",
          //       "updated_at": "2023-01-04T17:52:52.000000Z"
          //     },
          //     {
          //       "id": 7,
          //       "category_name": "Birthday celebration",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:53:40.000000Z",
          //       "updated_at": "2023-01-04T17:53:40.000000Z"
          //     },
          //     {
          //       "id": 8,
          //       "category_name": "Fashion photography",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:54:05.000000Z",
          //       "updated_at": "2023-01-04T17:54:05.000000Z"
          //     },
          //     {
          //       "id": 9,
          //       "category_name": "Housewarming",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:54:47.000000Z",
          //       "updated_at": "2023-01-04T17:54:47.000000Z"
          //     },
          //     {
          //       "id": 10,
          //       "category_name": "Pet photography",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:55:13.000000Z",
          //       "updated_at": "2023-01-04T17:55:13.000000Z"
          //     },
          //     {
          //       "id": 11,
          //       "category_name": "Food photography",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:55:49.000000Z",
          //       "updated_at": "2023-01-04T17:55:49.000000Z"
          //     },
          //     {
          //       "id": 12,
          //       "category_name": "Candid photo shoot",
          //       "status": 1,
          //       "created_at": "2023-01-04T17:56:48.000000Z",
          //       "updated_at": "2023-01-04T17:56:48.000000Z"
          //     }
          //   ];
          // }
          categoriesData.add(EventCategory(0, 'Event Type'));
          categoriesData
              .addAll(categoriesArray.map((e) => EventCategory.fromJson(e)));

          //***************** for unread notifications **********************
          int unreadNotificationCount =
              jsonResponse['unread_notification_count'] as int;
          userProvider.setUnreadNotificationCount(unreadNotificationCount);

          //***************** for pagination **********************
          setTotalPhotographerPages(jsonResponse['data']['last_page'] as int);
          setIsLoadingMore(false);
          userBookingProvider.fetchUserAllBookings(userId);
        } else {
          debugLog('invalid response from api: ${jsonResponse['message']}');
          allPhotographer = [];
          notifyListeners();
          Toasty.error('Error: ${jsonResponse['message']}');
        }
      }
    } catch (e) {
      debugLog(" unknown error in user side fetching photographers: $e");
      Toasty.error('Unknown error occured,');
    }
  }

  setTotalPhotographerPages(totalPages) {
    totalPhotographerPages = totalPages;
    notifyListeners();
  }

  setCurrentLoadingPage(pg) {
    currentLoadingPage = pg;
    notifyListeners();
  }

  setIsLoadingMore(val) {
    isLoadingMore = val;
    notifyListeners();
  }
}
