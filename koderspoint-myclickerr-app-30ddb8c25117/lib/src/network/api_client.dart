import 'package:dio/dio.dart';
import 'package:photo_lab/src/models/notification_model.dart';
import 'package:photo_lab/src/helpers/utils.dart';

class ApiClient {
  // static const baseUrl = 'http://shanzycollection.com/photolab/public/api';
  //static const baseUrl = 'https://tap4trip.com/photolab/public/api';
  // static const baseUrl = 'https://myclickerr.com/photolab/public/api';

  // static const baseUrl = 'https://app.myclickerr.com/api';

  static const baseUrl = 'https://myclickerr.info/public/api';

  //**********************   Auth APIs   ******************
  static const signupUrl = '$baseUrl/signup';
  static const loginUrl = '$baseUrl/login';
  static const updateProfileUrl = '$baseUrl/update-profile';
  static const changePasswordUrl = '$baseUrl/change-password'; // not used
  static const forgotPasswordUrl = '$baseUrl/forgot-password';
  static const resetPasswordUrl = '$baseUrl/reset-password';
  static const logoutUrl = '$baseUrl/logout';
  static const updateFcmTokenUrl = '$baseUrl/update-fcm-token';
  static const deleteAccountUrl = '$baseUrl/delete-account';

  //**********************   User side APIs   ******************
  static const userHomeUrl = '$baseUrl/user-home';
  static const addUserCardUrl =
      '$baseUrl/user-card'; // adding user payment card details
  static const hirePhotographerUrl = '$baseUrl/hire-photographer';
  static const rescheduleBookingUrl = '$baseUrl/reschedule-booking';
  static const userBookingsUrl = '$baseUrl/user-bookings';
  static const confirmPaymentUrl = '$baseUrl/confirm-payment';
  static const deleteBookingUrl = '$baseUrl/delete-booking';
  static const ratePhotographerUrl = '$baseUrl/rate-photographer';
  static const sendCustomOrderNotificationToPhotographerUrl =
      '$baseUrl/send-custom-order-notification-to-photographer';
  static const addPaymentInfoUrl = '$baseUrl/add-payment-info';
  static const instaPaymentUrl = '$baseUrl/insta-payment';

  //**********************   Photographer side APIs   ******************
  static const photographerHomeUrl = '$baseUrl/photographer-home';
  static const photographerBookingHistoryUrl = '$baseUrl/photographer-history';
  static const changeBookingStatusUrl = '$baseUrl/change-booking-status';
  static const deletephotographerUrl = '$baseUrl/delete-account';
  static const photographerUpcomingBookingUrl = '$baseUrl/upcoming-bookings';
  static const photographerHistoryUrl = '$baseUrl/photographer-history';
  static const photographerPendingBookingUrl = '$baseUrl/pending-bookings';
  static const photographerProcessedBookingsUrl = '$baseUrl/processed-bookings';
  static const photographerCompletedBookingsUrl = '$baseUrl/completed-bookings';
  static const addEquipmentUrl = '$baseUrl/add-equipment';
  static const getAllEquipmentUrl = '$baseUrl/all-equipment';
  static const deleteEquipmentUrl = '$baseUrl/delete-equipment';
  static const portfolioUrl = '$baseUrl/portfolio';
  static const resetTimeSlotsUrl = '$baseUrl/update-timeslots-and-availability';
  static const sendCustomOrderNotificationToUserUrl =
      '$baseUrl/send-custom-order-notification-to-user';
  static const photographerSkillsUrl = '$baseUrl/photographer-skills';
  //********************   Shared APIs   *****************

  static const updateBankDetailsUrl = '$baseUrl/update-bank-details';
  static const getBankDetailsUrl = '$baseUrl/get-bank-details';
  static const updateOneSignalIdUrl = '$baseUrl/update-onesignal-id';
  static const newMessageNotificationUrl = '$baseUrl/new-message-notification';
  static const userNotificationsUrl = '$baseUrl/user-notifications';
  static const resetNotificationsCountUrl =
      '$baseUrl/reset-unread-notification-counter';
  static const marketplaceCategoriesUrl = '$baseUrl/marketplace-categories';
  static const marketplaceProductsUrl = '$baseUrl/category-products';
  static const otpArrivalNotificationUrl = '$baseUrl/arrival-notification';

  static void get(String url,
      {required Function(dynamic response) successListener,
      required Function(Exception e) errorListener}) async {
    try {
      Response response = await Dio().get(url);
      //debugLog(response.data.toString());
      if (response.statusCode == 200) {
        successListener(response.data);
      } else {
        errorListener(Exception(
            'Request error with status code: ${response.statusCode}'));
      }
    } on Exception catch (e) {
      debugLog(e);
      errorListener(e);
    }
  }

  static void post(String url, dynamic data,
      {required Function(dynamic response) successListener,
      required Function(Exception e) errorListener}) async {
    try {
      Response response = await Dio().post(url, data: data);
      // print(response.data.toString());
      if (response.statusCode == 200) {
        successListener(response.data);
      } else {
        errorListener(Exception(
            'Request error with status code: ${response.statusCode}'));
      }
    } on Exception catch (e) {
      debugLog(e);
    }
  }

  static Future<CallResponse> resetNotificationCount(int userId) async {
    CallResponse callResponse = new CallResponse();
    // print('hi there');
    try {
      Response response = await Dio()
          .post('$resetNotificationsCountUrl', data: {'user_id': userId});
      // print(response.data.toString());
      debugLog(response.data);
      if (response.statusCode == 200) {
        var json = response.data;
        debugLog(json);
        bool status = json['status'];
        String message = json['message'];
        if (status) {
          callResponse.data = message;
        } else {
          throw Exception(message);
        }
      } else {
        // error case
        throw Exception('Status code: ${response.statusCode}');
      }
    } on Exception catch (e) {
      // print(e);
      callResponse.error = e;
    }

    return callResponse;
  }

  static Future<CallResponse> getUserNotifications(int userId) async {
    CallResponse callResponse = new CallResponse();

    try {
      Response response = await Dio().get('$userNotificationsUrl/$userId');
      if (response.statusCode == 200) {
        var json = response.data;
        var notificationArray = json['data'] as List<dynamic>;

        List<NotificationModel> notificationList = notificationArray
            .map((e) => NotificationModel.fromJson(e))
            .toList();
        callResponse.data = notificationList;
      } else {
        // error case
      }
    } on Exception catch (e) {
      //// print(e);
      callResponse.error = e;
    }

    return callResponse;
  }
}

class CallResponse {
  dynamic data;
  Exception? error;
//String? message;
}
