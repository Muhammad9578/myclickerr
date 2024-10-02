import 'package:flutter/material.dart';

class AppColors {
  static const Color kPrimaryColor = Colors.white;

  static const Color kOnPrimaryColor = Color(0xff18406F);
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
}

const String assetImagePath = "assets/images";

class ImageAsset {
  static const String UserImage = "${assetImagePath}/user1.png";
  static const String PhotographerImage = "${assetImagePath}/photographer1.png";
  static const String LogoImage = "${assetImagePath}/logo.png";
  static const String Onboard1Image = "${assetImagePath}/onboard1.png";
  static const String Onboard2Image = "${assetImagePath}/onboard2.png";
  static const String Onboard3Image = "${assetImagePath}/onboard3.png";
  static const String AppIcon = "${assetImagePath}/app_icon.png";
  static const String SendIcon = "${assetImagePath}/sendIcon.png";
  static const String FilterIcon = "${assetImagePath}/filter.png";
  static const String CurrentLocationIcon =
      "${assetImagePath}/current_location_icon.png";
  static const String EditIcon = "${assetImagePath}/editIcon.png";
  static const String DeleteIcon = "${assetImagePath}/delete.png";

  static const String placeholderimg = "${assetImagePath}/placeholder.png";
}

class MyTextStyle {
  // static final TextStyle black34 =  TextStyle(
  //     fontSize: 34, color: AppColors.blackColor, fontFamily: "AlbertSans",
  //     fontWeight: FontWeight.bold
  // );

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
const Color kPrimaryColor = Colors.white;
const Color kPrimaryTextColor = Colors.black87;
const Color kSecondaryTextColor = Color(0xff363636);
const Color kSbackbarColor = Colors.red;

const Color kOnPrimaryColor = Color(0xff18406F);
const Color kPrimaryButtonColor = AppColors.orange;
//const Color kOnPrimaryColor = Color(0xffffffff);
const Color kPrimaryButtonTextColor = Colors.white;
const Color kSecondaryButtonColor = Colors.white;
const Color kSecondaryButtonTextColor = Color(0xff3f3f3f);
const Color kInputBackgroundColor = Color(0xFFE7E7E7);
//const Color kHighlightTextColor = Color(0xFF000000);
const Color kHighlightTextColor = kPrimaryButtonColor;
const Color kAccentColor = AppColors.orange;
const Color kProgressColor = AppColors.orange;

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

// final RefreshController photographerEquipmentRefreshController =
//     RefreshController(initialRefresh: false);
// final RefreshController photographerPortfolioRefreshController =
//     RefreshController(initialRefresh: false);

// final RefreshController photographerSignupPortfolioRefreshController =
//     RefreshController(initialRefresh: false);
// final RefreshController photographerPaymentInfoRefreshController =
//     RefreshController(initialRefresh: false);
// final RefreshController profileBasicInfoScreenRefreshController =
//     RefreshController(initialRefresh: false);

Image kLogoImage = const Image(
  width: 160,
  height: 40,
  image: AssetImage(ImageAsset.LogoImage),
);

class FirestoreConstants {
  static const supportpersons = "SupportPerson";
  static const chats = "chats";
  static const supportunreadCounter = "supportunreadCounter";
  static const messages = "messages";
  static const customorderdetail = "customorderdetail";
  static const roomid = "roomid";
  static const customorderdocumentid = "customorderdocumentid";
  static const pathUserCollection = "users";
  static const pathUserCollection1 = "supportperson";
  static const pathCustomOrderCollection = "customOrders";
  static const pathMessageCollection = "messages";
  static const pathRoomsCollection = "rooms";
  static const pathSessionCollection = "bookingSessions";
  static const pushToken = "pushToken";
  static const nickname = "nickname";
  static const aboutMe = "aboutMe";
  static const photoUrl = "photoUrl";
  static const email = "email";
  static const roomId = "roomId";
  static const id = "id";
  static const chattingWith = "chattingWith";
  static const idFrom = "idFrom";
  static const idTo = "idTo";
  static const timestamp = "timestamp";
  static const content = "content";
  static const sentby = "sentby";
  static const type = "type";
  static const userType = "userType";
  static const userId = "userId";
  static const lastMessage = "lastMessage";
  static const lastMessageType = "lastMessageType";
  static const dateTime = "dateTime";
  static const users = "users";
  static const unreadCounter = "unreadCounter";

  static const idFromOrder = 'idFromOrder';

  static const idToOrder = 'idToOrder';
  static const orderTotalPrice = 'orderTotalPrice';
  static const orderTotalHours = 'orderTotalHours';
  static const orderDescription = 'orderDescription';
  static const orderStatus = 'orderStatus';
  static const orderCreatedTimestamp = 'orderCreatedTimestamp';
  static const orderPhotographer = "orderPhotographer";

  //***************** photographer data who is placing custom order ***********
  static const orderPskills = " orderPskills";
  static const orderPname = " orderPname";
  static const orderPprofileImage = " orderPprofileImage";
  static const orderPperHourPrice = " orderPperHourPrice";
  static const orderPshortBio = " orderPshortBio";
  static const onboardingScreenShown = " onboardingScreenShown";
  static const isOnline = " isOnline";
  static const createdAt = "createdAt";

//   bookingSession constants
  static const bookingId = "bookingId";
  static const startTime = "startTime";
  static const endTime = "endTime";
  static const totalHours = "totalHours";
  static const onGoing = "onGoing";
  static const otp = "otp";
  static const photographerId = "photographerId";
}

class ColorConstants {
  static const themeColor = Color(0xfff5a623);
  static Map<int, Color> swatchColor = {
    50: themeColor.withOpacity(0.1),
    100: themeColor.withOpacity(0.2),
    200: themeColor.withOpacity(0.3),
    300: themeColor.withOpacity(0.4),
    400: themeColor.withOpacity(0.5),
    500: themeColor.withOpacity(0.6),
    600: themeColor.withOpacity(0.7),
    700: themeColor.withOpacity(0.8),
    800: themeColor.withOpacity(0.9),
    900: themeColor.withOpacity(1),
  };
  static const primaryColor = Color(0xffd5d5d5);
  static const greyColor = Color(0xffaeaeae);
  //static const greyColor2 = Color(0xff18406F);
  static const greyColor2 = Color(0xff18406F);
  static const darkGrey = Color(0xff18406F);

  //static const greyColor2 = Color(0xffE8E8E8);
}

class AppConstants {
  static const appTitle = "Flutter Chat Demo";
  static const loginTitle = "Login";
  static const homeTitle = "Chats1";
  static const settingsTitle = "Settings";
  static const fullPhotoTitle = "Full Photo";
}

class ApiClient {
  // static const baseUrl = 'http://shanzycollection.com/photolab/public/api';
  //static const baseUrl = 'https://tap4trip.com/photolab/public/api';
  // static const baseUrl = 'https://myclickerr.com/photolab/public/api';

  // static const baseUrl = 'https://app.myclickerr.com/api';

  static const baseUrl = 'https://myclickerr.info/public/api';

  //**********************   Auth APIs   ******************
  static const signupUrl = '$baseUrl/signup';
  static const loginUrl = '$baseUrl/login';
  static const updateProfileUrl = '$baseUrl/update-profile';
  static const changePasswordUrl = '$baseUrl/change-password'; // not used
  static const forgotPasswordUrl = '$baseUrl/forgot-password';
  static const resetPasswordUrl = '$baseUrl/reset-password';
  static const logoutUrl = '$baseUrl/logout';
  static const updateFcmTokenUrl = '$baseUrl/update-fcm-token';
  static const deleteAccountUrl = '$baseUrl/delete-account';

  //**********************   User side APIs   ******************
  static const userHomeUrl = '$baseUrl/user-home';
  static const addUserCardUrl =
      '$baseUrl/user-card'; // adding user payment card details
  static const hirePhotographerUrl = '$baseUrl/hire-photographer';
  static const rescheduleBookingUrl = '$baseUrl/reschedule-booking';
  static const userBookingsUrl = '$baseUrl/user-bookings';
  static const confirmPaymentUrl = '$baseUrl/confirm-payment';
  static const deleteBookingUrl = '$baseUrl/delete-booking';
  static const ratePhotographerUrl = '$baseUrl/rate-photographer';
  static const sendCustomOrderNotificationToPhotographerUrl =
      '$baseUrl/send-custom-order-notification-to-photographer';
  static const addPaymentInfoUrl = '$baseUrl/add-payment-info';
  static const instaPaymentUrl = '$baseUrl/insta-payment';

  //**********************   Photographer side APIs   ******************
  static const photographerHomeUrl = '$baseUrl/photographer-home';
  static const photographerBookingHistoryUrl = '$baseUrl/photographer-history';
  static const changeBookingStatusUrl = '$baseUrl/change-booking-status';
  static const photographerUpcomingBookingUrl = '$baseUrl/upcoming-bookings';
  static const photographerHistoryUrl = '$baseUrl/photographer-history';
  static const photographerPendingBookingUrl = '$baseUrl/pending-bookings';
  static const photographerProcessedBookingsUrl = '$baseUrl/processed-bookings';
  static const photographerCompletedBookingsUrl = '$baseUrl/completed-bookings';
  static const addEquipmentUrl = '$baseUrl/add-equipment';
  static const getAllEquipmentUrl = '$baseUrl/all-equipment';
  static const deleteEquipmentUrl = '$baseUrl/delete-equipment';
  static const portfolioUrl = '$baseUrl/portfolio';
  static const resetTimeSlotsUrl = '$baseUrl/update-timeslots-and-availability';
  static const sendCustomOrderNotificationToUserUrl =
      '$baseUrl/send-custom-order-notification-to-user';
  static const photographerSkillsUrl = '$baseUrl/photographer-skills';

  //********************   Shared APIs   *****************

  static const updateBankDetailsUrl = '$baseUrl/update-bank-details';
  static const getBankDetailsUrl = '$baseUrl/get-bank-details';
  static const updateOneSignalIdUrl = '$baseUrl/update-onesignal-id';
  static const newMessageNotificationUrl = '$baseUrl/new-message-notification';
  static const userNotificationsUrl = '$baseUrl/user-notifications';
  static const resetNotificationsCountUrl =
      '$baseUrl/reset-unread-notification-counter';
  static const marketplaceCategoriesUrl = '$baseUrl/marketplace-categories';
  static const marketplaceProductsUrl = '$baseUrl/category-products';
  static const otpArrivalNotificationUrl = '$baseUrl/arrival-notification';
}
