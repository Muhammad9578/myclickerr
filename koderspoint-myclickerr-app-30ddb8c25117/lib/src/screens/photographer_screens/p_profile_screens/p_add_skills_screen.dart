import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';
import '../../../helpers/constants.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';
import '../../shared_screens/welcome_intro_screen.dart';

class PhotographerAddSkillsScreen extends StatefulWidget {
  static const String route = "photographerAddSkillsScreen";
  final Map<String, dynamic>? userData;

  PhotographerAddSkillsScreen({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  _PhotographerAddSkillsScreenState createState() =>
      _PhotographerAddSkillsScreenState();
}

class _PhotographerAddSkillsScreenState
    extends State<PhotographerAddSkillsScreen> {

 late PhotographerPortfolioController photographerPortfolioProvider;
  List<String> selectedReportList = [];

  

  @override
  void initState() {
    debugLog("userdata: ${widget.userData}");
    debugLog(selectedReportList);
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
           photographerPortfolioProvider =
           Provider.of<PhotographerPortfolioController>(context, listen: false);
           photographerPortfolioProvider.getskills();
        });
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PhotographerPortfolioController>(
                        builder: (context, portfolioPrvdr, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                20.SpaceY,
                Stack(
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.66,
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
                30.SpaceY,
                kLogoImage,
                25.SpaceY,
                Text(
                  "Add SKills",
                  style: MyTextStyle.boldBlack.copyWith(
                    fontSize: 34,
                  ),
                ),
                10.SpaceY,
                Text(
                  "Adding your skills will give you a good exposure",
                  style: MyTextStyle.medium07Black.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: kDefaultSpace * 3),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Pre Production Skills",
                    style: MyTextStyle.semiBoldBlack.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                15.SpaceY,
                portfolioPrvdr.isloading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.orange,
                  ),
                )
                    : Wrap(
                  children: _buildChoiceList(preProductionSkills),
                ),
                const SizedBox(height: kDefaultSpace * 3),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Post Production Skills",
                    style: MyTextStyle.semiBoldBlack.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                15.SpaceY,
                portfolioPrvdr.isloading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.orange,
                  ),
                )
                    : Wrap(
                  children: _buildChoiceList(postProductionSkills),
                ),
                Spacer(),
               portfolioPrvdr.isloading
                    ? SizedBox.shrink()
                    : GradientButton(
                  onPress: () {
                    if (selectedReportList.isEmpty) {
                      Toasty.error("Please select some skills");
                      return;
                    }
                    String skls = '';

                    for (int i = 0; i < selectedReportList.length; i++) {
                      if (i == selectedReportList.length - 1) {
                        skls += selectedReportList[i];
                      } else {
                        skls += selectedReportList[i] + ', ';
                      }
                    }

                    widget.userData!['skills'] = skls;
                    log("selec: ${widget.userData}");

                    Navigator.pushNamed(
                      context,
                      WelcomeIntroScreen.route,
                      arguments: {
                        'data': widget.userData,
                      },
                    );
                  },
                  text: "Next",
                )
              ],
            ),
          );
        }
      ),
    );
  }

  _buildChoiceList(reportList) {
    List<Widget> choices = [];

    reportList.forEach(
          (item) {
        choices.add(Container(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: MyTextStyle.mediumBlack.copyWith(fontSize: 16),
                ),
                2.SpaceX,
                Icon(
                  Icons.check,
                  size: 15,
                )
              ],
            ),
            backgroundColor: Colors.grey.shade200,
            selected: selectedReportList.contains(item),
            onSelected: (selected) {
              setState(
                    () {
                  if (selectedReportList.contains(item))
                    selectedReportList.remove(item);
                  else
                    selectedReportList.add(item);
                },
              );
            },
          ),
        ));
      },
    );
    return choices;
  }
}
