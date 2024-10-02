import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const String kGoogleMapsKey = "AIzaSyCFyRfL4R8QSNX7vwpCModvcPdM8T_Jm5Y";
const String kOneSignalAppID = "2e7b605e-3f18-4981-80f7-f00bc7fe272b";
const String kStripeKey =
    "pk_test_51M3PItSFxZeXg2aT5jqp9BflervO09JND9OpCnGM02pMPCyAMJZR3FGn8fOq4FOtF1jEKIVKMUZ7e0H91vgAwmLm00ABSveQWh";
const String kSupportEmail = 'contact@myclickerr.com';

const String kTwilioAccountSid = 'AC5c21cf5396a263ed58ab875b4d8921cd';
const String kTwilioAuthToken = 'b081cc4841c37fb380e14b33de3f3c1c';
const String kTwilioNumber = '+17628001997';

const bool kDebugMode = true;
const String kAppName = 'My Clickerr';
//Deep Blue color code 18406F
//Light Blue color 30A0E0

const double kScreenPadding = 20.0;
const double kInputBorderRadius = 8;
const double kButtonBorderRadius = 30;
const double kButtonBorderWidth = 1.5;
const double kPrimaryButtonFontSize = 16;
const double kBottomSheetBorderRadius = 16;
const EdgeInsets kButtonPadding =
    EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 14);
const double kDefaultSpace = 8.0;

//const String kDropboxClientId = 'test-flutter-dropbox';
const String kDropboxClientId = 'gc6s221x662krr3';
const String kDropboxAppKey = 'gc6s221x662krr3';
const String kDropboxSecret = '0rnpk18ovj8o4h0';

final RefreshController photographerEquipmentRefreshController =
    RefreshController(initialRefresh: false);
final RefreshController photographerPortfolioRefreshController =
    RefreshController(initialRefresh: false);

final RefreshController photographerSignupPortfolioRefreshController =
    RefreshController(initialRefresh: false);
final RefreshController photographerPaymentInfoRefreshController =
    RefreshController(initialRefresh: false);
final RefreshController profileBasicInfoScreenRefreshController =
    RefreshController(initialRefresh: false);

Image kLogoImage = Image(
  width: 160,
  height: 40,
  image: AssetImage(ImageAsset.LogoImage),
);

enum UserType { user, photographer }

class AppColors {
  static const Color black = Color(0xff121212);
  static const Color shaderBlue = Color(0xff3B3A56);
  static const Color darkBlack = Color(0xff0D0D0D);
  static const Color orange = Color(0xffFF8E3C);
  static const Color darkOrange = Color(0xffB96C34);
  static const Color lightOrange = Color(0xffDE6163);
  static const Color white = Color(0xffFFFFFF);
  static const Color lightGrey = Color(0xffF8F4EE);
  static const Color shaderWhite = Color(0xffF2F2F2);
  static const Color dropWhiteShadow = Color(0xffebebf5);
  static const Color cardBackgroundColor = Color(0xffF5F5F5);
  static const Color lightPurple = Color(0xffF4F4FF);
  static const Color lightPink = Color(0xffFFF4FA);
  static const Color shaderGreen = Color(0xffEAFBFF);
  static const Color shaderBrown = Color(0xffF8F4EE);
  static const Color notificationIconBlack = Color(0xff200E32);
  static const Color yellow = Color(0xffF8B84E);
  static const Color purple = Color(0xff18406F);
  static const Color browne = Color(0xffB4904F);
  static const Color pink = Color(0xffC13C8F);
  static const Color red = Color(0xffD94C2E);
  static const Color lightGreen = Color(0xff8FAE57);
  static const Color blue = Color(0xff2E7AF6);
  static const Color darkBlue = Color(0xff006FD1);
  static const Color senderCardLightGreen = Color(0xffE1FFE7);
  static const Color mediumGreen = Color(0xffc8ffd3);
  static const Color kPrimaryTextColor = Colors.black87;
  static const Color kSecondaryTextColor = Color(0xff363636);
  static const Color kOnPrimaryColor = Color(0xff18406F);
  static const Color kSecondaryButtonTextColor = Color(0xff3f3f3f);
  static const Color kInputBackgroundColor = Color(0xFFE7E7E7);
}

//images

const String assetImagePath = "assets/images";

class ImageAsset {
  static const String UserImage = "${assetImagePath}/user.png";
  static const String PhotographerImage = "${assetImagePath}/photographer.png";
  static const String LogoImage = "${assetImagePath}/logo.png";
  static String dropboxicon = "${assetImagePath}/dropboxicon.png";
  static const String Onboard1Image = "${assetImagePath}/onboard1.png";
  static const String Onboard2Image = "${assetImagePath}/onboard2.png";
  static const String Onboard3Image = "${assetImagePath}/onboard3.png";
  static const String AppIcon = "${assetImagePath}/app_icon.png";
  static const String SendIcon = "${assetImagePath}/sendIcon.svg";
  static const String FilterIcon = "${assetImagePath}/filter.svg";
  static const String CurrentLocationIcon =
      "${assetImagePath}/current_location_icon.png";
  static const String EditIcon = "${assetImagePath}/edit.svg";
  static const String DeleteIcon = "${assetImagePath}/delete.svg";
  static const String MaleIcon = "${assetImagePath}/male.png";
  static const String FemaleIcon = "${assetImagePath}/female.png";
  static const String PlaceholderImg = "${assetImagePath}/placeholder.png";
}

class MyTextStyle {
  static var boldBlack = TextStyle(
      color: AppColors.black,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w700);
  static var boldBWhite = TextStyle(
      color: AppColors.white,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w700);
  static var regularBlack = TextStyle(
      color: AppColors.black,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w400);
  static var semiBold05Black = TextStyle(
      color: AppColors.black.withOpacity(0.5),
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w600);
  static var semiBold07Black = TextStyle(
      color: AppColors.black.withOpacity(0.7),
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w600);
  static var semiBold085Black = TextStyle(
      color: AppColors.black.withOpacity(0.85),
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w600);

  static var semiBoldBlack = TextStyle(
      color: AppColors.black,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w600);

  static var semiBoldDarkBlack = TextStyle(
      color: AppColors.darkBlack,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w600);

  static var medium07Black = TextStyle(
      color: AppColors.black.withOpacity(0.7),
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w500);

  static var mediumBlack = TextStyle(
      color: AppColors.black,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w500);

  static var white16 = TextStyle(
      fontSize: 16,
      color: AppColors.white,
      fontFamily: "AlbertSans",
      fontWeight: FontWeight.w600);

  static var mediumItalic = TextStyle(
      color: AppColors.purple,
      fontFamily: "AlbertSans",
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600);
}

extension SpaceXY on int {
  SizedBox get SpaceX => SizedBox(
        width: this.toDouble(),
      );

  SizedBox get SpaceY => SizedBox(
        height: this.toDouble(),
      );
}

// 'genderFemale': _MdiIconData(0xf029c),
//   'genderMale': _MdiIconData(0xf029d),
//   'genderMaleFemale': _MdiIconData(0xf029e),
//   'genderMaleFemaleVariant': _MdiIconData(0xf113f),

// Icon maleicon=IconData(codePoint);

List<String> preProductionSkills = [
  "Portrait Photography",
  "Lighting",
  "Wedding Photography"
];
List<String> postProductionSkills = [
  "Editing",
  "Color Grading",
  "DI",
  "Poster Designing",
  "Album Designing"
];
