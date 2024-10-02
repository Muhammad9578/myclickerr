import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myclicker_support/Src/Utils/Extensions.dart';
import '../Utils/Constants.dart';
import '../Utils/Functions.dart';
import '../Utils/Toast.dart';
import '../Utils/Widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
  Image profileImage = Image.asset(ImageAsset.placeholderimg);
  String profileImagePath = '';

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController locationController = TextEditingController();
  FirebaseAuth firebaseauth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
  }

  void choosePhoto() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              child: const Row(
                children: [
                  Icon(
                    Icons.image,
                    color: kPrimaryButtonColor,
                    size: 22,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Gallery',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, "gallery");
              },
            ),
            const SizedBox(width: 6),
            SimpleDialogOption(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
              child: const Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: kPrimaryButtonColor,
                    size: 22,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Camera',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, "camera");
              },
            )
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(
        source: result == "gallery" ? ImageSource.gallery : ImageSource.camera,
        maxHeight: 500,
        maxWidth: 500);
    if (image != null) {
      profileImagePath = image.path;
      setState(() {
        profileImage = Image.file(
          File(profileImagePath),
          fit: BoxFit.cover,
        );
      });
    }
  }

  Future<void> signUpUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential =
          await firebaseauth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String? fcm = await firebaseMessaging.getToken();
      // Store additional user data in Firestore
      addUserToSupportCollection(userCredential, email, fcm ?? "");
      // User signup successful

      debugLog(userCredential.user!.uid);
      Toasty.success('Signup successful');
      if (mounted) {
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      }

      print('Signup successful: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      setState(() {
        Toasty.error(e.message!);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        Toasty.error("An error occurred while signing up.");
      });
    }
  }

  void addUserToSupportCollection(
      UserCredential userCredential, String email, String fcmToken) async {
    final supportPersonsCollection = FirebaseFirestore.instance
        .collection(FirestoreConstants.supportpersons);
    final supportDocument = supportPersonsCollection
        .doc(FirestoreConstants.supportpersons.toLowerCase());

    DocumentSnapshot supportDocumentSnapshot = await supportDocument.get();

    if (supportDocumentSnapshot.exists) {
      // Update the existing document by adding user data
      supportDocument.update({
        'emails': FieldValue.arrayUnion([email]),
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        'usersids': FieldValue.arrayUnion([userCredential.user!.uid]),
        FirestoreConstants.isOnline: true,
      });
    } else {
      // Create a new document if it doesn't exist
      supportDocument.set({
        'emails': [email],
        'fcmTokens': [fcmToken],
        'usersids': [userCredential.user!.uid],
        'unreadMessages': 0,
        FirestoreConstants.nickname: "Support Person",
        FirestoreConstants.photoUrl: "",
        FirestoreConstants.id: FirestoreConstants.supportpersons.toLowerCase(),
        FirestoreConstants.isOnline: true,
        FirestoreConstants.userType: "3",
        FirestoreConstants.createdAt:
            DateTime.now().millisecondsSinceEpoch.toString(),
        FirestoreConstants.chattingWith: null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  physics: const BouncingScrollPhysics(),
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
                        // InkWell(
                        //   onTap: () async {
                        //     choosePhoto();
                        //   },
                        //   child: Stack(
                        //     children: [
                        //       CircleProfile(
                        //         radius: 50,
                        //         image: profileImage,
                        //       ),
                        //       Positioned(
                        //         right: 5,
                        //         bottom: 0,
                        //         child: Container(
                        //           padding: const EdgeInsets.all(5),
                        //           decoration: const BoxDecoration(
                        //               shape: BoxShape.circle,
                        //               gradient: LinearGradient(
                        //                 colors: [
                        //                   Color(0xffFF8E3C),
                        //                   Color(0xffB96C34)
                        //                 ],
                        //               )),
                        //           child: const Icon(
                        //             Icons.camera_alt_outlined,
                        //             color: AppColors.white,
                        //             size: 18,
                        //           ),
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: kDefaultSpace * 3),
                        // PrimaryTextField(
                        //   labelText: "Full name",
                        //   'Full name',
                        //   validator: (value) => value == null || value.isEmpty
                        //       ? 'Please enter name'
                        //       : null,
                        //   keyboardType: TextInputType.name,
                        //   textCapitalization: TextCapitalization.words,
                        //   onChange: (value) {
                        //     name = value;
                        //   },
                        // ),
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
                              },
                            ),
                          ],
                        ),
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
                        const SizedBox(
                          height: kDefaultSpace * 3,
                        ),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: kProgressColor),
                              )
                            : GradientButton(
                                text: 'Sign Up',
                                onPress: () {
                                  if (_formKey.currentState!.validate()) {
                                    debugLog('phone:$phone');
                                    signUpUser();
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
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(color: kHighlightTextColor),
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
}
