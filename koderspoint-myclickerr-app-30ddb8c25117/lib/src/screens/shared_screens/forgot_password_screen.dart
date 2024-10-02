import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/shared_controllers/sharedcontroller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String route = 'forgot_password_screen';

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = '';

  final _formKey = GlobalKey<FormState>();

  late SharedController sharedController;

  @override
  Widget build(BuildContext context) {
    final UserType userType =
        ModalRoute.of(context)!.settings.arguments as UserType;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 10,
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
                  //physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Forget Password",
                            style: MyTextStyle.boldBlack.copyWith(
                              fontSize: 34,
                            ),
                          ),
                          10.SpaceY,
                          Text(
                            "Enter your email to reset password",
                            style: MyTextStyle.medium07Black.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          30.SpaceY,
                          PrimaryTextField(
                            'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your registered email address';
                              } else {
                                return null;
                              }
                            },
                            onChange: (value) {
                              email = value;
                            },
                          ),
                          const SizedBox(height: 28),
                          Consumer<SharedController>(
                              builder: (context, sharedcontroller, _) {
                            return sharedcontroller.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: AppColors.orange,
                                  ))
                                : GradientButton(
                                    text: 'Reset Password',
                                    onPress: () {
                                      closeKeyboard(context);
                                      if (_formKey.currentState!.validate()) {
                                        sharedcontroller.forgotPassword(
                                            context, email, userType);
                                      }
                                    },
                                  );
                          })
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
