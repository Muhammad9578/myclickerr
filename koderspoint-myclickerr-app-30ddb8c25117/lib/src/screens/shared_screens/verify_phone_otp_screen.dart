import 'dart:async';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_profile_screens/p_add_skills_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../../helpers/constants.dart';
import '../../helpers/helpers.dart';
import '../../helpers/session_helper.dart';
import '../../helpers/toast.dart';
import '../../helpers/utils.dart';
import '../../models/user.dart';
import '../../network/api_client.dart';
import '../../widgets/buttons.dart';
import 'on_boarding_screen.dart';

class VerifyMobileOtpScreen extends StatefulWidget {
  static const String route = "verifyMobileOtpScreen";
  final String verificationId;
  final Map<String, dynamic> userData;

  const VerifyMobileOtpScreen({
    Key? key,
    required this.verificationId,
    required this.userData,
  }) : super(key: key);

  @override
  _VerifyMobileOtpScreenState createState() => _VerifyMobileOtpScreenState();
}

class _VerifyMobileOtpScreenState extends State<VerifyMobileOtpScreen> {
  TextEditingController textEditingController = TextEditingController();

  StreamController<ErrorAnimationType>? errorController;
  bool isLoading = false;
  bool hasError = false;
  String enteredOtpCode = "";
  late String verificationId;
  late String actualOtp;
  late Map<String, dynamic> userData;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    userData = widget.userData;
    actualOtp = widget.verificationId;
    verificationId = widget.verificationId;
    super.initState();
  }

 
  
  
  void userSignup() async {
    setState(() {
      isLoading = true;
    });
    AuthController authProvider = context.read<AuthController>();

    FormData formData = FormData.fromMap(userData);
    Response response = await Dio().post(ApiClient.signupUrl, data: formData);

    var jsonResponse = response.data;
    if (response.statusCode == 200) {
      bool status = jsonResponse['status'];
      if (status) {
        //Toasty.success('Signup Successful');
        User user = User.fromJson(jsonResponse['data']);
        SessionHelper.setUser(user, UserType.user);

        SessionHelper.setRememberMeFlag(authProvider.prefs, rememberMe);

        // userProvider.setUser(user, userType);
        await authProvider.handleSignInWithEmail(
            user.id.toString(),
            userData['email'],
            userData['email'],
            userData['name'],
            user.profileImage,
            "1");
        setState(() {
          isLoading = false;
        });
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
            OnBoardingScreen.route,
            arguments: {'userType': UserType.user},
            (Route<dynamic> route) => false);
      } else {
        setState(() {
          isLoading = false;
        });

        debugLog("jsonResponse['message']: ${jsonResponse['message']}");
        Toasty.error('Error: ${jsonResponse['message']}');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Toasty.error('Something went wrong');
    }
  }

  void _sendSms() async {
    String phoneNumber =
        "+${CountryService().findByCode(userData['phone_code'].toString().replaceAll('+', ''))?.phoneCode}${userData['phone']}";
    debugLog(">>>>" + phoneNumber);

    TwilioFlutter twilioFlutter = TwilioFlutter(
        accountSid: kTwilioAccountSid,
        authToken: kTwilioAuthToken,
        twilioNumber: kTwilioNumber);
    var rng = new Random();
    int code = rng.nextInt(900000) + 100000;
    twilioFlutter
        .sendSMS(
            toNumber: phoneNumber,
            messageBody: 'MyClickerr phone verification code is $code.')
        .then((value) {
      Future.delayed(Duration(seconds: 4), () {
        actualOtp = code.toString();
        debugLog("message send: $value");
        Toasty.success("Verification Code Send to the phone");
        if (mounted)
          setState(() {
            isLoading = false;
            // otpsent = true;
          });
      });

      // Navigator.pushNamed(context, VerifyMobileOtpScreen.route, arguments: {
      //   'data': widget.userData,
      //   'verificationId': code
      // });
    }).catchError((error) {
      debugLog("verificationFailed error: $error");
      if (error.code == 'too-many-requests')
        Toasty.error("Otp Failed! Too many request. Try again later.");
      else {
        Toasty.error("Otp Failed! $error");
      }
      setState(() {
        isLoading = false;
      });
    }).timeout(Duration(minutes: 2), onTimeout: () {
      print("message timeout");
      Toasty.error("Otp request timeout. Try again later.");
      setState(() {
        isLoading = false;
      });
    });
  }

  void verifyOtp() {
    if (enteredOtpCode == actualOtp) {
      snackBar("OTP Verified!!");
      // signup();

      if (userData['signup_as'] == 'user') {
        userSignup();
      } else {
        Navigator.pushNamed(context, PhotographerAddSkillsScreen.route,
            arguments: {
              'data': widget.userData,
            });
        setState(() {
          isLoading = false;
        });
      }
    } else {
      Toasty.error("    Invalid OTP   ");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.kOnPrimaryColor,
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
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
                          width: MediaQuery.of(context).size.width * 0.33,
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
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 135,
              bottom: 20,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      10.SpaceY,
                      Text(
                        textAlign: TextAlign.center,
                        "OTP Verification",
                        style: MyTextStyle.regularBlack.copyWith(
                          fontSize: 20,
                          color: AppColors.shaderBlue,
                        ),
                      ),
                      10.SpaceY,
                      Text(
                        textAlign: TextAlign.center,
                        "Enter the OTP",
                        style: MyTextStyle.boldBlack.copyWith(
                          fontSize: 34,
                        ),
                      ),
                      10.SpaceY,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              textAlign: TextAlign.center,
                              "Enter the OTP send to ",
                              style: MyTextStyle.medium07Black.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          10.SpaceX,
                          Text(
                            '+${CountryService().findByCode(userData['phone_code'].toString().replaceAll('+', ''))?.phoneCode}${userData['phone']}',
                            style: MyTextStyle.semiBoldBlack.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          10.SpaceX,
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Edit',
                              style: MyTextStyle.boldBlack.copyWith(
                                  fontSize: 14, color: AppColors.purple),
                            ),
                          ),
                        ],
                      ),
                      30.SpaceY,
                      Form(
                        key: formKey,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            child: PinCodeTextField(
                              enablePinAutofill: true,

                              appContext: context,
                              pastedTextStyle: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                              length: 6,
                              // obscureText: true,
                              // obscuringCharacter: 'x',
                              // obscuringWidget: const FlutterLogo(
                              //   size: 24,
                              // ),
                              blinkWhenObscuring: true,
                              animationType: AnimationType.fade,
                              // validator: (v) {
                              //   if (v!.length < 3) {
                              //     return "I'm from validator";
                              //   } else {
                              //     return null;
                              //   }
                              // },
                              pinTheme: PinTheme(
                                disabledColor: Colors.grey[500],
                                inactiveFillColor: AppColors.shaderWhite,
                                selectedColor: Colors.orange,
                                inactiveColor: AppColors.shaderWhite,
                                activeColor: AppColors.shaderWhite,
                                selectedFillColor: Colors.orange,
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(10),
                                fieldHeight: 40,
                                fieldWidth: 35,
                                activeFillColor: Colors.white,
                              ),
                              cursorColor: Colors.black,
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              enableActiveFill: true,
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              boxShadows: const [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Colors.black12,
                                  blurRadius: 1,
                                )
                              ],
                              onCompleted: (v) {
                                // debug // print("Completed");
                              },
                              // onTap: () {
                              //   // print("Pressed");
                              // },
                              onChanged: (value) {
                                // debugPrint(value);
                                setState(() {
                                  enteredOtpCode = value;
                                });
                              },
                              beforeTextPaste: (text) {
                                // debug // print("Allowing to paste $text");
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                return true;
                              },
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          hasError
                              ? "*Please fill up all the cells properly"
                              : "",
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      isLoading
                          ? SizedBox.shrink()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Did not receive OTP ? ",
                                    style: MyTextStyle.mediumBlack
                                        .copyWith(fontSize: 14)),
                                TextButton(
                                  onPressed: () {
                                    textEditingController.clear();

                                    setState(() {
                                      isLoading = true;
                                      _sendSms();
                                    });
                                  },
                                  child: Text("RESEND",
                                      style: MyTextStyle.boldBlack
                                          .copyWith(fontSize: 14)),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    )
                  : GradientButton(
                      onPress: () {
                        formKey.currentState!.validate();
                        // conditions for validating
                        if (enteredOtpCode.length != 6) {
                          errorController!.add(ErrorAnimationType
                              .shake); // Triggering error shake animation
                          setState(() => hasError = true);
                        } else {
                          setState(
                            () {
                              isLoading = true;
                              // final auth.PhoneAuthCredential credential =
                              //     auth.PhoneAuthProvider.credential(
                              //   verificationId: verificationId,
                              //   smsCode: enteredOtpCode,
                              // );
                              verifyOtp();
                              // signInWithPhoneNumber(credential);
                              // hasError = false;
                              //
                              // Navigator.pushNamed(context, PhotographerAddSkillsScreen.route);
                            },
                          );
                        }
                      },
                      text: "Submit OTP",
                    ),
            )
          ],
        ),
      ),
    );
  }
}
