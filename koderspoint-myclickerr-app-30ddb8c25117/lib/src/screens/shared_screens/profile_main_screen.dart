import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as au;
import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_home_startup.dart';
import 'package:photo_lab/src/screens/user_screens/u_home_startup.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/photographer_side_controllers/photographer_booking_list_controller.dart';
import '../../controllers/user_side_controllers/user_controller.dart';
import '../../helpers/toast.dart';
import '../../models/user.dart';
import '../../modules/chat/constants/firestore_constants.dart';
import '../../modules/chat/pages/support_chat_page.dart';
import '../photographer_screens/p_all_bookings/p_previous_booking_screen.dart';
import '../photographer_screens/p_portfolio_screens/p_portfolio_main.dart';
import '../photographer_screens/p_profile_screens/p_display_equipments_geears.dart';
import '../photographer_screens/p_profile_screens/p_timeslot_availability_screen.dart';
import '../photographer_screens/p_profile_screens/payment_info_screen.dart';
import '../user_screens/u_all_booking_screens/u_previous_booking_screen.dart';
import '../user_screens/u_payment_screens/payment_screen.dart';
import 'profile_basic_info_screen.dart';

class CombinedProfileMainScreen extends StatefulWidget {
  static const route = "combinedProfileMainScreen";

  const CombinedProfileMainScreen({Key? key}) : super(key: key);

  @override
  State<CombinedProfileMainScreen> createState() =>
      _CombinedProfileMainScreenState();
}

class _CombinedProfileMainScreenState extends State<CombinedProfileMainScreen> {
  late UserController userProvider;

  User? loggedInUser;

  getUserData() {
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
  }

  int unreadcounter = 0;
  late StreamSubscription unreadcounterlistener;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserController>(context, listen: false);

    getUserData();
    unreadcounterlistener = FirebaseFirestore.instance
        .collection(FirestoreConstants.supportpersons)
        .doc(FirestoreConstants.supportpersons.toLowerCase())
        .collection("chats")
        .doc(au.FirebaseAuth.instance.currentUser!.uid ?? "")
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          if (event.data()!.containsKey('unreadCounter')) {
            unreadcounter = event['unreadCounter'];
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PhotographerBookingListController photographerProvider =
        Provider.of<PhotographerBookingListController>(
      context,
    );
    print(
        "inside profile main,  SessionHelper.userType: ${SessionHelper.userType}");

    return WillPopScope(
      onWillPop: () async {
        if (SessionHelper.userType == '2') {
          print("photographer");
          Navigator.pushNamedAndRemoveUntil(
              context, PhotographerHomeStartup.route, (route) => false);
        } else {
          print("user");
          Navigator.pushNamedAndRemoveUntil(
              context, UserHomeStartup.route, (route) => false);
        }
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Profile"),
        body: Container(
          child: loggedInUser == null
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                )
              : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Center(
                    child: Column(
                      children: [
                        30.SpaceY,
                        Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.orange.withOpacity(0.9),
                              )),
                          child: CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: FadeInImage.assetNetwork(
                                  fit: BoxFit.cover,
                                  placeholder: ImageAsset.PlaceholderImg,
                                  // const AssetImage(ImageAsset.PlaceholderImg),
                                  image: loggedInUser!.profileImage
                                      .toString()
                                      .replaceFirst(
                                          'https://app.myclickerr.com/',
                                          'http://myclickerr.info/public/')
                                      .replaceFirst(
                                          'http://app.myclickerr.com/',
                                          'http://myclickerr.info/public/'),
                                  // Image.network(loggedInUser.profileImage),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset(
                                      ImageAsset.PlaceholderImg,
                                      fit: BoxFit.cover,
                                      // width: 50,
                                      // height: 50,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // CircleProfile(
                          //   radius: 50,
                          //   image: loggedInUser.profileImage.length != 0
                          //       ? Image.asset(
                          //           ImageAsset.PlaceholderImg,
                          //         )
                          //       : Image.network(loggedInUser.profileImage),
                          // ),
                        ),
                        15.SpaceY,
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: Text(
                            textAlign: TextAlign.center,
                            loggedInUser!.name,
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 22),
                          ),
                        ),
                        8.SpaceY,
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: Text(
                            textAlign: TextAlign.center,
                            loggedInUser!.skills ?? "",
                            style: MyTextStyle.semiBold07Black
                                .copyWith(fontSize: 14),
                          ),
                        ),
                        20.SpaceY,
                        SessionHelper.userType == '2' //for photographer side
                            ? Column(
                                children: [
                                  profileHeadingsBuild(
                                    title: "Basic Information",
                                    icon: Icons.person_outline_outlined,
                                    onPress: () async {
                                      Object? res = await Navigator.pushNamed(
                                          context,
                                          ProfileBasicInfoScreen.route);

                                      if (res == true) {
                                        debugLog(
                                            "Back from photographer basic info, res: $res");

                                        getUserData();
                                      }
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "My Portfolio",
                                    icon: Icons.work_history_outlined,
                                    onPress: () {
                                      Navigator.pushNamed(context,
                                          PhotographerPortfolioMainScreen.route,
                                          arguments: {'photographerId': null});
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Equipments and Gear",
                                    icon: Icons.camera_alt_outlined,
                                    onPress: () {
                                      Navigator.pushNamed(
                                          context,
                                          PhotographerDisplayEquipmentsGearScreen
                                              .route);
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Previous Bookings",
                                    icon: Icons.calendar_month_outlined,
                                    onPress: () {
                                      Navigator.pushNamed(
                                          context,
                                          PhotographerPreviousBookingScreen
                                              .route);
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Payment Methods",
                                    icon: Icons.credit_card,
                                    onPress: () {
                                      Navigator.pushNamed(
                                          context, PaymentInfoScreen.route);
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Time slots and availability",
                                    icon: Icons.watch_later_outlined,
                                    onPress: () {
                                      Navigator.pushNamed(
                                          context,
                                          PhotographerTimeSlotAvailabilityScreen
                                              .route);
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Contact us",
                                    icon: Icons.call_outlined,
                                    onPress: () {
                                      Uri url =
                                          Uri.parse('mailto:$kSupportEmail');
                                      canLaunchUrl(url).then((value) {
                                        if (value) {
                                          launchUrl(url);
                                        } else {
                                          Toasty.error(
                                              'No email app available');
                                        }
                                      });
                                    },
                                  ),
                                  photographerProvider.changeStatusLoading ==
                                          true
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.orange,
                                          ),
                                        )
                                      : profileHeadingsBuild(
                                          title: "Delete Account",
                                          icon: Icons.delete_outline,
                                          onPress: () {
                                            deleteDialog(
                                                "Delete Account",
                                                "Are You Sure you want to delete Account?",
                                                context, () {
                                              Navigator.pop(context);
                                              photographerProvider
                                                  .deletephotographer(
                                                      context, loggedInUser);
                                            });

                                            // Uri url = Uri.parse(
                                            //     'http://myclickerr.info/public/account-deletion-request.html');
                                            // canLaunchUrl(url).then((value) {
                                            //   if (value) {
                                            //     launchUrl(url);
                                            //   } else {
                                            //     Toasty.error(
                                            //         'No app available to open web URL');
                                            //   }
                                            // });
                                          },
                                        ),
                                  profileHeadingsBuild(
                                    title: "Support Person",
                                    icon: Icons.support_agent,
                                    trailing: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection(
                                              FirestoreConstants.supportpersons)
                                          .doc(FirestoreConstants.supportpersons
                                              .toLowerCase())
                                          .collection("chats")
                                          .doc(au.FirebaseAuth.instance
                                                  .currentUser!.uid ??
                                              "")
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return SizedBox.shrink();
                                        }

                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        final data = snapshot.data?.data()
                                            as Map<String, dynamic>?;

                                        int unredcounter =
                                            data?['unreadCounter'] ?? 0;

                                        return Container(
                                          child: unredcounter != 0
                                              ? CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      AppColors.orange,
                                                  child: FittedBox(
                                                    child: Text(
                                                      unredcounter > 99
                                                          ? '99+'
                                                          : '$unredcounter',
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .kPrimaryTextColor,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  color: AppColors.black,
                                                  size: 16,
                                                ),
                                        );
                                      },
                                    ),
                                    onPress: () async {
                                      // if (mounted) {
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => SplashPage(
                                      //         targetUserId:
                                      //             "DOhRetbQstgbapKhTyWHAldblYR2",
                                      //         issupportperson: true,
                                      //         // SessionHelper.userType == '1'
                                      //         //     ? photographer.id.toString()
                                      //         //     : bkDetail.userId.toString(),
                                      //       ),
                                      //     ),
                                      //   );
                                      // }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SupportChatScreen(
                                            arguments:
                                                SupportChatScreenArguments(
                                                    peerId: au
                                                        .FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    peerAvatar: "",
                                                    peerNickname:
                                                        "Support Team",
                                                    mineimg: loggedInUser!
                                                            .profileImage ??
                                                        "",
                                                    minename:
                                                        loggedInUser!.name ??
                                                            ""),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            :
                            // for user side now
                            Column(
                                children: [
                                  profileHeadingsBuild(
                                    title: "Basic Information",
                                    icon: Icons.person_outline_outlined,
                                    onPress: () async {
                                      Object? res = await Navigator.pushNamed(
                                          context,
                                          ProfileBasicInfoScreen.route);

                                      if (res == true) {
                                        debugLog(
                                            "Back from user basic info, res: $res");

                                        getUserData();
                                      }
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Previous Bookings",
                                    icon: Icons.work_history_outlined,
                                    onPress: () {
                                      Navigator.pushNamed(context,
                                          UserPreviousBookingScreen.route);
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Payment Methods",
                                    icon: Icons.camera_alt_outlined,
                                    onPress: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaymentScreen(
                                            onCardSelected: (selectedCard) {},
                                          ),
                                        ),
                                      );
                                      //   Navigator.pushNamed(
                                      //       context, PaymentInfoScreen.route);
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Contact us",
                                    icon: Icons.call_outlined,
                                    onPress: () {
                                      Uri url =
                                          Uri.parse('mailto:$kSupportEmail');
                                      canLaunchUrl(url).then((value) {
                                        if (value) {
                                          //Toasty.error('ok');
                                          launchUrl(url);
                                        } else {
                                          Toasty.error(
                                              'No email app available');
                                        }
                                      });
                                    },
                                  ),
                                  profileHeadingsBuild(
                                    title: "Support Person",
                                    icon: Icons.support_agent,
                                    trailing: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection(
                                              FirestoreConstants.supportpersons)
                                          .doc(FirestoreConstants.supportpersons
                                              .toLowerCase())
                                          .collection("chats")
                                          .doc(au.FirebaseAuth.instance
                                                  .currentUser!.uid ??
                                              "")
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return SizedBox.shrink();
                                        }

                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        final data = snapshot.data?.data()
                                            as Map<String, dynamic>?;

                                        int unredcounter =
                                            data?['unreadCounter'] ?? 0;

                                        return Container(
                                          child: unredcounter != 0
                                              ? CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      AppColors.orange,
                                                  child: FittedBox(
                                                    child: Text(
                                                      unredcounter > 99
                                                          ? '99+'
                                                          : '$unredcounter',
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .kPrimaryTextColor,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  color: AppColors.black,
                                                  size: 16,
                                                ),
                                        );
                                      },
                                    ),
                                    onPress: () async {
                                      // if (mounted) {
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => SplashPage(
                                      //         targetUserId:
                                      //             "DOhRetbQstgbapKhTyWHAldblYR2",
                                      //         issupportperson: true,
                                      //         // SessionHelper.userType == '1'
                                      //         //     ? photographer.id.toString()
                                      //         //     : bkDetail.userId.toString(),
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SupportChatScreen(
                                            arguments:
                                                SupportChatScreenArguments(
                                                    peerId: au
                                                        .FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    peerAvatar: "",
                                                    peerNickname:
                                                        "Support Team",
                                                    mineimg: loggedInUser!
                                                            .profileImage ??
                                                        "",
                                                    minename:
                                                        loggedInUser!.name ??
                                                            ""),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        20.SpaceY,
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget profileHeadingsBuild({onPress, icon, title, trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20, right: 20),
      onTap: onPress,
      leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5)),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.black,
          )),
      title: Text(
        "$title",
        style: MyTextStyle.mediumBlack.copyWith(fontSize: 16),
      ),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.black, size: 16),
    );
  }
}
