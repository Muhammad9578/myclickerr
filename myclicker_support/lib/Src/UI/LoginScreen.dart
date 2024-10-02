// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:myclicker_support/Src/UI/SignupPage.dart';
import 'package:myclicker_support/Src/Utils/Extensions.dart';
import 'package:myclicker_support/Src/Utils/Toast.dart';
import '../Utils/Constants.dart';
import '../Utils/Functions.dart';
import '../Utils/Widgets.dart';
import 'ChatHomepage.dart';
import 'ChatScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool hidePassword = true;
  FirebaseAuth firebaseauth = FirebaseAuth.instance;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
                        const SizedBox(height: kDefaultSpace * 3),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              closeKeyboard(context);

                              // Navigator.pushNamed(
                              //     context, ForgotPasswordScreen.route,
                              //     arguments: userType);
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
                                    color: kProgressColor),
                              )
                            : GradientButton(
                                text: 'Log In',
                                onPress: () {
                                  closeKeyboard(context);

                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    loginUser();
                                  }
                                },
                              ),
                        20.SpaceY,
                        PrimaryButton(
                          text: 'Sign up',
                          onPress: () {
                            closeKeyboard(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupScreen()));
                          },
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

  Future<void> loginUser() async {
    try {
      UserCredential userCredential =
          await firebaseauth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      var supportdocref = FirebaseFirestore.instance
          .collection(FirestoreConstants.supportpersons)
          .doc(FirestoreConstants.supportpersons.toLowerCase());
      var token = await FirebaseMessaging.instance.getToken();
      var userDocument = await supportdocref.get();
      List<String> exsitingusers =
          List<String>.from(userDocument.data()!["usersids"]);

      if (exsitingusers.contains(userCredential.user!.uid)) {
        await supportdocref.update({FirestoreConstants.pushToken: token});
        Toasty.success("Login successful");
        print('Login successful: ${userCredential.user!.uid}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatHomePage()));
      } else {
        Toasty.error("Enter Correct Credential");
      }

      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      Toasty.error(e.toString());
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Toasty.error("An error occurred while logging in.");
      setState(() {
        isLoading = false;
      });
    }
  }
}
