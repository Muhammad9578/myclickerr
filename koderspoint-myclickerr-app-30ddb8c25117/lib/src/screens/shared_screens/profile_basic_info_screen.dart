import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/user.dart';
import '../../controllers/user_side_controllers/user_controller.dart';
import '../../widgets/circle_profile.dart';
import '../../widgets/custom_appbar.dart';
import '../user_screens/u_profile_screens/u_edit_profile_screen.dart';

class ProfileBasicInfoScreen extends StatefulWidget {
  static const route = "photographerProfileMainScreen";

  const ProfileBasicInfoScreen({Key? key}) : super(key: key);

  @override
  State<ProfileBasicInfoScreen> createState() => _ProfileBasicInfoScreenState();
}

class _ProfileBasicInfoScreenState extends State<ProfileBasicInfoScreen> {
  late UserController userProvider;
  User? loggedInUser;

  getUserData() {
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          if (profileBasicInfoScreenRefreshController.isRefresh)
            profileBasicInfoScreenRefreshController.refreshCompleted();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserController>(context, listen: false);
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Basic Information", action: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, UserEditProfileScreen.route);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 20, left: 18),
              child: Text(
                "Edit",
                style: MyTextStyle.boldBlack.copyWith(
                  color: AppColors.orange,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ]),
        body: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: loggedInUser == null
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                )
              : SmartRefresher(
                  controller: profileBasicInfoScreenRefreshController,
                  onRefresh: () {
                    // // print("loggedInUser!.id: ${loggedInUser.id}");
                    // setState(() {});
                    getUserData();
                    // fetchBankDetails(loggedInUser.id);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.SpaceY,
                      Center(
                        child: Stack(
                          children: [
                            CircleProfile(
                              radius: 50,
                              image: loggedInUser!.profileImage.isEmpty
                                  ? Image.asset(
                                      ImageAsset.PlaceholderImg,
                                    )
                                  : Image.network(
                                      loggedInUser!.profileImage,
                                    ),
                            ),
                            Positioned(
                              right: 0,
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
                      30.SpaceY,
                      Text(
                        "Full name",
                        style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                      ),
                      5.SpaceY,
                      Text(
                        "${loggedInUser!.name}",
                        style:
                            MyTextStyle.semiBold085Black.copyWith(fontSize: 18),
                      ),
                      20.SpaceY,
                      Text(
                        SessionHelper.userType == "1" ? 'Email' : "Skills",
                        style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                      ),
                      5.SpaceY,
                      Text(
                        SessionHelper.userType == "1"
                            ? "${loggedInUser!.email}"
                            : "${loggedInUser!.skills ?? 'Not provided'}",
                        style:
                            MyTextStyle.semiBold085Black.copyWith(fontSize: 18),
                      ),
                      20.SpaceY,
                      Text(
                        "Short bio",
                        style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                      ),
                      5.SpaceY,
                      Text(
                        "${loggedInUser!.shortBio != "" ? loggedInUser!.shortBio : "Not provided"}",
                        style:
                            MyTextStyle.semiBold085Black.copyWith(fontSize: 18),
                      ),
                      20.SpaceY,
                      Text(
                        'Phone No',
                        style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                      ),
                      5.SpaceY,
                      Text(
                        CountryService()
                                    .findByCode(
                                        loggedInUser!.countryCode.contains('+')
                                            ? loggedInUser!.countryCode
                                                .replaceAll('+', '')
                                            : loggedInUser!.countryCode)
                                    ?.phoneCode ==
                                null
                            ? "${loggedInUser!.countryCode} ${loggedInUser!.phone}"
                            : "+${CountryService().findByCode(loggedInUser!.countryCode.replaceAll('+', ''))?.phoneCode} ${loggedInUser!.phone}",
                        style:
                            MyTextStyle.semiBold085Black.copyWith(fontSize: 18),
                      ),
                      20.SpaceY,
                      Visibility(
                        visible: SessionHelper.userType == "2",
                        child: Text(
                          'Per Hour price',
                          style:
                              MyTextStyle.medium07Black.copyWith(fontSize: 14),
                        ),
                      ),
                      5.SpaceY,
                      Visibility(
                        visible: SessionHelper.userType == "2",
                        child: Text(
                          "${"${loggedInUser!.perHourPrice} ₹" ?? "Not provided"}",
                          style: MyTextStyle.semiBold085Black
                              .copyWith(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
