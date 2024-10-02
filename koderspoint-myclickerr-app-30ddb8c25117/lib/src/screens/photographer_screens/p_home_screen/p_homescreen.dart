import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/screens/shared_screens/market_place_screen.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';

import 'p_dashboard.dart';

class PhotographerHomeScreen1 extends StatefulWidget {
  static const String route = "photographerHomeScreen1";

  const PhotographerHomeScreen1({super.key});

  @override
  State<PhotographerHomeScreen1> createState() =>
      _PhotographerHomeScreen1State();
}

class _PhotographerHomeScreen1State extends State<PhotographerHomeScreen1>
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
    //var photographerBookingListProvider = Provider.of<PhotographerBookingListProvider>(context, listen: false);

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
        // extendBody: true,
        // extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: "Home",
        ),

        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "Dashboard"),
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
                  PhotographerDashboardScreen(),
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
