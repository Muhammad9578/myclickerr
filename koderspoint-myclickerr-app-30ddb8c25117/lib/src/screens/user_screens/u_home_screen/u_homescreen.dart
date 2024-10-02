import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/screens/shared_screens/market_place_screen.dart';
import 'package:photo_lab/src/screens/user_screens/u_side_photographer_profile_screen/u_hire_photographer_screen.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import '../../../helpers/utils.dart';

class UserHomeScreen1 extends StatefulWidget {
  static const String route = "userHomeScreen1";

  const UserHomeScreen1({super.key});

  @override
  State<UserHomeScreen1> createState() => _UserHomeScreen1State();
}

class _UserHomeScreen1State extends State<UserHomeScreen1>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index == 1) {
          _tabController.animateTo(0);
          return false;
        } else {
          return ExitDialog(context);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Home",
        ),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "Hire a Photographer"),
                Tab(text: "Mart"),
              ],
              unselectedLabelStyle:
                  MyTextStyle.medium07Black.copyWith(fontSize: 16),
              unselectedLabelColor: AppColors.black.withOpacity(0.7),
              labelStyle: MyTextStyle.semiBoldBlack.copyWith(fontSize: 15),
              labelColor: AppColors.black,
              indicatorWeight: 5,
              indicatorColor: AppColors.orange,
              padding: EdgeInsets.only(left: 20, right: 20),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  UserHirePhotographer(),
                  MarketplaceScreen1(),
                  // PhotographerNewBookingRequestScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
