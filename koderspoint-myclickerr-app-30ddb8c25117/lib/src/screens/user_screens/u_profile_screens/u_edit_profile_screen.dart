import 'dart:core';

import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/widgets/circle_profile.dart';
import 'package:photo_lab/src/widgets/phone_text_field.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom_appbar.dart';

class UserEditProfileScreen extends StatefulWidget {
  static const String route = "userEditProfileScreen";

  const UserEditProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  String name = '';
  String email = '';
  String phone = '12233';
  String password = '';
  String confirmPassword = '';
  double charges = 0;
  String city = '';
  String state = '';
  String country = '';
  String postalCode = '';
  String address = '';
  double latitude = 0;
  double longitude = 0;
  String skills = '';
  String shortBio = '';
  Country selectedCountry = CountryService().findByCode('IN')!;
  Image profileImage = Image.asset(ImageAsset.PlaceholderImg);
  late String userType;

  final _formKey = GlobalKey<FormState>();

  late UserController userController;
  var phoneController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    AppFunctions.imagepath = '';
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          userType = SessionHelper.userType!;
          name = loggedInUser.name;
          email = loggedInUser.email;
          phone = loggedInUser.phone;
          selectedCountry = CountryService()
              .findByCode(loggedInUser.countryCode.replaceAll('+', ''))!;
          // }
          if (userType == "2") {
            skills = loggedInUser.skills ?? "Skills not provided";
            charges = double.parse(loggedInUser.perHourPrice.toString());
          }
          shortBio = loggedInUser.shortBio ?? 'Not provided';
          phoneController.text = loggedInUser.phone;
          profileImage = loggedInUser.profileImage.isEmpty
              ? Image.asset(
                  ImageAsset.PlaceholderImg,
                )
              : Image.network(
                  loggedInUser.profileImage,
                );
        });
      }
    });
  }

  void updateProfile(
    String name,
    String countryCode,
    String phone,
    skills,
    shortBio,
  ) async {
    String fileName = AppFunctions.imagepath.split('/').last;
    var data = {
      'user_id': loggedInUser!.id,
      'name': name,
      'country_code': selectedCountry.phoneCode,
      'phone_code': countryCode,
      'phone': phone,
    };

    if (userType == "2") {
      data['per_hour_price'] = charges;
      data['skills'] = skills;
      data['short_bio'] = shortBio;
    }

    if (AppFunctions.imagepath.isNotEmpty) {
      data['image'] = await MultipartFile.fromFile(AppFunctions.imagepath,
          filename: fileName);
    }
    userController.updateProfilefun(name, countryCode, phone, skills, shortBio,
        data, context, loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Edit Profile", action: []),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: loggedInUser == null
              ? CircularProgressIndicator(
                  color: AppColors.orange,
                )
              : Consumer<UserController>(builder: (context, usercont, _) {
                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                            initialValue: name,
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
                          PhoneTextField(
                            phone: phone,
                            controller: phoneController,
                            selectedCountry: selectedCountry,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              } else if (!value.trim().isValidNumbers()) {
                                return 'Only numbers are allowed';
                              } else if (value.trim().length != 10) {
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
                          ...userType == "2"
                              ? [
                                  PrimaryTextField(
                                    labelText: 'Per Hour Charges',
                                    initialValue: charges.toString(),
                                    'Per Hour Charges',
                                    validator: (value) {
                                      if (userType == UserType.photographer) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter per hour charges';
                                        }
                                      }
                                      return null;
                                    },
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChange: (value) {
                                      charges = double.parse(value);
                                    },
                                  ),
                                  // PrimaryTextField(
                                  //   'Location',
                                  //   controller: locationController,
                                  //   validator: (value) {
                                  //     if (userType == UserType.photographer) {
                                  //       if (value == null || value.isEmpty) {
                                  //         return 'Please enter location';
                                  //       }
                                  //     }
                                  //     return null;
                                  //   },
                                  //   /*onChange: (value) {
                                  //                 location = value;
                                  //               },*/
                                  //   readOnly: true,
                                  //   onTap: () async {
                                  //     /*Navigator.of(context).push(
                                  //                   MaterialPageRoute(
                                  //                     builder: (_) => MapScreen(),
                                  //                   ),
                                  //                 );*/
                                  //     //requestLocationPermission();
                                  //     LocationResult locationResult =
                                  //     await showPlacePicker(context);
                                  //     LatLng? latLng = locationResult.latLng;
                                  //     String? formattedAddress =
                                  //         locationResult.formattedAddress;
                                  //     if (formattedAddress != null) {
                                  //       locationController.text =
                                  //           formattedAddress;
                                  //       city = locationResult.city != null
                                  //           ? locationResult.city!.name ?? ''
                                  //           : '';
                                  //       country = locationResult.country != null
                                  //           ? locationResult.country!.name ?? ''
                                  //           : '';
                                  //       state = locationResult.locality ?? '';
                                  //       postalCode =
                                  //           locationResult.postalCode ?? '';
                                  //       address =
                                  //           locationResult.formattedAddress ?? '';
                                  //       latitude =
                                  //       latLng != null ? latLng.latitude : 0;
                                  //       longitude =
                                  //       latLng != null ? latLng.longitude : 0;
                                  //
                                  //       setState(() {});
                                  //     }
                                  //     //requestLocationPermission();
                                  //   },
                                  // ),
                                  PrimaryTextField(
                                    initialValue: skills,
                                    lines: 2,
                                    labelText: "Skills",
                                    'Skills',
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Please enter skills'
                                            : null,
                                    onChange: (value) {
                                      skills = value;
                                    },
                                  ),
                                  PrimaryTextField(
                                    lines: 3,
                                    initialValue: shortBio,
                                    labelText: "Short Bio",
                                    'Short Bio',
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Please enter short bio'
                                            : null,
                                    onChange: (value) {
                                      shortBio = value;
                                    },
                                  ),
                                ]
                              : [],
                          const SizedBox(
                            height: kDefaultSpace * 3,
                          ),
                          userController.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.orange),
                                )
                              : GradientButton(
                                  text: 'Update',
                                  onPress: () {
                                    if (_formKey.currentState!.validate()) {
                                      debugLog(
                                          "SessionHelper.userType: ${SessionHelper.userType}");
                                      updateProfile(
                                        name,
                                        '${selectedCountry.countryCode}',
                                        phone,
                                        skills,
                                        shortBio,
                                      );
                                    }
                                  },
                                ),
                          const SizedBox(height: kDefaultSpace * 3),
                        ],
                      ),
                    ),
                  );
                }),
        ),
      ),
    );
  }
}
