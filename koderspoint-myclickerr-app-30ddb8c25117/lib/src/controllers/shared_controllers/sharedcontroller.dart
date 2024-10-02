import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/category.dart';
import 'package:photo_lab/src/models/notification_model.dart';
import 'package:photo_lab/src/models/product.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/screens/shared_screens/reset_password_screen.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';

class SharedController extends ChangeNotifier {
  bool isLoading = false;
  final _bottomSheetFormKey = GlobalKey<FormState>();
  String enteredCode = '';
  void updatePassword(context, String email, String password) async {
    isLoading = true;
    notifyListeners();
    var data = {
      'email': email,
      'password': password,
      'confirm_password': password
    };
    Response response;
    try {
      response = await Dio().post(ApiClient.resetPasswordUrl, data: data);
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
        var message = jsonResponse['message'];

        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Reset Password'),
                content: Text('$message. Proceed to login.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // reset confirmation popup dialog
                      Navigator.pop(context); // reset password screen
                      Navigator.pop(context); // reset code bottom sheet
                      Navigator.pop(context); // forgot password screen

                      // Navigator.of(context).pushNamedAndRemoveUntil(
                      //     UserLoginScreen.route, (route) => false,
                      //     arguments: widget.userType);
                    },
                    child: const Text('OK'),
                  )
                ],
              );
            });
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      Toasty.error('Something went wrong');
    }
  }

  //
  Future<List<NotificationModel>> fetchNotifications(
      int userId, userProvider) async {
    List<NotificationModel> notificationsList = [];

    CallResponse response = await ApiClient.getUserNotifications(userId);
    notifyListeners();

    if (response.error != null) {
    } else {
      if (response.data != null) {
        notificationsList = response.data;
        debugLog("notificationsList: $notificationsList");
        if (notificationsList.length > 0) {
          resetNotificationCount(userId, userProvider);
        }
      }
    }
    return notificationsList;
  }

  void resetNotificationCount(int userId, userProvider) async {
    CallResponse response = await ApiClient.resetNotificationCount(userId);
    if (response.error == null) {
      userProvider.setUnreadNotificationCount(0);
    }
  }

  Future<List<Category>?> fetchCategories() async {
    List<Category> categories = [];

    Response response;
    try {
      response = await Dio().get(ApiClient.marketplaceCategoriesUrl);
    } on DioError catch (e) {
      debugLog(e.message);

      isLoading = false;
      notifyListeners();
      Toasty.error('Network Error: ${e.message}');
      return null;
    }

    isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];

      if (status) {
        var dataArray = jsonResponse['data'] as List<dynamic>;
        for (var item in dataArray) {
          categories.add(Category.fromJson(item));
        }
        if (categories.isNotEmpty) {
          categories[0].isSelected = true;
        }
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    }

    return categories;
  }

  Future<List<Product>?> fetchProducts(int categoryId) async {
    List<Product> products = [];
    // print("cat id: $categoryId");
    Response response;
    try {
      response =
          await Dio().get('${ApiClient.marketplaceProductsUrl}/$categoryId');
    } on DioError catch (e) {
      debugLog(e.message);

      isLoading = false;
      notifyListeners();
      Toasty.error('Network Error: ${e.message}');
      return null;
    }

    isLoading = false;
    notifyListeners();
    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(
          "market palce screen response data : ${response.data.toString()}");
      bool status = jsonResponse['status'];

      if (status) {
        var dataArray = jsonResponse['data']['data'] as List<dynamic>;
        for (var item in dataArray) {
          products.add(Product.fromJson(item));
        }
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    }

    return products;
  }

  ///
  void forgotPassword(context, String email, UserType userType) async {
    isLoading = true;
    notifyListeners();
    Response response;
    try {
      response = await Dio().get('${ApiClient.forgotPasswordUrl}/$email');
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
        var message = jsonResponse['message'];
        int code = jsonResponse['data']['code'];
        // print("code  = $code");

        showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBottomSheetBorderRadius)),
            context: context,
            builder: (ctx) {
              return Padding(
                padding: EdgeInsets.only(
                    top: kScreenPadding,
                    left: kScreenPadding,
                    right: kScreenPadding,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        kScreenPadding * 2),
                child: Form(
                  key: _bottomSheetFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HeadingText(message),
                      Text(
                        '$message',
                        style: MyTextStyle.mediumBlack.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: kDefaultSpace * 2,
                      ),
                      PrimaryTextField(
                        'Enter code here...',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter code here';
                          } else {
                            return null;
                          }
                        },
                        onChange: (value) {
                          enteredCode = value;
                        },
                      ),
                      const SizedBox(
                        height: kDefaultSpace * 3,
                      ),
                      GradientButton(
                        text: 'Verify',
                        onPress: () {
                          debugLog("Here At verify button bash");
                          if (_bottomSheetFormKey.currentState!.validate()) {
                            if (enteredCode.isEmpty) {
                              return;
                            } else if (enteredCode == code.toString()) {
                              Navigator.pushNamed(
                                  context, ResetPasswordScreen.route,
                                  arguments: {
                                    'email': email,
                                    'user_type': userType
                                  });
                            } else {
                              Toasty.error('Invalid code');
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            });
      } else {
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      Toasty.error('Something went wrong');
    }
  }
}
