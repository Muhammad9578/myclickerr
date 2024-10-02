import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../helpers/toast.dart';
import '../../helpers/utils.dart';
import '../../models/booking.dart';
import '../../network/api_client.dart';

class UserBookingController extends ChangeNotifier {
  final RefreshController userAllBookingScreenRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController userPreviousBookingScreenRefreshController =
      RefreshController(initialRefresh: false);

  List<Booking>? allBookings;
  List<Booking>? previousBooking;
  bool isLoading = false;
  void fetchUserAllBookings(int userId) async {
    List<Booking> bookings = [];
    List<Booking> historyBookings = [];
    debugLog('inside fetchUserAllBookings userId:$userId');
    Response response;
    try {
      String url = '${ApiClient.userBookingsUrl}/$userId';

      response = await Dio().get(url);
    } on DioError catch (e) {
      debugLog(e.message);
      userAllBookingScreenRefreshController.refreshCompleted();
      userPreviousBookingScreenRefreshController.refreshCompleted();
      Toasty.error('Network Error: ${e.message}');
      return null;
    }
    userAllBookingScreenRefreshController.refreshCompleted();
    userPreviousBookingScreenRefreshController.refreshCompleted();

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];

      if (status) {
        final dataObject = jsonResponse['data'];
        final recentDataArray = dataObject['recent'] as List<dynamic>;
        final historyDataArray = dataObject['history'] as List<dynamic>;
        bookings.addAll(
          recentDataArray.map((e) => Booking.fromJson(e)).toList(),
        );
        historyBookings.addAll(
          historyDataArray.map((e) => Booking.fromJson(e)).toList(),
        );
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    }

    if (allBookings != null) {
      allBookings!.clear();
    }

    if (previousBooking != null) {
      previousBooking!.clear();
    }

    allBookings = bookings;
    previousBooking = historyBookings;

    debugLog("allBookings: ${bookings.length}");
    debugLog("previousBooking: ${historyBookings.length}");

    notifyListeners();
  }

  ///
  ///reschedule booking
  void rescheduleBooking(context, var data, int userid) async {
    isLoading = true;
    notifyListeners();

    debugLog("reschedule booking screen data: $data");
    Response response;
    try {
      response = await Dio().post(ApiClient.rescheduleBookingUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);

      isLoading = false;
      notifyListeners();
      Toasty.error('Network Error:${e.message}');
      return;
    }
    isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        Toasty.success('Booking Rescheduled Successfully');
        isLoading = false;
        notifyListeners();
        context.read<UserBookingController>().fetchUserAllBookings(userid);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        debugLog('Error: ${jsonResponse['message']}');
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      Toasty.error('Something went wrong. Try again later');
    }
  }

  ////give rating to photographer
  void submitPhotographerRating(context, dynamic data, int userid) async {
    isLoading = true;
    notifyListeners();
    Response response;
    try {
      response = await Dio().post(ApiClient.ratePhotographerUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);

      isLoading = false;
      notifyListeners();

      Toasty.error('Network Error:${e.message}');

      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;

      bool status = jsonResponse['status'];
      if (status) {
        Toasty.success('Successful rated.');
        Provider.of<UserBookingController>(context, listen: false)
            .fetchUserAllBookings(userid);

        isLoading = false;
        notifyListeners();
        Navigator.pop(context);
      } else {
        isLoading = false;
        notifyListeners();
        debugLog("failed to rate: $response ");
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      isLoading = false;
      notifyListeners();
      Toasty.error('Something went wrong');
    }
  }
}
