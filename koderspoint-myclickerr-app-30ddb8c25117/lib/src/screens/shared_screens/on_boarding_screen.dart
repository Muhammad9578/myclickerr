import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/dummy_data.dart';
import 'package:photo_lab/src/models/on_boarding_model.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

import 'package:photo_lab/src/screens/photographer_screens/p_home_startup.dart';
import 'package:photo_lab/src/widgets/buttons.dart';

import '../user_screens/u_home_startup.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String route = 'onBoardingScreen';
  final UserType userType;

  const OnBoardingScreen({Key? key, required this.userType}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late List<OnBoardingContent> _content;
  late PageController _controller;
  int pageIndex = 0;

  // late UserType userType;

  @override
  void initState() {
    _controller = PageController();

    _content = widget.userType.name == "user"
        ? UserOnboardingList()
        : PhotographerOnboardingList();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            45.SpaceY,
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  if (widget.userType == UserType.user) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        UserHomeStartup.route, (Route<dynamic> route) => false);
                  } else if (widget.userType == UserType.photographer) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        PhotographerHomeStartup.route,
                            (Route<dynamic> route) => false);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 15.0, bottom: 15, right: 0, top: 15),
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "Skip",
                    style: MyTextStyle.semiBold05Black.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.02,
            ),
            Flexible(
              fit: FlexFit.loose,
              child: PageView(
                physics: BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
                children: List.generate(
                  _content.length,
                      (index) =>
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset('${_content[index].img}'),
                          Spacer(),
                          Text(
                            '${_content[index].message}',
                            style: MyTextStyle.boldBlack.copyWith(fontSize: 28),
                          ),
                          SizedBox(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.02,
                          ),
                          Text(
                            '${_content[index].description}',
                            style: MyTextStyle.medium07Black
                                .copyWith(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                // color: Colors.blue,
                height: 10,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _content.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.animateTo(
                            MediaQuery
                                .of(context)
                                .size
                                .width * index,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        // height: 20,
                        width: 10,
                        decoration: BoxDecoration(
                          color: index == pageIndex
                              ? AppColors.orange
                              : AppColors.lightOrange.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(50),
                          // border: Border.all(
                          //     width: 6,
                          //     color: index == pageIndex
                          //         ? AppColors.orange
                          //         : AppColors.lightOrange)
                        ),
                      ),
                    );
                  },
                ),
              ),
              GradientButton(
                text: pageIndex == _content.length - 1 ? 'Continue' : "",
                width: pageIndex == _content.length - 1 ? w * 0.5 : w * 0.2,
                icon: Icons.arrow_forward_ios_rounded,
                onPress: () {
                  if (pageIndex == _content.length - 1) {
                    if (widget.userType == UserType.user) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          UserHomeStartup.route,
                              (Route<dynamic> route) => false);
                    } else if (widget.userType == UserType.photographer) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          PhotographerHomeStartup.route,
                              (Route<dynamic> route) => false);
                    }
                  } else {
                    _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  }
                },
              )
            ]),
            30.SpaceY,
          ],
        ),
      ),
    );
  }
}
