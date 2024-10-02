import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/modules/chat/controllers/controllers.dart';
import 'package:photo_lab/src/widgets/circle_profile.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../../../modules/chat/constants/firestore_constants.dart';
import '../../../widgets/buttons.dart';
import '../../shared_screens/phone_number_input_screen.dart';

class UserSignupScreen extends StatefulWidget {
  static const String route = "user_signup_screen";

  const UserSignupScreen({Key? key}) : super(key: key);

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  String name = '';
  String email = '';
  String phone = '';
  String password = '';
  String confirmPassword = '';
  double charges = 0;
  String city = '';
  String state = '';
  String country = '';
  String postalCode = '';
  String address = '';
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  double latitude = 0;
  double longitude = 0;
  Country selectedCountry = CountryService().findByCode('IN')!;
  Image profileImage = Image.asset(ImageAsset.PlaceholderImg);
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  late UserController userProvider;

  final TextEditingController locationController = TextEditingController();
  late AuthController authProvider;

  @override
  void initState() {
    super.initState();
    AppFunctions.imagepath = '';
    userProvider = context.read<UserController>();
    authProvider = Provider.of<AuthController>(context, listen: false);

    // checkEmailExistVerified();
  }

  checkEmailExistVerified() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        debugLog(
            "Firebase current user is not null mail is: ${FirebaseAuth.instance.currentUser?.email}");

        if (FirebaseAuth.instance.currentUser?.email != null) {
          await sendVerificationLinkToEmail();

          // print("verifies? ${FirebaseAuth.instance.currentUser!.emailVerified}");
          // if(!FirebaseAuth.instance.currentUser!.emailVerified)
          // { AuthCredential credentials =
          // EmailAuthProvider.credential(email: FirebaseAuth.instance.currentUser!.email!, password: FirebaseAuth.instance.currentUser!.email!);
          // await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credentials);
          // await FirebaseAuth.instance.currentUser!.delete();
          // }
        }
      } else {
        debugLog("Firebase current user is null");
      }
    } catch (e) {
      debugLog("Exception in verifying: $e");
    }
  }

  sendVerificationLinkToEmail() async {
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    email = FirebaseAuth.instance.currentUser!.email!;

    debugLog("email : $email \n isverified: $isEmailVerified");
    if (!isEmailVerified) {
      final user = authProvider.firebaseAuth.currentUser!;

      await user.sendEmailVerification();
      Toasty.success("A verification link has been send to your email");
      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
      if (mounted)
        setState(() {
          canResendEmail = false;
          isLoading = false;
        });

      await Future.delayed(Duration(seconds: 5), () {
        setState(() => canResendEmail = true);
      });
    } else {
      isEmailVerified = true;
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  checkEmailAlreadyTaken() async {
    try {
      final QuerySnapshot result = await authProvider.firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.email, isEqualTo: email)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        debugLog("Email not exist");
        await createUserForEmailVerification();
      } else {
        if (mounted)
          setState(() {
            isLoading = false;
            Toasty.error("This email has already been taken.");
          });
      }
    } catch (e) {
      debugLog("Exception in connecting firebase: $e");
      Toasty.error("Some error occurred. Try again later");
    }
  }

  checkEmailVerified() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    await FirebaseAuth.instance.currentUser!.reload();
    if (mounted)
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    if (isEmailVerified) timer?.cancel();
  }

  Future<void> createUserForEmailVerification() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        if (FirebaseAuth.instance.currentUser!.email == email) {
          // print("both mail equal");
          await sendVerificationLinkToEmail();
        } else {
          //print("both mail not equal");
          final response = await authProvider
              .onlyCreateUserForEmailVerification(email, email);
          if (response) {
            await sendVerificationLinkToEmail();
          }
        }
      } else {
        //print("current user is null");
        final response =
            await authProvider.onlyCreateUserForEmailVerification(email, email);
        if (response) {
          await sendVerificationLinkToEmail();
        }
      }

      // if(FirebaseAuth.instance.currentUser==null) {
      //   final response =
      //   await authProvider.onlyCreateUserForEmailVerification(email, email);
      //   if (response) {
      //     await sendVerificationLinkToEmail();
      //   }
      // }else{
      //     await sendVerificationLinkToEmail();
      //
      // }
    } catch (e) {
      debugLog("Exception: $e");
      // if (e == "email-already-in-use") {
      //   debugLog("Email already in use");
      //   // FirebaseAuth.instance.
      //   // sendVerificationLinkToEmail();
      // }else
      Toasty.error(e.toString());
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  void userSignup(UserType userType, String name, String email,
      String countryCode, String phone, String password,
      [double perHourCharges = 0, String city = '']) async {
    try {
      if (AppFunctions.imagepath.isEmpty) {
        File f = await getImageFileFromAssets('assets/images/profile.png');
        AppFunctions.imagepath = f.path;
      }

      String fileName = AppFunctions.imagepath.split('/').last;
      if (kDebugMode) {
        // print("profileImagePath: ${profileImagePath}");
        // print("fileName: ${fileName}");
      }
      var data = {
        'signup_as': 'user',
        'name': name,
        'country_code': selectedCountry.phoneCode,
        'phone_code': countryCode,
        'email': email,
        'phone': phone,
        'password': password,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'image': await MultipartFile.fromFile(AppFunctions.imagepath,
            filename: fileName),
      };
      Navigator.pushNamed(context, MobileNumberInputScreen.route,
          arguments: {'data': data});
    } catch (e) {
      if (mounted)
        setState(() {
          isLoading = false;
        });
      debugLog("Dio error in signup: $e");

      Toasty.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    UserType userType = ModalRoute.of(context)!.settings.arguments as UserType;

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
                  40.SpaceY,
                  kLogoImage,
                  25.SpaceY,
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 100,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Enter Basic Details",
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
                        const SizedBox(height: kDefaultSpace * 3),
                        InkWell(
                          onTap: () async {
                            profileImage =
                                await AppFunctions.choosePhoto(context);
                            setState(() {});
                          },
                          child: Stack(
                            children: [
                              CircleProfile(
                                radius: 50,
                                image: profileImage,
                              ),
                              Positioned(
                                right: 5,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xffFF8E3C),
                                          Color(0xffB96C34)
                                        ],
                                      )),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.white,
                                    size: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: kDefaultSpace * 3),
                        PrimaryTextField(
                          labelText: "Full name",
                          'Full name',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter name'
                              : null,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          onChange: (value) {
                            name = value;
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PrimaryTextField(
                              initialValue: email,
                              labelText: "Email ID",
                              'Email ID',
                              validator: (value) =>
                                  value == null || !value.trim().isValidEmail()
                                      ? 'Enter email address'
                                      : null,
                              keyboardType: TextInputType.emailAddress,
                              onChange: (value) {
                                email = value.trim();
                                setState(() {
                                  isEmailVerified = false;
                                });
                              },
                            ),
                            isLoading
                                ? SizedBox.shrink()
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: AppColors.orange,
                                    ),
                                    onPressed: canResendEmail || !isLoading
                                        ? () async {
                                            if (email.isEmpty) {
                                              Toasty.error(
                                                  "Please enter email");
                                              return;
                                            }

                                            if (!isEmailVerified) {
                                              if (mounted)
                                                setState(() {
                                                  isLoading = true;
                                                });
                                              await checkEmailAlreadyTaken();
                                            }
                                          }
                                        : null,
                                    child: Text(isEmailVerified
                                        ? "Verified"
                                        : "Verify"),
                                  ),
                          ],
                        ),
                        // PhoneTextField(
                        //   selectedCountry: selectedCountry,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter phone number';
                        //     } else if (!value.trim().isValidNumbers()) {
                        //       return 'Only numbers are allowed';
                        //     } else if (value.trim().length != 10) {
                        //       return 'Invalid mobile number. Only 9-10 digits are allowed.';
                        //     }
                        //     return null;
                        //   },
                        //   onChange: (country, phone) {
                        //     if (country != null) {
                        //       setState(() {
                        //         selectedCountry = country;
                        //       });
                        //     }
                        //     if (phone != null) {
                        //       setState(() {
                        //         this.phone = phone.trim();
                        //       });
                        //     }
                        //   },
                        // ),
                        PrimaryTextField(
                          labelText: "Password",
                          'Password',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          hideText: hidePassword,
                          suffixIcon: hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          suffixIconOnTap: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          onChange: (value) {
                            password = value;
                          },
                        ),
                        PrimaryTextField(
                          labelText: "Confirm Password",
                          'Confirm Password',
                          suffixIcon: hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          hideText: hideConfirmPassword,
                          suffixIconOnTap: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value != password) {
                              return 'Passwords do no not match';
                            }
                            return null;
                          },
                          onChange: (value) {
                            confirmPassword = value;
                          },
                        ),
                        PrimaryTextField(
                          'Location',
                          controller: locationController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }

                            return null;
                          },
                          readOnly: true,
                          onTap: () async {
                            try {
                              LocationResult locationResult =
                                  await showPlacePicker(context);
                              LatLng? latLng = locationResult.latLng;
                              String? formattedAddress =
                                  locationResult.formattedAddress;
                              if (formattedAddress != null) {
                                locationController.text = formattedAddress;
                                city = locationResult.city != null
                                    ? locationResult.city!.name ?? ''
                                    : '';
                                country = locationResult.country != null
                                    ? locationResult.country!.name ?? ''
                                    : '';
                                state = locationResult.locality ?? '';
                                postalCode = locationResult.postalCode ?? '';
                                address = locationResult.formattedAddress ?? '';
                                latitude = latLng != null ? latLng.latitude : 0;
                                longitude =
                                    latLng != null ? latLng.longitude : 0;
                                if (mounted) setState(() {});
                              }
                            } catch (e) {
                              debugLog("Error in picking location: $e");
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                                // fillColor: MaterialStateProperty.all<Color>(
                                //     AppColors.orange),
                                side: BorderSide(
                                    color: AppColors.orange, width: 2),
                                activeColor: AppColors.orange,
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
                        const SizedBox(
                          height: kDefaultSpace * 3,
                        ),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.orange),
                              )
                            : GradientButton(
                                text: 'Sign Up',
                                onPress: () {
                                  if (!isEmailVerified) {
                                    Toasty.error("Email not verified.");
                                    return;
                                  }
                                  if (FirebaseAuth.instance.currentUser !=
                                      null) {
                                    print("user not nulll");
                                    if (FirebaseAuth.instance.currentUser!
                                            .emailVerified !=
                                        true) {
                                      Toasty.error("Email not verified.");
                                      return;
                                    }
                                  }
                                  //Navigator.pushNamed(context, UserHomeScreen.route);
                                  // if (profileImagePath.isEmpty) {
                                  //   Toasty.error('Choose profile photo');
                                  // } else
                                  if (_formKey.currentState!.validate()) {
                                    // if (phone.isEmpty) {
                                    //   Toasty.error('Enter phone number');
                                    //   return;
                                    // }

                                    setState(() {
                                      isLoading = true;
                                    });
                                    debugLog('phone:$phone');
                                    userSignup(
                                        userType,
                                        name,
                                        email,
                                        '+${selectedCountry.countryCode}',
                                        phone,
                                        password,
                                        charges,
                                        city);
                                  }
                                },
                              ),
                        const SizedBox(height: kDefaultSpace * 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                            ),
                            const SizedBox(width: 6.0),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                // Navigator.pushNamed(context, UserLoginScreen.route,
                                //     arguments: userType);
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(color: AppColors.orange),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: kDefaultSpace * 2)
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

  Future<void> requestLocationPermission() async {
    //final serviceStatusLocation = await Permission.locationWhenInUse.isGranted ;
    //bool isLocation = serviceStatusLocation == ServiceStatus.enabled;

    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      // print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      // print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      // print('Permission Permanently Denied');
      await openAppSettings();
    }
  }
}
