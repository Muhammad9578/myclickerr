import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';
import '../../helpers/helpers.dart';
import '../../helpers/toast.dart';
import '../../models/user.dart';
import '../../modules/chat/controllers/auth_controller.dart';
import '../../network/api_client.dart';
import '../photographer_screens/p_portfolio_screens/p_signup_add_portfolio_screen.dart';

class WelcomeIntroScreen extends StatefulWidget {
  static const String route = "welcomeIntroScreen";
  final Map<String, dynamic>? userData;

  const WelcomeIntroScreen({Key? key, this.userData}) : super(key: key);

  @override
  State<WelcomeIntroScreen> createState() => _WelcomeIntroScreenState();
}

class _WelcomeIntroScreenState extends State<WelcomeIntroScreen> {
  bool terms = false;
  bool isLoading = false;

  void signup() async {
    try {
      AuthController authProvider = context.read<AuthController>();

      debugLog("photographer signup date: ${widget.userData}");

      FormData formData = FormData.fromMap(widget.userData!);

      // ************* send data to server *******************
      Response response = await Dio().post(
        ApiClient.signupUrl,
        data: formData,
      );

      debugLog(response.data.toString());
      var jsonResponse = response.data;
      if (response.statusCode == 200) {
        bool status = jsonResponse['status'];
        if (status) {
          //Toasty.success('Signup Successful');
          User user = User.fromJson(jsonResponse['data']);
          SessionHelper.setUser(user, UserType.photographer);
          SessionHelper.setRememberMeFlag(authProvider.prefs, rememberMe);

          // userProvider.setUser(user, userType);

          await authProvider.handleSignInWithEmail(
              user.id.toString(),
              widget.userData!['email'],
              widget.userData!['email'],
              widget.userData!['name'],
              user.profileImage,
              "2");

          Future.delayed(Duration(seconds: 1), () {
            if (mounted)
              setState(() {
                isLoading = false;
              });

            Navigator.of(context).pushNamedAndRemoveUntil(
                PhotographerSignupAddPortfolioScreen.route,
                    (Route<dynamic> route) => false,
                arguments: {'photographerId': user.id});
          });
        } else {
          setState(() {
            isLoading = false;
          });
          Toasty.error('Error: ${jsonResponse['message']}');
          // handleFailSignup();
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Toasty.error('Something went wrong');
        // handleFailSignup();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugLog("Dio error in signup: $e");
      Toasty.error('Something went wrong');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            20.SpaceY,
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppColors.shaderWhite,
                  ),
                  height: 10,
                ),
                Container(
                  height: 10,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.66,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                    ),
                  ),
                ),
              ],
            ),
            30.SpaceY,
            kLogoImage,
            30.SpaceY,
            Text(
              textAlign: TextAlign.center,
              "Welcome to MyClicker",
              style: MyTextStyle.boldBlack.copyWith(
                fontSize: 30,
              ),
            ),
            10.SpaceY,
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10.0),
              child: Text(
                textAlign: TextAlign.center,
                "Accept the terms and conditions to complete your signup process",
                style: MyTextStyle.medium07Black.copyWith(
                  fontSize: 14,
                ),
              ),
            ),
            20.SpaceY,
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.black.withOpacity(0.2), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Text(
                        "Integer at faucibus urna. Nullam condimentum leo id elit sagittis auctor. \n\nCurabitur elementum nunc a leo imperdiet, nec elementum diam elementum. \n\nEtiam elementum euismod commodo. Proin eleifend eget quam ut efficitur. \n\nMauris a accumsan mauris. Phasellus egestas et risus sit amet hendrerit. \n\nNulla facilisi. Cras urna sem, vulputate sed condimentum a, posuere vel enim. \n\nInteger at faucibus urna. Nullam condimentum leo id elit sagittis auctor. \n\nCurabitur elementum nunc a leo imperdiet, nec elementum diam elementum. \n\nEtiam elementum euismod commodo. Proin eleifend eget quam ut efficitur. \n\nMauris a accumsan mauris. Phasellus egestas et risus sit amet hendrerit. \n\nNulla facilisi. Cras urna sem, vulputate sed condimentum a, posuere vel enim."),
                  ),
                ),
              ),
            ),
            20.SpaceY,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                    // fillColor:
                    // MaterialStateProperty.all<Color>(AppColors.orange),
                      side: BorderSide(color: AppColors.orange,width: 2),
                              activeColor: AppColors.orange,
                    value: terms,
                    onChanged: (val) {
                      setState(() {
                        terms = val!;
                      });
                      // print("val: $val");
                    }),
                5.SpaceX,
                Expanded(
                  child: Text(
                    "I agree all the Terms and Conditions",
                    style: MyTextStyle.mediumBlack.copyWith(fontSize: 14),
                  ),
                )
              ],
            ),
            15.SpaceY,
            isLoading
                ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.orange),
            )
                : GradientButton(
              text: "Proceed",
              onPress: () {
                if (!terms) {
                  Toasty.error("Please accept terms & conditions.");
                  return;
                } else {
                  setState(() {
                    isLoading = true;
                    signup();
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
