import 'dart:math';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/screens/shared_screens/verify_phone_otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import '../../helpers/helpers.dart';
import '../../models/user.dart' as usr;
import '../../network/api_client.dart';
import '../../widgets/buttons.dart';
import '../../widgets/phone_text_field.dart';
import '../photographer_screens/p_home_startup.dart';

class MobileNumberInputScreen extends StatefulWidget {
  static const String route = "mobileNumberInputScreen";
  final Map<String, dynamic> userData;

  const MobileNumberInputScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<MobileNumberInputScreen> createState() =>
      _MobileNumberInputScreenState();
}

class _MobileNumberInputScreenState extends State<MobileNumberInputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  Country selectedCountry = CountryService().findByCode('IN')!;
  String phone = '';
  var verificationId;
  bool otpsent = false;
  PhoneAuthCredential? phoneAuthCredential;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*UserType userType = ModalRoute
        .of(context)!
        .settings
        .arguments as UserType;*/

    return Scaffold(
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
                            .width * 0.33,
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
              //physics: const ClampingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "Welcome to MyClicker",
                      style: MyTextStyle.regularBlack.copyWith(
                        fontSize: 21,
                      ),
                    ),
                    10.SpaceY,
                    Text(
                      textAlign: TextAlign.center,
                      "Enter your mobile number",
                      style: MyTextStyle.boldBlack.copyWith(
                        fontSize: 34,
                      ),
                    ),
                    10.SpaceY,
                    Text(
                      textAlign: TextAlign.center,
                      "Enter your 10 digit mobile number to proceed",
                      style: MyTextStyle.medium07Black.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    30.SpaceY,
                    PhoneTextField(
                      selectedCountry: selectedCountry,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        } else if (!value.trim().isValidNumbers()) {
                          return 'Only numbers are allowed';
                        } else if (value
                            .trim()
                            .length != 10) {
                          return 'Invalid mobile number. Only 9-10 digits are allowed.';
                        }
                        return null;
                      },
                      onChange: (country, phone) {
                        if (country != null) {
                          setState(() {
                            selectedCountry = country;
                          });
                        }
                        if (phone != null) {
                          setState(() {
                            this.phone = phone.trim();
                          });
                        }
                      },
                    ),
                    20.SpaceY,
                    // GradientButton(
                    //   text: "Verify number",
                    //   onPress: (){
                    //     signInWithPhoneNumber(verificationId, '123456');
                    //   },
                    // )
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
                ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.orange),
            )
                : GradientButton(
              text: 'Get OTP',
              onPress: () {
                closeKeyboard(context);
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  widget.userData['phone_code'] =
                  '+${selectedCountry.countryCode}';
                  widget.userData['country_code'] =
                  '+${selectedCountry.phoneCode}';
                  widget.userData['phone'] = phone;

                  // _submitPhoneNumber();
                  // signup();
                  _sendSms();
                  // login(userType, email, password);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  void _sendSms() async {
    String phoneNumber = "+" + selectedCountry.phoneCode + phone;
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
        messageBody: 'MyClickerr phone verification OTP is $code.')
        .then((value) {
      Future.delayed(Duration(seconds: 10), () {
        if (mounted)
          setState(() {
            isLoading = false;
            otpsent = true;
          });
        debugLog("message send: $value");
        Toasty.success("Verification Code Send to the phone");
        Navigator.pushNamed(context, VerifyMobileOtpScreen.route, arguments: {
          'data': widget.userData,
          'verificationId': code.toString()
        });
      });
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
}
