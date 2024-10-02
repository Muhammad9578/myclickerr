import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/bank_account.dart';
import 'package:photo_lab/src/models/photographer_equipment.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_all_bookings/p_accept_booking_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PhotorapherController extends ChangeNotifier {
  bool isLoading = false;
  List<PhotographerEquipment>? equipments = [];
  bool isBookingUpdatedSuccessfully = false;
  int totalPhotographerPages = 1;
  int currentLoadingPage = 1;
  BankAccount? bankAccount;

  ///edit equiopment function
  void editEquipment(
      id, RefreshController photographerEquipmentRefreshController) async {
    isLoading = true;
    notifyListeners();
    // print("userid: $id");
    Response response;
    try {
      String url = '${ApiClient.addEquipmentUrl}/${id}';
      response = await Dio().delete(url);
    } on DioError catch (e) {
      debugLog(e.message);
      isLoading = false;
      notifyListeners();

      photographerEquipmentRefreshController.refreshCompleted();
      Toasty.success('Network Error: ${e.message}');
      return null;
    }

    if (response.statusCode == 200) {
      // print("response: $response");

      var jsonResponse = response.data;
      // print("jsonResponse: ${jsonResponse}");
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];

      if (status) {
        Toasty.success('Equipment deleted.');
        photographerEquipmentRefreshController.requestRefresh();

        isLoading = false;
        notifyListeners();
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    }
  }

  ///
  ///delete equipment function
  ///
  ///
  void deleteEquipment(
      id, RefreshController photographerEquipmentRefreshController) async {
    isLoading = true;
    notifyListeners();
    // print("userid: $id");
    Response response;
    try {
      String url = '${ApiClient.deleteEquipmentUrl}/${id}';
      response = await Dio().delete(url);
    } on DioError catch (e) {
      debugLog(e.message);

      isLoading = false;
      notifyListeners();
      photographerEquipmentRefreshController.refreshCompleted();
      Toasty.success('Network Error: ${e.message}');
      return null;
    }

    if (response.statusCode == 200) {
      // print("response: $response");

      var jsonResponse = response.data;
      // print("jsonResponse: ${jsonResponse}");
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];

      if (status) {
        Toasty.success('Equipment deleted.');
        photographerEquipmentRefreshController.requestRefresh();

        isLoading = false;
        notifyListeners();
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    }
  }

  ///frtch
  ///
  void fetchEquipments(int userId,
      RefreshController photographerEquipmentRefreshController) async {
    List<PhotographerEquipment> equipment = [];
    // print("userid: $userId");
    Response response;
    try {
      isLoading = true;
      notifyListeners();
      String url =
          '${ApiClient.getAllEquipmentUrl}/${userId}?page=$currentLoadingPage';
      response = await Dio().get(url);
    } on DioError catch (e) {
      debugLog(e.message);
      isLoading = false;
      notifyListeners();
      photographerEquipmentRefreshController.refreshCompleted();
      Toasty.error('Network Error: ${e.message}');
      return null;
    }
    isLoading = false;
    notifyListeners();
    photographerEquipmentRefreshController.refreshCompleted();
    if (response.statusCode == 200) {
      // print("response: $response");

      var jsonResponse = response.data;
      // print("jsonResponse: ${jsonResponse}");
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];

      if (status) {
        var dataArray = jsonResponse['data']['data'];
        equipment.clear();
        // print("equipment list length: ${dataArray.length}");
        for (var item in dataArray) {
          equipment.add(PhotographerEquipment.fromJson(item));
        }

        if (currentLoadingPage == 1 && equipments != null) {
          equipments!.clear();
          equipments = equipment;
        } else if (equipments == null) {
          equipments = equipment;
        } else {
          equipments!.addAll(equipment);
        }

        // if (equipments != null) {
        //   equipments!.clear();
        // }
        // equipments = equipment;

        totalPhotographerPages = jsonResponse['data']['last_page'] as int;

        isLoading = false;
        notifyListeners();
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    }
  }

  void changeBookingStatus(context, String bookingId, String bookingStatus,
      String fileLink, int loggedinuserid, int photographerid) async {
    isLoading = true;
    notifyListeners();
    var data = {
      'booking_id': bookingId,
      'status': bookingStatus,
      'file_link': fileLink,
      'rejected_by': loggedinuserid,
    };
    debugLog("dropbox order screen data: $data");
    Response response;
    try {
      response = await Dio().post(ApiClient.changeBookingStatusUrl, data: data);
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
        Toasty.success('uploaded Successfully');
        isBookingUpdatedSuccessfully = true;
        notifyListeners();
        context
            .read<PhotographerBookingListController>()
            .fetchPhotographerBookings(photographerid, context);
        //selectedBooking?.status = bookingStatus;
        /*if (!mounted) {
          return;
        }*/
      } else {
        debugLog('Error: ${jsonResponse['message']}');
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      Toasty.error('Something went wrong');
    }
  }

  void updateBankDetails(
      context, BankAccount bankAccount, loggedinuserid) async {
    isLoading = true;
    notifyListeners();
    var data = {
      'user_id': loggedinuserid,
      'bank_name': bankAccount.bankName,
      'account_number': bankAccount.accountNumber,
      'account_holder_name': bankAccount.accountHolderName,
      'bank_country': bankAccount.country,
    };
    Response response;
    try {
      response = await Dio().post(ApiClient.updateBankDetailsUrl, data: data);

      isLoading = false;
      notifyListeners();
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        debugLog('response: ${response.data}');
        bool status = jsonResponse['status'];

        if (status) {
          //var data = jsonResponse['data'];
          Toasty.success('Bank details updated successfully');
          photographerPaymentInfoRefreshController.requestRefresh();
          Navigator.pop(context);
        } else {
          Toasty.error('Error: ${jsonResponse['message']}');
        }
      }
    } on DioError catch (e) {
      debugLog(e.message);

      isLoading = false;
      notifyListeners();
      Toasty.error('Network Error: ${e.message}');
      return;
    }
  }

  ///
  void addNewEquipment(
      context, equipment, loggedinuserid, name, amountPer, amount) async {
    try {
      var data = {
        "action": equipment != null ? "edit" : "create",
        'user_id': loggedinuserid,
        'equipment_name': name,
        'amount': amountPer == "Day"
            ? amount
            : (double.parse(amount) / 7).toStringAsFixed(1),
        'amount_per': 'day',
      };
      if (equipment != null) {
        data['equipment_id'] = equipment!.id;
      }

      if (AppFunctions.imagepath != '') {
        String fileName = AppFunctions.imagepath.split('/').last;

        data['equipment_photo'] = await MultipartFile.fromFile(
            AppFunctions.imagepath,
            filename: fileName);
      } else {
        File img = await AppFunctions.getFileImage();
        AppFunctions.imagepath = img.path;
        String fileName = AppFunctions.imagepath.split('/').last;

        data['equipment_photo'] = await MultipartFile.fromFile(
            AppFunctions.imagepath,
            filename: fileName);
      }

      debugLog("Add equipemnt details: $data");
      FormData formData = FormData.fromMap(data);
      Response response =
          await Dio().post(ApiClient.addEquipmentUrl, data: formData);

      debugLog(response.data.toString());
      var jsonResponse = response.data;
      if (response.statusCode == 200) {
        bool status = jsonResponse['status'];
        if (status) {
          Toasty.success(equipment != null
              ? 'Equipment Edited Succesfully'
              : 'Equipment added Successful');
          photographerEquipmentRefreshController.requestRefresh();
          Navigator.pop(context);

          isLoading = false;
          notifyListeners();

          return;
        } else {
          isLoading = false;
          notifyListeners();
          debugLog('Error: ${jsonResponse['message']}');
          Toasty.error('Error: ${jsonResponse['message']}');
        }
      } else {
        isLoading = false;
        notifyListeners();
        debugLog('Error: Something went wrong');
        Toasty.error('Something went wrong');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugLog('Error Exception in adding equipment: $e');
      Toasty.error('Something went wrong');
    }
  }

  void updateTimeSlots(
      context, User loggedInUser, isAvailable, selectedTimeSlots) async {
    try {
      isLoading = true;
      notifyListeners();

      var data = {
        'photographer_id': loggedInUser.id,
        'is_available': isAvailable ? "1" : "0",
        'timeslots':
            jsonEncode(AppFunctions.creatingTimeSLotJson(selectedTimeSlots)),
      };

      FormData formData = FormData.fromMap(data);

      // print("formData: $formData");
      Response response =
          await Dio().post(ApiClient.resetTimeSlotsUrl, data: formData);

      debugLog(response.data.toString());
      var jsonResponse = response.data;
      if (response.statusCode == 200) {
        bool status = jsonResponse['status'];
        if (status) {
          Toasty.success('Updated Successfully');

          isLoading = false;
          notifyListeners();

          // print("SessionHelper.userType: ${SessionHelper.userType}");
          loggedInUser.isAvailable = isAvailable ? "1" : "0";
          loggedInUser.timeslots = selectedTimeSlots;

          User? updatedUser = loggedInUser;

          SessionHelper.setUser(
              updatedUser,
              SessionHelper.userType == "1"
                  ? UserType.user
                  : UserType.photographer);

          // print("SessionHelper.userType 2: ${SessionHelper.userType}");
          Navigator.pop(context);
        } else {
          isLoading = false;
          notifyListeners();
          debugLog("Error: ${jsonResponse['message']}");

          Toasty.error('Error: ${jsonResponse['message']}');
        }
      } else {
        isLoading = false;
        notifyListeners();
        Toasty.error('Something went wrong');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugLog("Exception in resetting timeslot: $e");
      Toasty.error('Something went wrong');
    }
  }

  void fetchBankDetails(int userId) async {
    isLoading = true;
    notifyListeners();

    Response response;
    try {
      response = await Dio().get('${ApiClient.getBankDetailsUrl}/$userId');

      if (photographerPaymentInfoRefreshController.isRefresh) {
        photographerPaymentInfoRefreshController.refreshCompleted();
      }
      isLoading = false;
      notifyListeners();
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        debugLog(response.data.toString());
        bool status = jsonResponse['status'];

        if (status) {
          var data = jsonResponse['data'];

          bankAccount = BankAccount.fromJson(data);
        } else {
          Toasty.error('Error: ${jsonResponse['message']}');
        }
        isLoading = false;
        notifyListeners();
      }
    } on DioError catch (e) {
      debugLog(e.message);
      isLoading = false;
      notifyListeners();
      Toasty.error('Network Error: ${e.message}');
      return;
    }
  }


   void acceptBooking(
      int bookingId, String bookingStatus, int photographerId, bkDetail, photographerBookingListProvider,context) async {
    photographerBookingListProvider.setStatusLoader(true);
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
      photographerBookingListProvider.setStatusLoader(false);
      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        //String msg = bookingStatus;
        // Navigator.pop(context);
        photographerBookingListProvider.fetchPhotographerBookings(
            photographerId, context);
        Navigator.pushReplacementNamed(
            context, PhotographerAcceptBookingScreen.route,
            arguments: bkDetail);
        photographerBookingListProvider.setStatusLoader(false);
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
        photographerBookingListProvider.setStatusLoader(false);
      }
    } else {
      Toasty.error('Something went wrong');
      photographerBookingListProvider.setStatusLoader(false);
    }
  }

  ///
  
}
