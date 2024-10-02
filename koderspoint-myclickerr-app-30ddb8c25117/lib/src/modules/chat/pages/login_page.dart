import 'package:flutter/material.dart';
import 'package:photo_lab/src/modules/chat/constants/app_constants.dart';
import 'package:photo_lab/src/modules/chat/constants/color_constants.dart';
import 'package:photo_lab/src/modules/chat/controllers/auth_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_lab/src/widgets/loading_view.dart';
import 'package:provider/provider.dart';
import 'pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    AuthController authProvider = Provider.of<AuthController>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            AppConstants.loginTitle,
            style: TextStyle(color: ColorConstants.primaryColor),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Center(
              child: TextButton(
                onPressed: () async {
                  authProvider.handleSignIn().then((isSuccess) {
                    if (isSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }
                  }).catchError((error, stackTrace) {
                    Fluttertoast.showToast(msg: error.toString());
                    authProvider.handleException();
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) return const Color(0xffdd4b39).withOpacity(0.8);
                      return const Color(0xffdd4b39);
                    },
                  ),
                  splashFactory: NoSplash.splashFactory,
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.fromLTRB(30, 15, 30, 15),
                  ),
                ),
                child: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            // Loading
            Positioned(
              child: authProvider.status == Status.authenticating ? const LoadingView() : const SizedBox.shrink(),
            ),
          ],
        ));
  }
}
