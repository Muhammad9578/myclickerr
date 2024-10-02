import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:photo_lab/src/models/photographer.dart';
import 'package:photo_lab/src/models/rating.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

import 'package:photo_lab/src/screens/user_screens/u_add_booking_screens/u_add_new_booking_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_side_photographer_profile_screen/user_side_photographer_equipment_slider.dart';
import 'package:photo_lab/src/screens/user_screens/u_side_photographer_profile_screen/user_side_photographer_portfolio_slider.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';

import '../../../helpers/session_helper.dart';
import '../../photographer_screens/p_portfolio_screens/p_portfolio_main.dart';
import '../u_add_booking_screens/u_display_p_equipment_screen.dart';

class UserSidePhotographerProfileScreen extends StatefulWidget {
  static const String route = "userSidePhotographerProfileScreen";

  const UserSidePhotographerProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserSidePhotographerProfileScreen> createState() =>
      _UserSidePhotographerProfileScreenState();
}

class _UserSidePhotographerProfileScreenState
    extends State<UserSidePhotographerProfileScreen> {
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    final Photographer photographer =
        ModalRoute.of(context)!.settings.arguments as Photographer;

    // print("photographer: ${photographer.id}");

    return Scaffold(
      appBar: CustomAppBar(
        title: "Photographer Profile",
        action: [],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        20.SpaceY,
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.orange.withOpacity(0.9),
                              )),
                          child: ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: ImageAsset.PlaceholderImg,
                              image: photographer.imageURL,
                              // .replaceFirst('https', 'http'),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  ImageAsset.PlaceholderImg,
                                  //  fit: BoxFit.fitWidth,
                                  width: 100,
                                  height: 100,
                                );
                              },
                            ),
                          ),
                        ),
                        15.SpaceY,
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            textAlign: TextAlign.center,
                            photographer.name,
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 24),
                          ),
                        ),
                        5.SpaceY,
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            textAlign: TextAlign.center,
                            "${photographer.skills}",
                            style: MyTextStyle.semiBold07Black
                                .copyWith(fontSize: 14),
                          ),
                        ),
                        20.SpaceY,
                        Container(
                          padding: EdgeInsets.only(
                              top: 15, bottom: 15, left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset.zero,
                                  blurRadius: 10,
                                ),
                              ]),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Bid Amount',
                                style: MyTextStyle.semiBold05Black.copyWith(
                                    fontSize: 14, color: AppColors.black),
                              ),
                              Spacer(),
                              Text(
                                '\u{20B9} ${photographer.perHourPrice}',
                                style: MyTextStyle.semiBold05Black.copyWith(
                                    fontSize: 20, color: AppColors.black),
                              ),
                              8.SpaceX,
                              Text(
                                'Per Hour',
                                style: MyTextStyle.mediumItalic.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        20.SpaceY,
                        Row(
                          children: [
                            Expanded(
                              child: infoCardsBuild(
                                  quantity: photographer.totalBookings,
                                  title: "Total Bookings",
                                  color: AppColors.lightGrey),
                            ),
                            20.SpaceX,
                            Expanded(
                              child: infoCardsBuild(
                                  quantity: photographer.averageRating == 0.0
                                      ? 0
                                      : photographer.averageRating
                                          .toStringAsFixed(1),
                                  title: "Total Rating",
                                  color: AppColors.lightPurple),
                            ),
                          ],
                        ),
                        20.SpaceY,
                        Text(
                          "Full name",
                          style:
                              MyTextStyle.medium07Black.copyWith(fontSize: 14),
                        ),
                        5.SpaceY,
                        Text(
                          "${photographer.name}",
                          style: MyTextStyle.semiBold085Black
                              .copyWith(fontSize: 17),
                        ),
                        20.SpaceY,
                        Text(
                          "Skills",
                          style:
                              MyTextStyle.medium07Black.copyWith(fontSize: 14),
                        ),
                        5.SpaceY,
                        Text(
                          "${photographer.skills}",
                          style: MyTextStyle.semiBold085Black
                              .copyWith(fontSize: 17),
                        ),
                        20.SpaceY,
                        Text(
                          "Short bio",
                          style:
                              MyTextStyle.medium07Black.copyWith(fontSize: 14),
                        ),
                        5.SpaceY,
                        Text(
                          "${photographer.shortBio == "" ? "Bio not provided." : photographer.shortBio}",
                          style: MyTextStyle.semiBold085Black
                              .copyWith(fontSize: 17),
                        ),
                        20.SpaceY,
                        photographer.photographerEquipment.isEmpty
                            ? SizedBox.shrink()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "My Portfolio",
                                    style: MyTextStyle.medium07Black
                                        .copyWith(fontSize: 14),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          PhotographerPortfolioMainScreen.route,
                                          arguments: {
                                            'photographerId': photographer.id
                                          });
                                    },
                                    child: Text(
                                      "View all",
                                      style: MyTextStyle.semiBoldBlack.copyWith(
                                          fontSize: 14,
                                          color: AppColors.darkOrange),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  photographer.photographerPortfolio.isEmpty
                      ? 0.SpaceY
                      : 10.SpaceY,
                  photographer.photographerPortfolio.isEmpty
                      ? SizedBox.shrink()
                      : UserSidePhotographerPortfolioSlider(
                          portfolioList: photographer.photographerPortfolio,
                          key: UniqueKey()),
                  photographer.photographerPortfolio.isEmpty
                      ? 0.SpaceY
                      : 20.SpaceY,
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Equipment & Gear",
                          style:
                              MyTextStyle.medium07Black.copyWith(fontSize: 14),
                        ),
                        photographer.photographerEquipment.length == 0
                            ? SizedBox.shrink()
                            : InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    UserSideDisplayPhotographerEquipmentsScreen
                                        .route,
                                    arguments:
                                        photographer.photographerEquipment,
                                  );
                                },
                                child: Text(
                                  "View all",
                                  style: MyTextStyle.semiBoldBlack.copyWith(
                                      fontSize: 14,
                                      color: AppColors.darkOrange),
                                ),
                              ),
                      ],
                    ),
                  ),
                  2.SpaceY,
                  photographer.photographerEquipment.length == 0
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 8),
                          child: Text(
                            "Didn't provide equipment info.",
                            style: MyTextStyle.semiBoldBlack
                                .copyWith(fontSize: 18),
                          ),
                        )
                      : SizedBox(
                          // width: MediaQuery.of(context).size.width-60,
                          //   height: MediaQuery.of(context).size.height*0.13,
                          child: UserSidePhotographerEquipmentSlider(
                              portfolioList: photographer.photographerEquipment,
                              key: UniqueKey()),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        30.SpaceY,
                        Text(
                          "Reviews",
                          style:
                              MyTextStyle.medium07Black.copyWith(fontSize: 14),
                        ),
                        15.SpaceY,
                        photographer.photographerRating.length == 0
                            ? Text(
                                "No Reviews yet.",
                                style: MyTextStyle.semiBoldBlack
                                    .copyWith(fontSize: 18),
                              )
                            : ListView.builder(
                                itemCount:
                                    photographer.photographerRating.length,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  PhotographerRating rating =
                                      photographer.photographerRating[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      reviewCardBuild(rating, context),
                                      index !=
                                              photographer.photographerRating
                                                      .length -
                                                  1
                                          ? Divider(
                                              color: AppColors.black
                                                  .withOpacity(0.1),
                                              height: 5,
                                              thickness: 1,
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  );
                                },
                              ),
                        30.SpaceY,
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 15,
            child: GradientButton(
              text: "Book Now",
              onPress: () {
                Navigator.pushNamed(context, UserAddNewBookingScreen.route,
                    arguments: {'photographer': photographer});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget reviewCardBuild(PhotographerRating rating, context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            // color: Colors.greenAccent.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: ImageAsset.PlaceholderImg,
                    image: rating.imgPath,
                    // .replaceFirst('https', 'http'),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        ImageAsset.PlaceholderImg,
                        //  fit: BoxFit.fitWidth,
                        width: 50,
                        height: 50,
                      );
                    },
                  ),
                ),
                10.SpaceX,
                Expanded(
                  child: Container(
                    // color: Colors.red,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              // fit: FlexFit.loose,
                              child: Text(
                                '${rating.userName}',
                                overflow: TextOverflow.ellipsis,
                                style: MyTextStyle.semiBold05Black.copyWith(
                                    fontSize: 16, color: AppColors.black),
                              ),
                            ),
                            // Spacer(),
                            RatingBar.builder(
                              itemSize: 16,
                              initialRating: rating.rating,
                              minRating: 1,

                              unratedColor: AppColors.cardBackgroundColor,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              ignoreGestures: true,
                              // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: AppColors.orange,
                              ),
                              onRatingUpdate: (rating) {
                                // print(rating);
                              },
                            ),
                          ],
                        ),
                        8.SpaceY,
                        Text(
                          '${rating.dateTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MyTextStyle.regularBlack.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          15.SpaceY,
          Text(
            "${rating.description}",
            style: MyTextStyle.semiBold085Black.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget infoCardsBuild({quantity, title, color}) {
    return Container(
      padding: EdgeInsets.all(15),
      // width: w * 0.4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$quantity",
            style: MyTextStyle.boldBlack.copyWith(fontSize: 24),
          ),
          8.SpaceY,
          Text(
            title,
            style: MyTextStyle.medium07Black
                .copyWith(fontSize: 14, color: Colors.black.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
