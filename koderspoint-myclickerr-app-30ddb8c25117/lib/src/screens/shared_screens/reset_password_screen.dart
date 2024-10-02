import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/shared_controllers/sharedcontroller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String route = 'reset_password_screen';
  final String email;
  final UserType userType;

  const ResetPasswordScreen(
      {required this.email, required this.userType, Key? key})
      : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String password = '';
  String confirmPassword = '';
  // bool isLoading = false;

  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late SharedController sharedcontroller;
  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    sharedcontroller = Provider.of<SharedController>(context, listen: false);
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
                  25.SpaceY,
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 150,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Reset Password",
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
                          'Email',
                          controller: emailController,
                          readOnly: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        PrimaryTextField(
                          'Password',
                          hideText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password';
                            } else if (password.length < 6) {
                              return 'Password must be at least 6 characters long';
                            } else {
                              return null;
                            }
                          },
                          onChange: (value) {
                            password = value;
                          },
                        ),
                        PrimaryTextField(
                          'Confirm Password',
                          hideText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password again';
                            } else if (value != password) {
                              return 'Passwords do not match';
                            } else {
                              return null;
                            }
                          },
                          onChange: (value) {
                            confirmPassword = value;
                          },
                        ),
                        const SizedBox(
                          height: kDefaultSpace * 3,
                        ),
                        Consumer<SharedController>(
                            builder: (context, sharedcontroller, _) {
                          return sharedcontroller.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: AppColors.orange,
                                ))
                              : GradientButton(
                                  text: 'Update Password',
                                  onPress: () {
                                    if (_formKey.currentState!.validate()) {
                                      sharedcontroller.updatePassword(
                                          context, widget.email, password);
                                    }
                                  },
                                );
                        }),
                        const SizedBox(
                          height: kDefaultSpace,
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
}
