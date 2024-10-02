import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/screens/shared_screens/user_login_screen.dart';
import 'package:photo_lab/src/widgets/buttons.dart';

class ProfileSelectionScreen extends StatefulWidget {
  static String route = "profileSelectionScreen";

  const ProfileSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    // double w = MediaQuery.of(context).size.width;
    //double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 25.0, top: 90, right: 25, bottom: 25),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                // bottom: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "Select your profile to proceed",
                      style: MyTextStyle.boldBlack.copyWith(
                        fontSize: 34,
                      ),
                    ),
                    58.SpaceY,
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ProfileContainer(
                                  image: ImageAsset.UserImage,
                                  title: "User",
                                  index: 0),
                              20.SpaceY,
                              TickContainer(index: 0)
                            ],
                          ),
                        ),

                        20.SpaceX,

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ProfileContainer(
                                  image: ImageAsset.PhotographerImage,
                                  title: "Photographer",
                                  index: 1),
                              20.SpaceY,
                              TickContainer(index: 1)
                            ],
                          ),
                        ),

                        // Flexible(
                        //     fit: FlexFit.loose,
                        //     child: Image.asset(ImageAsset.PhotographerImage))
                      ],
                    ),

                    // ElevatedButton(onPressed: () {
                    //   Navigator.pushNamed(context, SplashScreen.route,);
                    // }, child: Text("Splash")),
                  ],
                ),
              ),
              Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: GradientButton(
                      text: "Continue",
                      icon: Icons.arrow_forward_ios_rounded,
                      onPress: () {
                        if (selected == 0) {
                          SessionHelper.userType = "1";
                          Navigator.pushNamed(context, UserLoginScreen.route,
                              arguments: UserType.user);
                          // SessionHelper.getUser().then((value) {
                          //   if (value != null && value.perHourPrice.isEmpty) {
                          //     Navigator.pushNamed(context, UserHomeStartup.route,
                          //         arguments: UserType.user);
                          //   } else {
                          //
                          //   }
                          // });
                        } else {
                          SessionHelper.userType = "2";
                          Navigator.pushNamed(context, UserLoginScreen.route,
                              arguments: UserType.photographer);
                          // SessionHelper.getUser().then((value) {
                          //   if (value != null && value.perHourPrice.isEmpty) {
                          //     Navigator.pushNamed(context, PhotographerHomeStartup.route,
                          //         arguments: UserType.photographer);
                          //   } else {
                          //
                          //   }
                          // });
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }

  Widget TickContainer({index}) {
    return Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.8,
          color: selected == index
              ? AppColors.orange
              : AppColors.orange.withOpacity(0.4),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: 18,
        color: selected == index
            ? AppColors.orange
            : AppColors.orange.withOpacity(0.4),
      ),
    );
  }

  Widget ProfileContainer({title, index, image}) {
    return Container(
      // width: 200,
      // height: 200,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected == index
                ? AppColors.orange
                : AppColors.orange.withOpacity(0),
            width: 1,
          )),
      child: InkWell(
        onTap: () {
          setState(() {
            selected = index;
          });
        },
        child: Ink(
          child: Stack(
            children: [
              Positioned(
                top: 15,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "$title",
                    style: MyTextStyle.medium07Black.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Image.asset(image, fit: BoxFit.fitWidth),
            ],
          ),
        ),
      ),
    );
  }
}
