import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/utils.dart';
import '../../../models/photographer_equipment.dart';
import '../../../models/user.dart';
import '../../../widgets/custom_appbar.dart';
import 'p_add_equipment.dart';

class PhotographerDisplayEquipmentsGearScreen extends StatefulWidget {
  static const route = "photographerDisplayEquipmentsGearScreen";

  const PhotographerDisplayEquipmentsGearScreen({Key? key}) : super(key: key);

  @override
  State<PhotographerDisplayEquipmentsGearScreen> createState() =>
      _PhotographerDisplayEquipmentsGearScreenState();
}

class _PhotographerDisplayEquipmentsGearScreenState
    extends State<PhotographerDisplayEquipmentsGearScreen> {
  // bool isLoading = false;
  User? loggedInUser;
  //
  late ScrollController _scrollController = ScrollController();

  bool isLoadingMore = false;
  late PhotorapherController photorapherController;
  @override
  initState() {
    super.initState();
    photorapherController =
        Provider.of<PhotorapherController>(context, listen: false);
    SessionHelper.getUser().then((value) {
      if (value != null) {
        photorapherController.fetchEquipments(
            loggedInUser!.id, photographerEquipmentRefreshController);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _scrollController.addListener(scrollHandler);
          //   scrollHandler();
          // _scrollController = ScrollController()..addListener(scrollHandler);

          // _scrollController.addListener(scrollHandler());
        });
        // fetchData(loggedInUser!.id, 31.3952319, 74.2570513);
      }
    });
  }

  scrollHandler() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (!isLoadingMore) {
        if (photorapherController.currentLoadingPage <=
            photorapherController.totalPhotographerPages) {
          ++photorapherController.currentLoadingPage;
          photorapherController.fetchEquipments(
              loggedInUser!.id, photographerEquipmentRefreshController);

          isLoadingMore = true;
          setState(() {});
        }
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
    double sw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(title: "Equipments and Gear", action: [
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 10),
          child: SizedBox(
            height: 30,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, PhotographerAddEquipmentsScreen.route,
                    arguments: {'equipment': null});
              },
              child: Text(
                "+ Add New",
                style: MyTextStyle.boldBlack
                    .copyWith(fontSize: 14, color: AppColors.orange),
              ),
            ),
          ),
        ),
      ]),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Center(
          child: Consumer<PhotorapherController>(
              builder: (context, photorapherController, _) {
            return SmartRefresher(
              controller: photographerEquipmentRefreshController,
              onRefresh: () {
                photorapherController.currentLoadingPage = 1;
                photorapherController.fetchEquipments(
                    loggedInUser!.id, photographerEquipmentRefreshController);
              },
              child: photorapherController.equipments == null ||
                      photorapherController.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    )
                  : photorapherController.equipments!.length == 0
                      ? EquipmentNotFound()
                      : Container(
                          // color: Colors.red.shade50,
                          child: Column(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: ListView.builder(
                                controller: _scrollController,
                                // scrollDirection: Axis.vertical,
                                padding: EdgeInsets.zero,
                                physics: BouncingScrollPhysics(),
                                // shrinkWrap: true,
                                itemCount:
                                    photorapherController.equipments!.length,
                                // photographerBookings.length,
                                itemBuilder: (context, index) {
                                  var equipment =
                                      photorapherController.equipments![index];
                                  return equipmentBuild(equipment, sw);
                                },
                              ),
                            ),
                            isLoadingMore
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: AppColors.orange,
                                  ))
                                : SizedBox.shrink(),
                          ],
                        )),
            );
          }),
        ),
      ),
    );
  }

  Widget equipmentBuild(PhotographerEquipment equipment, sw) {
    return Container(
        decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.dropWhiteShadow, //.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset.zero)
            ]),
        padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
        margin: EdgeInsets.only(bottom: 15),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FadeInImage.assetNetwork(
                  placeholder: ImageAsset.PlaceholderImg,
                  image: '${equipment.equipmentImagePath}',
                  // .replaceFirst('https', 'http'),
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      ImageAsset.PlaceholderImg,
                      //  fit: BoxFit.fitWidth,
                      width: 50,
                      height: 50,
                    );
                  },
                ),
              ),
            ),
            10.SpaceX,
            Expanded(
              child: Container(
                // color: Colors.red.shade200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        "${equipment.name}",
                        overflow: TextOverflow.ellipsis,
                        style: MyTextStyle.semiBoldBlack.copyWith(fontSize: 14),
                      ),
                    ),
                    5.SpaceY,
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        "Price: ${equipment.amount} / ${equipment.amountPer}",
                        style: MyTextStyle.semiBoldBlack
                            .copyWith(fontSize: 12, color: AppColors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            5.SpaceX,
            MaterialButton(
              shape: ShapeBorder.lerp(
                CircleBorder(),
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                true ? 1.0 : 0.0,
              )!,
              padding: EdgeInsets.all(10),
              minWidth: 0,
              onPressed: () {
                Navigator.pushNamed(
                    context, PhotographerAddEquipmentsScreen.route,
                    arguments: {'equipment': equipment});
              },
              child: SvgPicture.asset(
                ImageAsset.EditIcon,
                height: sw * 0.06,
                width: sw * 0.06,
              ),
            ),
            MaterialButton(
              shape: ShapeBorder.lerp(
                CircleBorder(),
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                true ? 1.0 : 0.0,
              )!,
              padding: EdgeInsets.all(10),
              minWidth: 0,
              onPressed: () {
                deleteDialog('Delete Equipment',
                    'Are you sure to delete this equipment', context, () {
                  Navigator.pop(context); // closing dialog
                  photorapherController.deleteEquipment(
                      equipment.id, photographerEquipmentRefreshController);
                });
              },
              child: SvgPicture.asset(
                ImageAsset.DeleteIcon,
                height: sw * 0.06,
                width: sw * 0.06,
              ),
            ),
          ],
        ));
  }
}

class EquipmentNotFound extends StatelessWidget {
  const EquipmentNotFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5)),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 25,
              color: AppColors.black,
            )),
        20.SpaceY,
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Text(
            textAlign: TextAlign.center,
            "There are no equipments or gear added!",
            style: MyTextStyle.mediumBlack.copyWith(fontSize: 20),
          ),
        ),
        30.SpaceY,
        GradientButton(
            text: "+ Add Equipment or Gear",
            onPress: () {
              Navigator.pushNamed(
                  context, PhotographerAddEquipmentsScreen.route,
                  arguments: {'equipment': null});
            }),
      ],
    );
  }
}
