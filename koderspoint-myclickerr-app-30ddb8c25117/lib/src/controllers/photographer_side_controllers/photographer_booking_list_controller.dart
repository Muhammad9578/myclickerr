import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as au;
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:photo_lab/src/models/booking.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/toast.dart';
import '../../helpers/utils.dart';
import '../../models/photographer_performance_chart.dart';
import '../../models/user.dart';
import '../../network/api_client.dart';
import '../../screens/photographer_screens/p_all_bookings/p_accept_booking_screen.dart';
import '../../screens/shared_screens/profile_selections.dart';
import '../user_side_controllers/u_booking_controller.dart';
import '../user_side_controllers/user_controller.dart';

class PhotographerBookingListController extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final au.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  bool changeStatusLoading = false;

  final RefreshController pActiveBookingRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController pNewRequestBookingRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController pHomeRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController pCompletedBookingRefreshController =
      RefreshController(initialRefresh: false);

  List<Booking>? allBookings;
  List<Booking>? completedBooking;
  List<Booking>? activeBooking;
  List<Booking> pendingBooking = [];
  List<PhotographerChart>? photographerPerformanceChart;

  int totalBookings = 0,
      totalClients = 0,
      totalAcceptedBookings = 0,
      totalRejectedBookings = 0;
  double totalAmountEarned = 0;

  PhotographerBookingListController({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  setPendingBooking(lst) {
    pendingBooking = lst;
    notifyListeners();
  }

  setActiveBooking(lst) {
    activeBooking = lst;
    notifyListeners();
  }

  Future<List<Booking>?> fetchPhotographerBookings(int userId, context) async {
    debugLog("inside fetchUserBooking userId: $userId");
    UserController userProvider =
        Provider.of<UserController>(context, listen: false);
    List<Booking> allBookng = [];
    List<Booking> activeBookng = [];
    List<Booking> pendingBookng = [];
    List<Booking> completedBookng = [];
    List<PhotographerChart> performanceChart = [];
    Response response;
    try {
      response =
          await Dio().get('${ApiClient.photographerHomeUrl}/$userId').timeout(
                Duration(minutes: 2),
              );
    } on DioError catch (e) {
      if (pActiveBookingRefreshController.isRefresh) {
        pActiveBookingRefreshController.refreshCompleted();
      }
      if (pNewRequestBookingRefreshController.isRefresh) {
        pNewRequestBookingRefreshController.refreshCompleted();
      }
      if (pCompletedBookingRefreshController.isRefresh) {
        pCompletedBookingRefreshController.refreshCompleted();
      }
      if (pHomeRefreshController.isRefresh) {
        pHomeRefreshController.refreshCompleted();
      }
      Toasty.error('Network Error: ${e.message}');
      notifyListeners();
      return null;
    }

    if (pActiveBookingRefreshController.isRefresh) {
      pActiveBookingRefreshController.refreshCompleted();
    }
    if (pNewRequestBookingRefreshController.isRefresh) {
      pNewRequestBookingRefreshController.refreshCompleted();
    }
    if (pCompletedBookingRefreshController.isRefresh) {
      pCompletedBookingRefreshController.refreshCompleted();
    }
    if (pHomeRefreshController.isRefresh) {
      pHomeRefreshController.refreshCompleted();
    }
    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      bool status = jsonResponse['status'];

      if (status) {
        //*************** Handling counts ********************
        totalBookings = jsonResponse['data']['total_bookings'];
        totalClients = jsonResponse['data']['total_clients'];
        totalAcceptedBookings = jsonResponse['data']['accepted_bookings'];
        totalRejectedBookings = jsonResponse['data']['rejected_bookings'];

        totalAmountEarned = double.parse(
            jsonResponse['data']['total_amount_earned'].toString());

        //*************** Handling Booking details ********************

        var dataArray = jsonResponse['data']['bookings'] as List<dynamic>;
        for (var item in dataArray) {
          var js = Booking.fromJson(item);
          allBookng.add(js);

          if (js.status == "accepted") {
            activeBookng.add(js);
          }
          if (js.status == "pending") {
            pendingBookng.add(js);
          }
          if (js.status == "rejected" || js.status == "completed") {
            completedBookng.add(js);
          }
        }

        //***************** for unread notifications **********************
        int unreadNotificationCount =
            jsonResponse['data']['unread_notification_count'] as int;
        userProvider.setUnreadNotificationCount(unreadNotificationCount);

        //*************** Handling chart data ********************

        var chartList =
            jsonResponse['data']['earned_amount_graph'] as List<dynamic>;

        for (var item in chartList) {
          var js = PhotographerChart.fromJson(item);
          performanceChart.add(js);
        }
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }

      if (allBookings != null) {
        allBookings!.clear();
      }
      if (completedBooking != null) {
        completedBooking!.clear();
      }
      if (pendingBooking.isEmpty) {
        pendingBooking.clear();
      }
      if (activeBooking != null) {
        activeBooking!.clear();
      }

      allBookings = allBookng;
      completedBooking = completedBookng;
      pendingBooking = pendingBookng;
      activeBooking = activeBookng;

      if (photographerPerformanceChart != null) {
        photographerPerformanceChart!.clear();
      }
      photographerPerformanceChart = performanceChart;

      notifyListeners();
    }

    return allBookng;
  }

  Future<void> p_changeBookingStatus(int bookingId, String bookingStatus,
      int photographerId, BuildContext context,
      {bool fromDetail = true}) async {
    setStatusLoader(true);

    var data = {
      'booking_id': bookingId,
      'status': bookingStatus,
      'rejected_by': photographerId.toString(),
    };
    Response response;
    try {
      response = await Dio().post(ApiClient.changeBookingStatusUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);
      Toasty.error('Network Error:${e.message}');
      setStatusLoader(false);
      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        setStatusLoader(false);
        if (bookingStatus == 'rejected') {
          if (SessionHelper.userType == "1") {
            Toasty.success('Booking is cancelled successfully');
          } else {
            Toasty.success('Booking is rejected successfully');
          }
        } else {
          String msg = bookingStatus;
          Toasty.success('Booking is $msg successfully');
        }

        if (SessionHelper.userType == "1") {
          UserBookingController userBookingProvider =
              Provider.of<UserBookingController>(context, listen: false);
          userBookingProvider.fetchUserAllBookings(photographerId);
          Navigator.pop(context);
        } else {
          fetchPhotographerBookings(photographerId, context);
          // print("fromDetail: ${fromDetail} ,, photographerId: $photographerId");
          // Navigator.pop(context);
          if (fromDetail) {
            Navigator.pop(context);
          }
        }

        /*if (!mounted) {
        return;
      }*/
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
        setStatusLoader(false);
      }
    } else {
      Toasty.error('Something went wrong');
      setStatusLoader(false);
    }
  }

  setStatusLoader(val) {
    changeStatusLoading = val;
    notifyListeners();
  }

  Future acceptBooking(int bookingId, String bookingStatus, int photographerId,
      bkDetail, context) async {
    setStatusLoader(true);
    var data = {
      'booking_id': bookingId,
      'status': bookingStatus,
      'rejected_by': photographerId.toString(),
    };
    Response response;
    try {
      response = await Dio().post(ApiClient.changeBookingStatusUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);
      Toasty.error('Network Error:${e.message}');
      setStatusLoader(false);
      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        //String msg = bookingStatus;

        await fetchPhotographerBookings(photographerId, context);

        Navigator.pushNamed(context, PhotographerAcceptBookingScreen.route,
            arguments: bkDetail);
        pNewRequestBookingRefreshController.requestRefresh();
        setStatusLoader(false);
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
        setStatusLoader(false);
      }
    } else {
      Toasty.error('Something went wrong');
      setStatusLoader(false);
    }
  }

  void deletephotographer(context, User? loggedinuser) async {
    debugLog(loggedinuser!.id.toString());
    setStatusLoader(true);

    Response response;
    try {
      response = await Dio()
          .get('${ApiClient.deletephotographerUrl}/${loggedinuser.id}')
          .timeout(
            Duration(minutes: 2),
          );
    } on DioError catch (e) {
      debugLog(e);
      Toasty.error('Network Error:${e.message}');
      setStatusLoader(false);
      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        //String msg = bookingStatus;

        SessionHelper.removeUser();
        deleteUserAndDocument();

        Navigator.of(context).pushNamedAndRemoveUntil(
            ProfileSelectionScreen.route, (Route<dynamic> route) => false);
        setStatusLoader(false);
        Toasty.success('Account deleted Successfully');
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
        setStatusLoader(false);
      }
    } else {
      Toasty.error('Something went wrong');
      setStatusLoader(false);
    }
    // Future.delayed(Duration(seconds: 5), () {
    //   setStatusLoader(false);
    // });
  }

  Future<void> deleteUserAndDocument() async {
    try {
      au.User? user = firebaseAuth.currentUser;
      if (user != null) {
        // Delete the user account from Firebase Authentication
        await user.delete();

        // Delete the user document from Firestore collection
        await firebaseFirestore
            .collection(FirestoreConstants.users)
            .doc(user.uid)
            .delete();

        print('User account and document deleted successfully.');
      } else {
        print('No user is currently signed in.');
      }
    } catch (error) {
      print('Error deleting user account and document: $error');
    }
  }
}
