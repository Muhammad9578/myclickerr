import 'package:flutter/material.dart';
import 'package:photo_lab/src/screens/photographer_screens/p_home_startup.dart';
import 'package:photo_lab/src/screens/shared_screens/splash_screen.dart';

import '../modules/chat/pages/splash_page.dart';
import '../screens/market_place_screens/product_detail_screen.dart';
import '../screens/photographer_screens/p_all_bookings/p_accept_booking_screen.dart';
import '../screens/photographer_screens/p_all_bookings/p_all_booking_screen.dart';
import '../screens/photographer_screens/p_all_bookings/p_booking_accept_screen.dart';
import '../screens/photographer_screens/p_all_bookings/p_previous_booking_screen.dart';
import '../screens/photographer_screens/p_custom_order_screens/p_create_custom_order_screen.dart';
import '../screens/photographer_screens/p_custom_order_screens/p_display_custom_orders_screen.dart';
import '../screens/photographer_screens/p_home_screen/p_homescreen.dart';
import '../screens/photographer_screens/p_portfolio_screens/p_add_work_image_screen.dart';
import '../screens/photographer_screens/p_portfolio_screens/p_display_single_portfolio_event.dart';
import '../screens/photographer_screens/p_portfolio_screens/p_portfolio_main.dart';
import '../screens/photographer_screens/p_portfolio_screens/p_signup_add_portfolio_screen.dart';
import '../screens/photographer_screens/p_portfolio_screens/p_signup_portfolio_main_screen.dart';
import '../screens/photographer_screens/p_profile_screens/bank_detail_fragment.dart';
import '../screens/photographer_screens/p_profile_screens/p_add_equipment.dart';
import '../screens/photographer_screens/p_profile_screens/p_add_skills_screen.dart';
import '../screens/photographer_screens/p_profile_screens/p_display_equipments_geears.dart';
import '../screens/photographer_screens/p_profile_screens/p_pending_verification_screen.dart';
import '../screens/photographer_screens/p_profile_screens/p_timeslot_availability_screen.dart';
import '../screens/photographer_screens/p_profile_screens/p_verification_succesfull_screen.dart';
import '../screens/photographer_screens/p_profile_screens/payment_info_screen.dart';
import '../screens/photographer_screens/p_profile_screens/photographer_signup_screen.dart';
import '../screens/shared_screens/forgot_password_screen.dart';
import '../screens/shared_screens/my_home_page.dart';
import '../screens/shared_screens/on_boarding_screen.dart';
import '../screens/shared_screens/phone_number_input_screen.dart';
import '../screens/shared_screens/profile_basic_info_screen.dart';
import '../screens/shared_screens/profile_selections.dart';
import '../screens/shared_screens/reset_password_screen.dart';
import '../screens/shared_screens/user_login_screen.dart';
import '../screens/shared_screens/verify_phone_otp_screen.dart';
import '../screens/shared_screens/welcome_intro_screen.dart';
import '../screens/user_screens/u_add_booking_screens/u_add_new_booking_screen.dart';
import '../screens/user_screens/u_add_booking_screens/u_booking_confirmed_screen.dart';
import '../screens/user_screens/u_add_booking_screens/u_display_p_equipment_screen.dart';
import '../screens/user_screens/u_all_booking_screens/u_previous_booking_screen.dart';
import '../screens/user_screens/u_all_booking_screens/u_rate_photographer.dart';
import '../screens/user_screens/u_home_screen/u_homescreen.dart';
import '../screens/user_screens/u_home_startup.dart';
import '../screens/user_screens/u_payment_screens/add_card_screen.dart';
import '../screens/user_screens/u_profile_screens/u_edit_profile_screen.dart';
import '../screens/user_screens/u_profile_screens/user_signup_screen.dart';
import '../screens/user_screens/u_side_photographer_profile_screen/UserSidePhotographerProfileScreen.dart';

class MyRoutes {
  static Map<String, Widget Function(BuildContext)> namedRoutes = {
    SplashScreen.route: (builder) => const SplashScreen(),
    PhotographerHomeStartup.route: (builder) => PhotographerHomeStartup(),
    PhotographerBookingAcceptScreen.route: (builder) =>
        const PhotographerBookingAcceptScreen(),
    ProfileBasicInfoScreen.route: (builder) => const ProfileBasicInfoScreen(),
    UserPreviousBookingScreen.route: (builder) =>
        const UserPreviousBookingScreen(),
    PaymentInfoScreen.route: (builder) => const PaymentInfoScreen(),
    PhotographerTimeSlotAvailabilityScreen.route: (builder) =>
        const PhotographerTimeSlotAvailabilityScreen(),
    PhotographerDisplayEquipmentsGearScreen.route: (builder) =>
        const PhotographerDisplayEquipmentsGearScreen(),

    PhotographerVerificationSuccessfulScreen.route: (builder) =>
        const PhotographerVerificationSuccessfulScreen(),
    // PhotographerAddEquipmentsScreen.route: (builder) =>
    //     PhotographerAddEquipmentsScreen(),

    PhotographerPreviousBookingScreen.route: (builder) =>
        const PhotographerPreviousBookingScreen(),
    UserEditProfileScreen.route: (builder) => const UserEditProfileScreen(),
    PhotographerAcceptBookingScreen.route: (builder) =>
        const PhotographerAcceptBookingScreen(),
    PhotographerSignupPortfolioMainScreen.route: (builder) =>
        const PhotographerSignupPortfolioMainScreen(),

    PhotographerPendingVerificationScreen.route: (builder) =>
        const PhotographerPendingVerificationScreen(),
    UserBookingConfirmedScreen.route: (builder) =>
        const UserBookingConfirmedScreen(),
    SplashPage.route: (builder) => SplashPage(
          issupportperson: false,
        ),
    PhotographerSinglePortfolioScreen.route: (builder) =>
        const PhotographerSinglePortfolioScreen(),

    UserHomeStartup.route: (builder) => UserHomeStartup(),
    UserSidePhotographerProfileScreen.route: (builder) =>
        const UserSidePhotographerProfileScreen(),

    // older photo clicker
    MyHomePage.route: (builder) => const MyHomePage(),
    ProfileSelectionScreen.route: (builder) => const ProfileSelectionScreen(),

    UserSignupScreen.route: (builder) => const UserSignupScreen(),
    UserLoginScreen.route: (builder) => const UserLoginScreen(),
    ForgotPasswordScreen.route: (builder) => const ForgotPasswordScreen(),
    UserHomeScreen1.route: (builder) => const UserHomeScreen1(),

    AddCardScreen.route: (builder) => const AddCardScreen(),
    ProductDetailScreen.route: (builder) => const ProductDetailScreen(),
    PhotographerSignupScreen.route: (builder) =>
        const PhotographerSignupScreen(),

    PhotographerHomeScreen1.route: (builder) {
      return const PhotographerHomeScreen1();
    },
    PhotographerAllBookingScreen.route: (builder) {
      return const PhotographerAllBookingScreen();
    },

    UserSideDisplayPhotographerEquipmentsScreen.route: (builder) {
      return UserSideDisplayPhotographerEquipmentsScreen();
    },

    // BookingDetailScreen1.route: (builder) => BookingDetailScreen1(),
  };

  // Below routes are used to pass arguments to screens without using ModelRoute class
  static MaterialPageRoute? onGenerateRoutes(settings) {
    if (settings.name == PhotographerAddEquipmentsScreen.route) {
      final args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => PhotographerAddEquipmentsScreen(
          equipment: args['equipment'],
        ),
      );
    } else if (settings.name == MobileNumberInputScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => MobileNumberInputScreen(
          userData: args['data'],
        ),
      );
    } else if (settings.name == VerifyMobileOtpScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => VerifyMobileOtpScreen(
          userData: args['data'],
          verificationId: args['verificationId'],
        ),
      );
    } else if (settings.name == UserRatingPhotographerScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => UserRatingPhotographerScreen(
          bookingDetail: args['bookingDetail'],
        ),
      );
    } else if (settings.name == PhotographerCreateCustomOrderScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => PhotographerCreateCustomOrderScreen(
          groupChatId: args['groupChatId'],
          onSendMessage: args['onSendMessage'],
          peerUserId: args['peerUserId'],
          roomid: args['roomid'],
        ),
      );
    } else if (settings.name == PhtographerDisplayCustomOrder.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => PhtographerDisplayCustomOrder(
          groupChatId: args['groupChatId'],
          onSendMessage: args['onSendMessage'],
          peerUserId: args['peerUserId'],
          roomid: args['roomid'],
        ),
      );
    } else if (settings.name == UserAddNewBookingScreen.route) {
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => UserAddNewBookingScreen(
          selectedPhotographer: args['photographer'],
          customOrder: args['customOrder'],
        ),
      );
    } else if (settings.name == BankDetailFragment.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) =>
            BankDetailFragment(bankAccount: args['bankDetail']),
      );
    } else if (settings.name == ResetPasswordScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(
            email: args['email'] as String, userType: args['user_type']),
      );
    } else if (settings.name == OnBoardingScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => OnBoardingScreen(userType: args['userType']),
      );
    } else if (settings.name == PhotographerAddSkillsScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) =>
            PhotographerAddSkillsScreen(userData: args['data']),
      );
    } else if (settings.name == WelcomeIntroScreen.route) {
      if (settings.arguments == null) {
        return null;
      }
      var args = settings.arguments! as Map<String, dynamic>;
      print(" args['data']: ${args['data']}");
      return MaterialPageRoute(
        builder: (context) => WelcomeIntroScreen(userData: args['data']),
      );
    } else if (settings.name == PhotographerPickWorkImageScreen.route) {
      var args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (context) => PhotographerPickWorkImageScreen(
          portfolioModel: args?['portfolioModel'],
          edit: args?['edit'],
        ),
      );
    } else if (settings.name == PhotographerPortfolioMainScreen.route) {
      var args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (context) => PhotographerPortfolioMainScreen(
          photographerId: args?['photographerId'],
        ),
      );
    } else if (settings.name == PhotographerSignupAddPortfolioScreen.route) {
      var args = settings.arguments as Map<String, dynamic>?;
      // if(args?['photographerId']==null){
      //   args?['photographerId'] = 70;
      // }
      return MaterialPageRoute(
        builder: (context) => PhotographerSignupAddPortfolioScreen(
          // todo change it after verifying

          photographerId: args?['photographerId'],
          fromPortfolio: args?['fromPortfolio'],
        ),
      );
    }

    return null;
  }
}
