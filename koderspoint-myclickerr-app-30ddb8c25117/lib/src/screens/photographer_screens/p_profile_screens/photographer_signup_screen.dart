import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/circle_profile.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:provider/provider.dart';

import '../../../controllers/user_side_controllers/user_controller.dart';
import '../../../helpers/helpers.dart';
import '../../../modules/chat/constants/firestore_constants.dart';
import '../../../modules/chat/controllers/auth_controller.dart';
import '../../shared_screens/phone_number_input_screen.dart';

class PhotographerSignupScreen extends StatefulWidget {
  static const String route = "photographer_signup_screen";

  const PhotographerSignupScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerSignupScreen> createState() =>
      _PhotographerSignupScreenState();
}

class _PhotographerSignupScreenState extends State<PhotographerSignupScreen> {
  String name = '';
  String email = '';
  String phone = '';
  String dob = '';
  String password = '';
  double charges = 0;
  String confirmPassword = '';
  String skills = '';
  String shortBio = '';
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  String date = '';
  String gender = "male";

  String state = '';
  String country = '';
  String postalCode = '';
  String city = '';
  String address = '';
  double latitude = 0;
  double longitude = 0;

  Country selectedCountry = CountryService().findByCode('IN')!;
  Image profileImage = Image.asset(ImageAsset.PlaceholderImg);

  var dobController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = true;
  bool isLoading = false;
  late UserController userProvider;
  late AuthController authProvider;

  final _formKey = GlobalKey<FormState>();

  // final appCheck = FirebaseAppCheck.instance;

  @override
  void initState() {
    super.initState();
    AppFunctions.imagepath = '';
    // appCheck.onTokenChange.listen(setEventToken);
    authProvider = Provider.of<AuthController>(context, listen: false);
    userProvider = context.read<UserController>();
    // checkEmailExistVerified();
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

  Future<void> createUserForEmailVerification() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        if (FirebaseAuth.instance.currentUser!.email == email) {
          //   print("both mail equal");
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
        // print("current user is null");
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
      Toasty.success("Email already verified.");

      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (mounted)
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

    if (isEmailVerified) timer?.cancel();
  }

  List<Map<String, String>> creatingTimeSLotJson() {
    List<Map<String, String>> timeSlots = [];
    photographerAvailabilityList.forEach((element) {
      Map<String, String> slot = {'time': element};
      timeSlots.add(slot);
    });

    return timeSlots;
  }

  void signup(UserType userType, String name, String email, String countryCode,
      String phone, String password, skills, shortBio,
      [double perHourCharges = 0, String city = '']) async {
    try {
      if (AppFunctions.imagepath.isEmpty) {
        File f = await getImageFileFromAssets('assets/images/profile.png');
        AppFunctions.imagepath = f.path;
      }
      String fileName = AppFunctions.imagepath.split('/').last;
      print("file name: $AppFunctions.imagepath");
      var data = {
        'signup_as': 'photographer',
        'name': name.trim(),
        'gender': gender,
        'dob': date,
        'email': email.trim(),

        'password': password,
        'image': await MultipartFile.fromFile(AppFunctions.imagepath,
            filename: fileName),
        'per_hour_price': '$perHourCharges',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'city': city,
        // 'skills': skills,
        'short_bio': shortBio,
        'is_available': 1,
        'timeslots': jsonEncode(creatingTimeSLotJson()),
      };

      Navigator.pushNamed(context, MobileNumberInputScreen.route,
          arguments: {'data': data});
      // signup2(data);
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
                  24.SpaceY,
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
                        height: 9,
                        width: MediaQuery.of(context).size.width * 0.30,
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
            left: 0,
            right: 0,
            top: 115,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        10.SpaceY,
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
                          onChange: (value) {
                            name = value;
                          },
                        ),
                        PrimaryTextField(
                          labelText: 'Date of Birth',
                          '21 July, 2021',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter date of birth'
                              : null,
                          readOnly: true,
                          controller: startDateController,
                          suffixIcon: Icons.calendar_month_outlined,
                          // prefixIcon:
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.utc(1990),
                              firstDate: DateTime.utc(1910),
                              //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime.utc(DateTime.now().year - 17),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.orange,
                                      onPrimary: AppColors.white,
                                      //onSurface: Colors.blueAccent, // <-- SEE HERE
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                          foregroundColor: AppColors.orange
                                          /*foregroundColor: AppColors.orange,*/
                                          ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              debugLog(
                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate =
                                  DateFormat('dd MMM yyyy').format(pickedDate);
                              debugLog(
                                  formattedDate); //formatted date output using intl package =>  2021-03-16
                              startDateController.text = formattedDate;
                              // date = formattedDate;
                              date =
                                  pickedDate.millisecondsSinceEpoch.toString();
                            }
                          },
                        ),
                        2.SpaceY,
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              " Gender",
                              style: MyTextStyle.medium07Black
                                  .copyWith(fontSize: 16),
                            )),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: RadioListTile(
                                contentPadding:
                                    EdgeInsets.only(left: 0, top: 0, right: 0),
                                isThreeLine: false,
                                activeColor: AppColors.kOnPrimaryColor,
                                title: Row(
                                  children: [
                                    // Icon(
                                    //   MdiIcons.genderMale,
                                    //   color: AppColors.kOnPrimaryColor,
                                    // ),
                                    Image.asset(ImageAsset.MaleIcon,
                                      height: 20,width: 20, color: AppColors.kOnPrimaryColor,),
                                    5.SpaceX,
                                    Text("Male"),
                                  ],
                                ),
                                value: "male",
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: RadioListTile(
                                isThreeLine: false,
                                activeColor: AppColors.kOnPrimaryColor,
                                contentPadding:
                                    EdgeInsets.only(left: 0, top: 0, right: 0),
                                title: Row(
                                  children: [
                                    // Icon(
                                    //   MdiIcons.genderFemale,
                                    //   color: AppColors.kOnPrimaryColor,
                                    // ),
                                    Image.asset(ImageAsset.FemaleIcon,
                                      height: 20,width: 20, color: AppColors.kOnPrimaryColor,),
                                    5.SpaceX,
                                    Text("Female"),
                                  ],
                                ),
                                value: "female",
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value.toString();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PrimaryTextField(
                              initialValue: email,
                              labelText: "Email ID",
                              'Email Id',
                              validator: (value) =>
                                  value == null || !value.trim().isValidEmail()
                                      ? 'Please enter valid email'
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
                        PrimaryTextField(
                          labelText: "Confirm Password",
                          'Confirm Password',
                          suffixIcon: hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          suffixIconOnTap: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                          hideText: hideConfirmPassword,
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
                          labelText: "Per Hour Charges",
                          'Per Hour Charges',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter per hour charges';
                            }
                            if (!value.trim().isValidNumbers()) {
                              return 'Only numbers are allowed';
                            }

                            return null;
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChange: (value) {
                            charges = double.parse(value.trim());
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
                              //requestLocationPermission();
                            } catch (e) {
                              debugLog("Error in picking location: $e");
                            }
                          },
                        ),
                        // PrimaryTextField(
                        //   lines: 2,
                        //   labelText: "Skills",
                        //   'Skills',
                        //   validator: (value) => value == null || value.isEmpty
                        //       ? 'Please enter skills'
                        //       : null,
                        //   onChange: (value) {
                        //     skills = value;
                        //   },
                        // ),
                        PrimaryTextField(
                          lines: 3,
                          labelText: "Short Bio",
                          'Short Bio',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter short bio'
                              : null,
                          onChange: (value) {
                            shortBio = value;
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
                          height: kDefaultSpace * 2,
                        ),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.orange),
                              )
                            : GradientButton(
                                text: 'Next',
                                onPress: ()

                                    // {
                                    //   Navigator.pushNamed(
                                    //     context,
                                    //     PhotographerVerificationSuccessfulScreen
                                    //         .route,
                                    //   );
                                    // },

                                    {
                                  if (AppFunctions.imagepath.isEmpty) {
                                    Toasty.error('Choose profile photo');
                                    return;
                                  }
                                  if (!isEmailVerified) {
                                    Toasty.error("Email not verified.");
                                    return;
                                  }

                                  if (_formKey.currentState!.validate()) {
                                    // setState(() {
                                    //   isLoading = true;
                                    // });
                                    signup(
                                      userType,
                                      name,
                                      email,
                                      '+${selectedCountry.countryCode}',
                                      phone,
                                      password,
                                      skills,
                                      shortBio,
                                      charges,
                                      city,
                                    );
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
                                Navigator.pop(context);
                                // Navigator.pushNamed(
                                //     context, UserLoginScreen.route,
                                //     arguments: UserType.photographer);
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(color: AppColors.orange),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: kDefaultSpace * 3,
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
