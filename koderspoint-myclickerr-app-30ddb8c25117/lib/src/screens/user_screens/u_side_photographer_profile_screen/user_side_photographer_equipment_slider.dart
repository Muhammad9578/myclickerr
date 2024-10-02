import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/photographer_equipment.dart';

import '../../../helpers/helpers.dart';
import '../../../widgets/display_equipment_widget.dart';

class UserSidePhotographerEquipmentSlider extends StatefulWidget {
  const UserSidePhotographerEquipmentSlider(
      {super.key, required this.portfolioList});

  final List<PhotographerEquipment> portfolioList;

  @override
  State<UserSidePhotographerEquipmentSlider> createState() =>
      _UserSidePhotographerEquipmentSliderState();
}

class _UserSidePhotographerEquipmentSliderState
    extends State<UserSidePhotographerEquipmentSlider> {
  late List<PhotographerEquipment> _content;

  // late PageController _controller;
  final CarouselController _controller1 = CarouselController();

  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    // _controller = PageController();
// if(widget.portfolioList.length>3){
//   for(int i=0;i<3;i++){
//     _content.add(widget.portfolioList[i]);
//   }
// }else
    _content = widget.portfolioList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ListView.builder(
          //   itemCount:
          //   photographer.photographerEquipment.length>=3?3: photographer.photographerEquipment.length,
          //
          //   shrinkWrap: true,
          //   physics: BouncingScrollPhysics(),
          //   scrollDirection: Axis.horizontal,
          //   itemBuilder: (context, index) {
          //     PhotographerEquipment equipment =
          //     photographer.photographerEquipment[index];
          //     return
          //       DisplayEquipmentWidget(equipment: equipment);
          //     //   Container(
          //     //   margin: EdgeInsets.only(bottom: 15),
          //     //   padding: EdgeInsets.only(
          //     //       top: 15, bottom: 15, left: 20, right: 20),
          //     //   decoration: BoxDecoration(
          //     //     color: AppColors.cardBackgroundColor,
          //     //     borderRadius: BorderRadius.circular(10),
          //     //   ),
          //     //   child: Text(
          //     //     "${equipment.name}",
          //     //     style: MyTextStyle.semiBoldBlack
          //     //         .copyWith(fontSize: 18),
          //     //   ),
          //     // );
          //   },
          // ),
          Flexible(
            fit: FlexFit.loose,
            child: CarouselSlider(
              items: List.generate(
                  _content.length > 3 ? 3 : _content.length,
                      (index) =>
                      DisplayEquipmentWidget(equipment: _content[index])),
              carouselController: _controller1,
              options: CarouselOptions(
                  initialPage: 0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  // autoPlayAnimationDuration: Duration(seconds: 3),
                  aspectRatio: sw < 400 ? 6 / 1.8 : 6 / 1.6,
                  viewportFraction: 0.94,
                  pageSnapping: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      pageIndex = index;
                    });
                  }),
            ),

          ),
          Container(
            // color: Colors.blue,
            height: 10,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _content.length > 3 ? 3 : _content.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _controller1.animateToPage(pageIndex,
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
