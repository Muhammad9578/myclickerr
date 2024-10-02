import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/modules/chat/constants/firestore_constants.dart';
import 'package:photo_lab/src/modules/chat/controllers/auth_controller.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/portfolio_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/utils.dart';
import '../../../models/portfolio_model.dart';
import '../../../widgets/empty_portfolio_widget.dart';
import '../p_home_startup.dart';
import '../p_profile_screens/p_pending_verification_screen.dart';
import '../p_profile_screens/p_verification_succesfull_screen.dart';
import 'p_signup_add_portfolio_screen.dart';

class PhotographerSignupPortfolioMainScreen extends StatefulWidget {
  static const route = "photographerSignupPortfolioMainScreen";

  const PhotographerSignupPortfolioMainScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerSignupPortfolioMainScreen> createState() =>
      _PhotographerSignupPortfolioMainScreenState();
}

class _PhotographerSignupPortfolioMainScreenState
    extends State<PhotographerSignupPortfolioMainScreen> {
  User? loggedInUser;
  late PhotographerPortfolioController photographerPortfoliocontroller;

  Future<void> deleteDialog(id) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                // color: AppColors.orange,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Delete Event',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to delete this event?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.cancel,
                        color: AppColors.black.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.red,
                      ),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(
                          color: AppColors.red, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        photographerPortfoliocontroller.deletePortfolio(id);
        break;
    }
  }

  @override
  initState() {
    super.initState();
    photographerPortfoliocontroller =
        Provider.of<PhotographerPortfolioController>(context, listen: false);
    SessionHelper.getUser().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            loggedInUser = value;
            photographerPortfoliocontroller.isloading = false;
            // todo verify this with photographer having empty portfolio
            if (photographerPortfoliocontroller.photographerPortfolio != null) {
              if (photographerPortfoliocontroller
                  .photographerPortfolio!.isEmpty)
                photographerPortfoliocontroller.setPhotographerPortfolio(null);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loggedInUser == null
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            )
          : SmartRefresher(
              controller: photographerSignupPortfolioRefreshController,
              onRefresh: () {
                photographerPortfoliocontroller.getPortfolio(loggedInUser!.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    40.SpaceY,
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppColors.shaderWhite,
                            ),
                            height: 10,
                          ),
                          Container(
                            height: 10,
                            width: MediaQuery.of(context).size.width * 0.75,
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
                    ),
                    30.SpaceY,
                    kLogoImage,
                    30.SpaceY,
                    Text(
                      textAlign: TextAlign.center,
                      "My Portfolio",
                      style: MyTextStyle.boldBlack.copyWith(
                        fontSize: 30,
                      ),
                    ),
                    10.SpaceY,
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10.0),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Add your photos or videos to build a portfolio",
                        style: MyTextStyle.medium07Black.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    10.SpaceY,
                    Expanded(child: Consumer<PhotographerPortfolioController>(
                        builder: (context, portfolioPrvdr, child) {
                      print(
                          "portfolioPrvdr.photographerPortfolio: ${portfolioPrvdr.photographerPortfolio}");
                      if (portfolioPrvdr.photographerPortfolio == null) {
                        portfolioPrvdr.getPortfolio(loggedInUser!.id);
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        );
                      } else
                        return portfolioPrvdr.photographerPortfolio!.isEmpty
                            ? EmptyPortfolio(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      PhotographerSignupAddPortfolioScreen
                                          .route,
                                      arguments: {
                                        'photographerId': loggedInUser!.id,
                                        'fromPortfolio': true
                                      });
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: portfolioPrvdr
                                          .photographerPortfolio!.length,
                                      itemBuilder: (context, index) {
                                        PortfolioModel portfolioModel =
                                            portfolioPrvdr
                                                .photographerPortfolio![index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: PortfolioWidget(
                                            portfolioModel: portfolioModel,
                                            onLongPress: () {
                                              deleteDialog(
                                                  portfolioModel.portfolioId);
                                              // deletePortfolio();
                                            },
                                            onTap: () {
                                              // Navigator.pushNamed(context,
                                              //     PhotographerSinglePortfolioScreen.route,
                                              //
                                              //     arguments:
                                              //     portfolioModel
                                              // );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 15),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              PhotographerSignupAddPortfolioScreen
                                                  .route,
                                              arguments: {
                                                'photographerId':
                                                    loggedInUser!.id,
                                                'fromPortfolio': true
                                              });
                                        },
                                        child: Text(
                                          "+ Add More",
                                          style: MyTextStyle.boldBlack.copyWith(
                                              fontSize: 14,
                                              color: AppColors.orange),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                    })),
                    Consumer<PhotographerPortfolioController>(
                      builder: (context, portfolioPrvdr, child) {
                        if (portfolioPrvdr.isloading) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.orange,
                              ),
                            ),
                          );
                        } else {
                          if (portfolioPrvdr.photographerPortfolio != null &&
                              portfolioPrvdr
                                  .photographerPortfolio!.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15, bottom: 15),
                              child: GradientButton(
                                text: "Proceed",
                                onPress: () async {
                                  closeKeyboard(context);

                                  if (loggedInUser!.isVerified == 1) {
                                    var userDocRef = FirebaseFirestore.instance
                                        .collection(FirestoreConstants
                                            .pathUserCollection)
                                        .doc(auth.FirebaseAuth.instance
                                            .currentUser!.uid);

                                    var userDocument = await userDocRef.get();
                                    bool isverified = false;
                                    if (userDocument.data()!.containsKey(
                                        FirestoreConstants
                                            .isverifiedscreenshown)) {
                                      isverified = userDocument.data()![
                                          FirestoreConstants
                                              .isverifiedscreenshown];
                                    } else {
                                      await userDocRef.update({
                                        FirestoreConstants
                                            .isverifiedscreenshown: true,
                                      });
                                    }
                                    if (isverified) {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        PhotographerHomeStartup.route,
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      context
                                          .read<AuthController>()
                                          .prefs
                                          .setBool(
                                              FirestoreConstants
                                                  .onboardingScreenShown,
                                              true);

                                      await userDocRef.update({
                                        FirestoreConstants
                                            .isverifiedscreenshown: true,
                                      });

                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        PhotographerVerificationSuccessfulScreen
                                            .route,
                                        arguments: {
                                          'userType': UserType.photographer
                                        },
                                        (Route<dynamic> route) => false,
                                      );
                                    }
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      PhotographerPendingVerificationScreen
                                          .route,
                                    );
                                  }
                                },
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }
                      },
                    )
                  ],
                ),
              )),
    );
  }
}
