import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/portfolio_model.dart';
import 'package:photo_lab/src/widgets/portfolio_widget.dart';

import '../../../helpers/helpers.dart';
import '../../../widgets/buttons.dart';

class UserSidePhotographerPortfolioSlider extends StatefulWidget {
  const UserSidePhotographerPortfolioSlider(
      {super.key, required this.portfolioList});

  final List<PortfolioModel> portfolioList;

  @override
  State<UserSidePhotographerPortfolioSlider> createState() =>
      _UserSidePhotographerPortfolioSliderState();
}

class _UserSidePhotographerPortfolioSliderState
    extends State<UserSidePhotographerPortfolioSlider> {
  late List<PortfolioModel> _content;

  // late PageController _controller;
  final CarouselController _controller = CarouselController();

  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    // _controller = PageController();

    _content = widget.portfolioList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double w = width;
    // print("width: $w");

    // subtracting padding from left and right of width other padding (50)
    w -= width <= 400
        ? 45 // 3 images
        : width <= 600
            ? 65 // 5 images
            : 85; // 7 images

    int imagePerLine = w <= 400
        ? 3
        : w <= 600
            ? 5
            : 7;

    return Container(
      height: w <= 400
          ?
          // _content[pageIndex].images.length <= imagePerLine
          //     ? (w / imagePerLine) + 11
          //     :
          ((w / imagePerLine) * 2) + 14
          :
          // _content[pageIndex].images.length <= imagePerLine
          //     ? (w / imagePerLine) + 23
          //     :
          ((w / imagePerLine) * 2) + 29,
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: CarouselSlider(
              items: List.generate(
                _content.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: PortfolioWidget(
                    portfolioModel: _content[index],
                    onLongPress: () {
                      // deleteDialog(_content[index].portfolioId);
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
                ),
              ),
              carouselController: _controller,
              options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: Duration(seconds: 15),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  // autoPlayAnimationDuration: Duration(seconds: 3),
                  aspectRatio: w < 400 ? 1.67 : 6 / 2.25,
                  viewportFraction: 1,
                  pageSnapping: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      pageIndex = index;
                    });
                  }),
            ),

            // PageView(
            //
            //
            //   scrollDirection: Axis.horizontal,
            //   physics: BouncingScrollPhysics(),
            //   controller: _controller,
            //   allowImplicitScrolling: true,
            //   pageSnapping: true,
            //   onPageChanged: (index) {
            //     setState(() {
            //       pageIndex = index;
            //     });
            //   },
            //   children: List.generate(
            //     _content.length,
            //         (index) =>
            //         Padding(
            //           padding: const EdgeInsets.only(bottom: 10.0),
            //           child: PortfolioWidget(
            //             portfolioModel: _content[index],
            //             onLongPress: (){
            //               // deleteDialog(_content[index].portfolioId);
            //             },
            //             onTap: () {
            //               // Navigator.pushNamed(context,
            //               //     PhotographerSinglePortfolioScreen.route,
            //               //
            //               //     arguments:
            //               //     portfolioModel
            //               // );
            //             },
            //           ),
            //         ),
            //   ),
            // ),
          ),
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
                    _controller.animateToPage(pageIndex,
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
        ],
      ),
    );
  }
}
