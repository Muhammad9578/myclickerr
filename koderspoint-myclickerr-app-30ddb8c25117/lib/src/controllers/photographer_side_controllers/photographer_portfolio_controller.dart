import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_booking_controller.dart';
import 'package:photo_lab/src/models/booking.dart';
import 'package:photo_lab/src/models/skill_model.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_portfolio_screens/p_signup_portfolio_main_screen.dart';

import '../../helpers/constants.dart';
import '../../helpers/toast.dart';
import '../../helpers/utils.dart';
import '../../models/portfolio_model.dart';
import '../../network/api_client.dart';

class PhotographerPortfolioController extends ChangeNotifier {
  bool alreadyRated = false;
  bool isloading = false;
  List<PortfolioModel>? photographerPortfolio;
  Dio dio = Dio();
  void getPortfolio(int photographerId) async {
    List<PortfolioModel>? portfolio = [];

    var data = {
      'action': 'view',
      'photographer_id': photographerId,
    };
    Response response;
    try {
      response = await dio.post(ApiClient.portfolioUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);
      Toasty.error('Something went wrong. Try again later');
      setPhotographerPortfolio([]);
      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        var dataArray = jsonResponse['data'];
        portfolio.clear();
        // debugPrint("equipment list length: ${dataArray.length}");
        for (var item in dataArray) {
          portfolio.add(PortfolioModel.fromJson(item));
        }

        if (photographerPortfolio != null) {
          photographerPortfolio!.clear();
          setPhotographerPortfolio(portfolio);
        } else {
          setPhotographerPortfolio(portfolio);
        }
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
        setPhotographerPortfolio([]);
      }
    } else {
      Toasty.error('Something went wrong. Try again later');
      setPhotographerPortfolio([]);
    }
  }

  getskills() async {
    isloading = true;
    try {
      Response response = await dio
          .get(ApiClient.photographerSkillsUrl); // Replace with your API URL
      if (response.statusCode == 200) {
        final skillsResponse = SkillsResponse.fromJson(response.data);

        debugPrint('Status: ${skillsResponse.status}');
        debugPrint('Message: ${skillsResponse.message}');
        if (skillsResponse.data['pre_production'] != null) {
          preProductionSkills = [];
          for (final skill in skillsResponse.data['pre_production']!) {
            debugPrint('Pre-Production Skill: ${skill.skill}');
            preProductionSkills.add(skill.skill);
          }
        }
        if (skillsResponse.data['post_production'] != null) {
          postProductionSkills = [];
          for (final skill in skillsResponse.data['post_production']!) {
            debugPrint('Post-Production Skill: ${skill.skill}');
            postProductionSkills.add(skill.skill);
          }
        }
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
      }

      isloading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');

      isloading = false;
      notifyListeners();
    }
  }

  setPhotographerPortfolio(val) {
    photographerPortfolio = val;
    if (photographerPortfolioRefreshController.isRefresh) {
      photographerPortfolioRefreshController.refreshCompleted();
    }
    if (photographerSignupPortfolioRefreshController.isRefresh) {
      photographerSignupPortfolioRefreshController.refreshCompleted();
    }
    notifyListeners();
  }

  ///save portfolio
  void savePortfolio(
      {context,
      bool? edit,
      PortfolioModel? portfolioModel,
      required List<File> selectedImages,
      required String eventName,
      User? loggedInUser}) async {
    try {
      isloading = true;
      notifyListeners();
      var lst = [];
      selectedImages.forEach((File element) {
        String fileName = element.path.split('/').last;
        lst.add(MultipartFile.fromFileSync(element.path, filename: fileName));
      });
      var data = {
        'photographer_id': loggedInUser!.id,
        'title': eventName.toString(),
        'portfolio_date': DateTime.now().millisecondsSinceEpoch,
        'images[]': lst,
      };

      if (edit!) {
        data['portfolio_id'] = portfolioModel!.portfolioId!;
        data['action'] = 'edit';
      } else {
        data['action'] = 'create';
      }
      print("lst2: $lst");
      debugLog("Add equipemnt details: $data");
      FormData formData = FormData.fromMap(data);
      Response response =
          await Dio().post(ApiClient.portfolioUrl, data: formData);

      debugLog(response.data.toString());
      var jsonResponse = response.data;
      if (response.statusCode == 200) {
        bool status = jsonResponse['status'];
        if (status) {
          if (edit) {
            Toasty.success('Portfolio updated Successfully');
            photographerPortfolioRefreshController.requestRefresh();
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            Toasty.success('Portfolio added Successfully');
            photographerPortfolioRefreshController.requestRefresh();
            Navigator.pop(context);
          }

          isloading = false;
        } else {
          isloading = false;

          debugLog('Error: ${jsonResponse['message']}');
          Toasty.error('Error: ${jsonResponse['message']}');
        }
      } else {
        isloading = false;
        notifyListeners();
        debugLog('Error: Something went wrong');
        Toasty.error('Something went wrong');
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      debugLog('Error Exception in adding equipment: $e');
      Toasty.error('Something went wrong');
    }
  }

  void submitRating(
      {context,
      required Booking bkDetail,
      required double rating,
      required String description,
      required UserBookingController userBookingProvider}) async {
    var data = {
      'user_id': bkDetail.userId,
      'photographer_id': bkDetail.photographerId,
      'rating': rating,
      'description': description,
      'booking_id': bkDetail.id,
    };

    print("for data: $data");
    Response response;
    try {
      response = await Dio().post(ApiClient.ratePhotographerUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);

      isloading = false;
      notifyListeners();

      Toasty.error('Network Error:${e.message}');

      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;

      bool status = jsonResponse['status'];
      if (status) {
        Toasty.success('Successful rated.');
        userBookingProvider.fetchUserAllBookings(bkDetail.userId);

        alreadyRated = true;
        isloading = false;

        Navigator.pop(context);
      } else {
        isloading = false;
        notifyListeners();
        debugLog("failed to rate: $response ");
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      isloading = false;
      notifyListeners();
      Toasty.error('Something went wrong');
    }
  }

  void deletePortfolio(id) async {
    isloading = true;
    notifyListeners();

    var data = {
      'action': 'delete',
      'portfolio_id': id,
    };
    Response response;
    try {
      response = await Dio().post(ApiClient.portfolioUrl, data: data);
    } on DioError catch (e) {
      debugLog(e.message);

      isloading = false;
      notifyListeners();

      Toasty.error('Network Error: ${e.message}');
      return null;
    }

    if (response.statusCode == 200) {
      // print("response: $response");

      var jsonResponse = response.data;
      // print("jsonResponse: ${jsonResponse}");
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];

      if (status) {
        Toasty.success('Successfully deleted');
        photographerPortfolioRefreshController.requestRefresh();

        isloading = false;
        notifyListeners();
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');

        isloading = false;
        notifyListeners();
      }
    }
  }

  void savePortfolio1(
    context,
    selectedImages,
    photographerId,
    eventName,
    fromPortfolio,
  ) async {
    try {
      isloading=true;
      notifyListeners();
      var lst = [];
      selectedImages.forEach((File element) {
        String fileName = element.path.split('/').last;
        lst.add(MultipartFile.fromFileSync(element.path, filename: fileName));
      });
      var data = {
        'action': 'create',
        'photographer_id': photographerId,
        'title': eventName.toString(),
        'portfolio_date': DateTime.now().millisecondsSinceEpoch,
        'images[]': lst,
      };

      debugLog("Add equipemnt details: $data");
      FormData formData = FormData.fromMap(data);
      Response response =
          await Dio().post(ApiClient.portfolioUrl, data: formData);

      debugLog(response.data.toString());
      var jsonResponse = response.data;
      if (response.statusCode == 200) {
        bool status = jsonResponse['status'];
        if (status) {
          Toasty.success('Portfolio added Successfully');

          //
          // todo move to display signup portfolio screen
          if (fromPortfolio!) {
            photographerSignupPortfolioRefreshController.requestRefresh();
            Navigator.pop(context);
          } else
            Navigator.pushNamed(
                context, PhotographerSignupPortfolioMainScreen.route);

          isloading = false;
          notifyListeners();
          return;
        } else {
          isloading = false;
          notifyListeners();
          debugLog('Error: ${jsonResponse['message']}');
          Toasty.error('Error: ${jsonResponse['message']}');
        }
      } else {
        isloading = false;
        debugLog('Error: Something went wrong');
        Toasty.error('Something went wrong');
      }
    } catch (e) {
      isloading = false;
      debugLog('Error Exception in adding equipment: $e');
      Toasty.error('Something went wrong');
    }
  }
}
