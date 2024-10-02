import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/modules/chat/constants/constants.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/network/api_client.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_profile_screens/photographer_signup_screen.dart';
import 'package:photo_lab/src/screens/shared_screens/forgot_password_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_profile_screens/user_signup_screen.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../photographer_screens/p_home_startup.dart';
import '../photographer_screens/p_portfolio_screens/p_signup_add_portfolio_screen.dart';
import '../photographer_screens/p_profile_screens/p_pending_verification_screen.dart';
import '../photographer_screens/p_profile_screens/p_verification_succesfull_screen.dart';
import '../user_screens/u_home_startup.dart';
import 'instamojo_paymnet_screen.dart';

class UserLoginScreen extends StatefulWidget {
  static const String route = 'user_login_screen';

  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  String email = 'Email';
  String password = '';
  bool hidePassword = true;

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late UserController userProvider;

  late TwilioFlutter twilioFlutter;

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserController>();
    twilioFlutter = TwilioFlutter(
        accountSid: kTwilioAccountSid,
        authToken: kTwilioAuthToken,
        twilioNumber: kTwilioNumber);
    SessionHelper().getemail().then((value) {
      emailController.text = value;
      email = value;
      debugLog("email$email");
    });
  }

  @override
  Widget build(BuildContext context) {
    UserType userType = ModalRoute.of(context)!.settings.arguments as UserType;

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      // appBar: CustomAppBar(
      //   title: "Log In",
      //   action: [],
      // ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Column(
                children: [
                  80.SpaceY,
                  kLogoImage,
                  // 25.SpaceY,
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 130,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  //physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome Back",
                          style: MyTextStyle.boldBlack.copyWith(
                            fontSize: 34,
                          ),
                        ),
                        10.SpaceY,
                        Text(
                          "Enter the following details to proceed",
                          style: MyTextStyle.medium07Black.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        30.SpaceY,
                        PrimaryTextField(
                          controller: emailController,
                          textCapitalization: TextCapitalization.none,
                          'Email',
                          labelText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter email address';
                            }
                            return null;
                          },
                          onChange: (value) {
                            debugLog(email);
                            email = value.trim();
                          },
                        ),
                        10.SpaceY,
                        PrimaryTextField(
                          'Password',
                          labelText: "Password",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password';
                            } else {
                              return null;
                            }
                          },
                          suffixIcon: hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          suffixIconOnTap: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          hideText: hidePassword,
                          onChange: (value) {
                            password = value;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                                side: BorderSide(
                                    color: AppColors.orange, width: 2),
                                activeColor: AppColors.orange,

                                // fillColor: MaterialStateProperty.all<Color>(
                                //     AppColors.orange),
                                value: rememberMe,
                                onChanged: (val) {
                                  setState(() {
                                    rememberMe = val!;
                                  });
                                  // print("val: $val");
                                }),
                            5.SpaceX,
                            Expanded(
                              child: Text(
                                "Remember Me",
                                style: MyTextStyle.mediumBlack
                                    .copyWith(fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: kDefaultSpace * 3),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              closeKeyboard(context);

                              Navigator.pushNamed(
                                  context, ForgotPasswordScreen.route,
                                  arguments: userType);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.all(5),
                              child: const Text(
                                'Forgot Password',
                              ),
                            ),
                          ),
                        ),
                        50.SpaceY,
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.orange),
                              )
                            : GradientButton(
                                text: 'Log In',
                                onPress: () {
                                  closeKeyboard(context);

                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    login(userType, email, password);
                                  }
                                },
                              ),
                        20.SpaceY,
                        PrimaryButton(
                          text: 'Sign up',
                          onPress: () {
                            closeKeyboard(context);
                            // print("userType in login screen: $userType");
                            userType == UserType.user
                                ? Navigator.pushNamed(
                                    context, UserSignupScreen.route,
                                    arguments: userType)
                                : Navigator.pushNamed(
                                    context, PhotographerSignupScreen.route,
                                    arguments: userType);
                          },
                        ),
                        20.SpaceY,
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            // Navigator.pushNamed(
                            //     context, UserLoginScreen.route,
                            //     arguments: UserType.photographer);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'Back to profile selection',
                              style: TextStyle(color: AppColors.orange),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendSms() async {
    TwilioFlutter twilioFlutter = TwilioFlutter(
        accountSid: kTwilioAccountSid,
        authToken: kTwilioAuthToken,
        twilioNumber: kTwilioNumber);
    var rng = new Random();
    int code = rng.nextInt(900000) + 100000;
    twilioFlutter
        .sendSMS(
            toNumber: '+923336440536',
            messageBody: 'Your myclickerr otp is $code')
        .then((value) {
      print("message send: $value");
    }).catchError((error) {
      print("message error: $error");
    }).timeout(Duration(minutes: 2), onTimeout: () {
      print("message timeout");
    });
  }

  void getSms() async {
    var data = await twilioFlutter.getSmsList();
    print("get sms response: $data");
    await twilioFlutter.getSMS('***************************');
  }

  void login(UserType userType, String email, String password) async {
    AuthController authProvider = context.read<AuthController>();
    debugLog(email);
    var data = {
      'login_as': userType == UserType.user ? 1 : 2,
      'email': email,
      'password': password
    };

    Response response;
    try {
      response = await Dio().post(ApiClient.loginUrl, data: data);
    } on DioError catch (e) {
      debugLog(e);
      setState(() {
        isLoading = false;
      });
      Toasty.error('Network Error:${e.message}');

      return;
    }

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugLog(response.data.toString());
      bool status = jsonResponse['status'];
      if (status) {
        //Toasty.success('Login Successful');
        User user = User.fromJson(jsonResponse['data']);
        SessionHelper.setUser(user, userType);
        SessionHelper.setRememberMeFlag(authProvider.prefs, rememberMe);
        SessionHelper.setuseremail(userType, rememberMe, email);
        // userProvider.setUser(user, userType);

        await authProvider.handleSignInWithEmail(
            user.id.toString(),
            email,
            email,
            user.name,
            user.profileImage,
            userType == UserType.user ? "1" : "2");
        setState(() {
          isLoading = false;
        });
        if (!mounted) {
          return;
        }

        if (userType == UserType.user) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              UserHomeStartup.route, (Route<dynamic> route) => false);
        } else if (userType == UserType.photographer) {
          if (!user.hasPortfolio) {
            //  todo upload portfolio screen
            SessionHelper.setRememberMeFlag(authProvider.prefs, false);
            Navigator.of(context).pushNamedAndRemoveUntil(
                PhotographerSignupAddPortfolioScreen.route,
                (Route<dynamic> route) => false,
                arguments: {'photographerId': user.id});
          } else if (user.isVerified == 0) {
            SessionHelper.setRememberMeFlag(authProvider.prefs, false);
            Navigator.pushNamed(
                context, PhotographerPendingVerificationScreen.route);
          } else {
            var userDocRef = FirebaseFirestore.instance
                .collection(FirestoreConstants.pathUserCollection)
                .doc(auth.FirebaseAuth.instance.currentUser!.uid);

            var userDocument = await userDocRef.get();
            bool isverified = false;
            if (userDocument
                .data()!
                .containsKey(FirestoreConstants.isverifiedscreenshown)) {
              isverified = userDocument
                  .data()![FirestoreConstants.isverifiedscreenshown];
            } else {
              await userDocRef
                  .update({FirestoreConstants.isverifiedscreenshown: true});
            }

            // check onboarding screen shown or not

            if (isverified) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PhotographerHomeStartup.route,
                  (Route<dynamic> route) => false);
            } else {
              await userDocRef
                  .update({FirestoreConstants.isverifiedscreenshown: true});
              authProvider.prefs
                  .setBool(FirestoreConstants.onboardingScreenShown, true);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PhotographerVerificationSuccessfulScreen.route,
                  arguments: {'userType': userType},
                  (Route<dynamic> route) => false);
            }
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Toasty.error(jsonResponse['message']);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Toasty.error('Something went wrong');
    }
  }
}
