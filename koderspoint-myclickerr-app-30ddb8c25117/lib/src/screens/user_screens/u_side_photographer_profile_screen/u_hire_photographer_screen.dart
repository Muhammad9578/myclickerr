import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/u_photographer_controller.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/toast.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/photographer.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../helpers/helpers.dart';
import '../../../modules/chat/pages/splash_page.dart';
import 'UserSidePhotographerProfileScreen.dart';

class UserHirePhotographer extends StatefulWidget {
  const UserHirePhotographer({
    Key? key,
  }) : super(key: key);

  @override
  State<UserHirePhotographer> createState() => _UserHirePhotographerState();
}

class _UserHirePhotographerState extends State<UserHirePhotographer> {
  List<Photographer> photographerList = [];
  late UserController userProvider;
  late UserSidePhotographerController photographerProvider;

  // String searchController.text = '';
  String searchBy = 'time slot';
  var searchController = TextEditingController();

  User? loggedInUser;

  late ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    userProvider = context.read<UserController>();
    photographerProvider = context.read<UserSidePhotographerController>();
    SessionHelper.getUser().then((value) {
      if (value != null) {
        setState(() {
          loggedInUser = value;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scrollController.addListener(scrollHandler);
      //   scrollHandler();
      // _scrollController = ScrollController()..addListener(scrollHandler);

      // _scrollController.addListener(scrollHandler());
    });
  }

  scrollHandler() {
    // // print("len: ${ photographerProvider.allPhotographer!.length}");
    // _scrollController.addListener(() {
    //   log("_scrollController.position.maxScrollExtent: ${_scrollController.position.maxScrollExtent} \n _scrollController.offset: ${_scrollController.offset}");
    //   if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (!photographerProvider.isLoadingMore) {
        if (photographerProvider.currentLoadingPage <=
            photographerProvider.totalPhotographerPages) {
          photographerProvider
              .setCurrentLoadingPage(++photographerProvider.currentLoadingPage);

          photographerProvider.getAllPhotographers(
              loggedInUser!.id,
              double.parse(loggedInUser!.latitude),
              double.parse(loggedInUser!.longitude),
              context);
          photographerProvider.setIsLoadingMore(true);
        }

        // setState(() {
        //   isLoading=true;
        // });
      }
    }
    // });
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: kScreenPadding, bottom: kScreenPadding),
      child: SmartRefresher(
        controller:
            photographerProvider.hirePhotographerScreenRefreshController,
        onRefresh: () {
          // print("loggedInUser!.id: ${loggedInUser!.id}");
          photographerProvider.setCurrentLoadingPage(1);
          photographerProvider.getAllPhotographers(
              loggedInUser!.id,
              double.parse(loggedInUser!.latitude),
              double.parse(loggedInUser!.longitude),
              context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: kScreenPadding, right: kScreenPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      "Search by $searchBy",
                      labelText: searchBy == 'maximum bid amount'
                          ? "Enter maximum price"
                          : searchBy == 'minimum bid amount'
                              ? "Enter minimum price"
                              : searchBy == 'time slot'
                                  ? 'Enter time slot'
                                  : "Enter photographer name",
                      suffixIcon: Icons.search,
                      controller: searchController,
                      keyboardType: searchBy == 'maximum bid amount' ||
                              searchBy == 'minimum bid amount'
                          ? TextInputType.number
                          : TextInputType.text,
                      onChange: (value) {
                        setState(() {
                          // searchController.text = value;
                          // filterSearchResults(value);
                        });
                      },
                    ),
                  ),
                  9.SpaceX,
                  InkWell(
                    onTap: () {
                      searchController.text = '';
                      closeKeyboard(context);
                      showModelBottomSheet();
                    },
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.darkBlack.withOpacity(0.3))),
                      child: SvgPicture.asset(
                        ImageAsset.FilterIcon,
                        height: 20,
                        width: 20,
                        color: AppColors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),

            Flexible(
              fit: FlexFit.loose,
              child: Consumer<UserSidePhotographerController>(
                  builder: (context, photographerListProvider, child) {
                if (photographerListProvider.allPhotographer == null) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  );
                }
                photographerList.clear();
                photographerList.addAll(
                  photographerListProvider.allPhotographer!
                      .where((Photographer element) {
                    //var lst = element.timeslots.iterator;

                    try {
                      // this logic is to convert timeslot to feasible search value given by user
                      if (searchBy == 'time slot') {
                        bool res = false;
                        element.timeslots.forEach((element1) {
                          // print(
                          //     "element.timeslots: ${element.timeslots.toString()}");
                          var spl = element1.split(' ');
                          var num = spl[0].split(':');
                          String finalSearch = '${int.parse(num[0])}${spl[1]}';
                          // // print("final search: $finalSearch");
                          if (finalSearch
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                            // // print("element1 true: ${element1}");

                            res = true;
                          }
                        });

                        return res;
                      } else {
                        return searchBy == 'photographer name'
                            ? searchController.text.isEmpty ||
                                element.name.toLowerCase().contains(
                                      searchController.text.toLowerCase(),
                                    )
                            : searchBy == 'maximum bid amount'
                                ? searchController.text.isEmpty ||
                                    element.perHourPrice <=
                                        double.parse(searchController.text)
                                : searchController.text.isEmpty ||
                                    element.perHourPrice >=
                                        double.parse(searchController.text);
                      }
                    } catch (e) {
                      debugLog("Error: $e");
                      Toasty.error('Invalid search value');
                      return false;
                    }
                  }),
                );

                if (photographerList.isEmpty) {
                  return Center(
                    child: Text('No Photographer available'),
                  );
                }
                if (searchBy == 'maximum bid amount') {
                  photographerList
                      .sort((a, b) => b.perHourPrice.compareTo(a.perHourPrice));
                } else if (searchBy == 'minimum bid amount') {
                  photographerList
                      .sort((a, b) => a.perHourPrice.compareTo(b.perHourPrice));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 10),
                  shrinkWrap: true,
                  // physics: AlwaysScrollableScrollPhysics(),
                  physics: BouncingScrollPhysics(),
                  // shrinkWrap: true,
                  itemCount: photographerList.length,
                  itemBuilder: (context, index) {
                    var photographer = photographerList[index];

                    return GestureDetector(
                      onTap: () {
                        // photographerProvider
                        //     .setSelectedPhotographer(
                        //     photographerList[index]);
                        closeKeyboard(context);
                        Navigator.pushNamed(
                            context, UserSidePhotographerProfileScreen.route,
                            arguments: photographerList[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(kInputBorderRadius),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset.zero)
                          ],
                        ),
                        margin: const EdgeInsets.only(
                            bottom: 12,
                            left: kScreenPadding,
                            right: kScreenPadding),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child:
                                      // FadeInImage(
                                      //   image:
                                      //       NetworkImage(photographer.imageURL),
                                      //   placeholder: const AssetImage(
                                      //     "images/placeholder.png",
                                      //   ),
                                      //   imageErrorBuilder:
                                      //       (context, error, stackTrace) {
                                      //     return Image.asset(
                                      //       ImageAsset.PlaceholderImg,
                                      //       //  fit: BoxFit.fitWidth,
                                      //       width: 50,
                                      //       height: 50,
                                      //     );
                                      //   },
                                      //   // fit: BoxFit.fitWidth,
                                      //   width: 50,
                                      //   height: 50,
                                      // ),

                                      FadeInImage.assetNetwork(
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        ImageAsset.PlaceholderImg,
                                        //  fit: BoxFit.fitWidth,
                                        width: 50,
                                        height: 50,
                                      );
                                    },
                                    placeholder: ImageAsset.PlaceholderImg,
                                    image: photographer.imageURL,
                                    // .replaceFirst('https', 'http'),
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                15.SpaceX,
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    // width: double.infinity,
                                    // color: Colors.red.shade200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${photographer.name}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: "AlbertSans",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColors.black),
                                        ),
                                        8.SpaceY,
                                        Text(
                                          '${photographer.skills}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: MyTextStyle.semiBold05Black
                                              .copyWith(
                                                  fontSize: 12,
                                                  color: AppColors.black
                                                      .withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                15.SpaceX,
                                InkWell(
                                  onTap: () {
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SplashPage(
                                            targetUserId:
                                                photographer.id.toString(),
                                            issupportperson: false,
                                            // SessionHelper.userType == '1'
                                            //     ? photographer.id.toString()
                                            //     : bkDetail.userId.toString(),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color:
                                              AppColors.orange.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Icon(Icons.chat_outlined)),
                                )
                              ],
                            ),
                            15.SpaceY,
                            Divider(
                              color: AppColors.black.withOpacity(0.1),
                              height: 5,
                              thickness: 1,
                            ),
                            15.SpaceY,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Price:',
                                  style: MyTextStyle.mediumBlack.copyWith(
                                      fontSize: 14, color: AppColors.black),
                                ),
                                Spacer(),
                                Text(
                                  '\u{20B9} ${photographer.perHourPrice}',
                                  style: MyTextStyle.semiBold05Black.copyWith(
                                      fontSize: 18, color: AppColors.black),
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // when the _loadMore function is running

            Consumer<UserSidePhotographerController>(
                builder: (context, photographerListProvider, child) {
              return photographerListProvider.isLoadingMore
                  ? Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  showModelBottomSheet() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: AppColors.orange,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBottomSheetBorderRadius)),
        context: context,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: kScreenPadding,
                left: kScreenPadding,
                right: kScreenPadding,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    kScreenPadding * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Search By",
                  style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 18),
                ),
                // MaterialButton(
                //     color: AppColors.cardBackgroundColor,
                //     onPressed: () {
                //       searchController.text = '';
                //       Navigator.pop(context);
                //       setState(() {
                //         searchBy = 'photographer name';
                //       });
                //     },
                //     child: Text("Photographer Name")),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '9am';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'time slot';
                      });
                    },
                    child: Text(
                        'Available Slot (9am, 10am, ..., 3pm, 11pm.. etc)')),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '10000';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'maximum bid amount';
                      });
                    },
                    child: Text('Maximum per hour price')),
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '0';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'minimum bid amount';
                      });
                    },
                    child: Text('Minimum per hour price')),
              ],
            ),
          );
        });
  }
}
