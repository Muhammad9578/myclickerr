import 'package:flutter/material.dart';

import '../../../models/photographer_equipment.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../helpers/helpers.dart';

class UserSideDisplayPhotographerEquipmentsScreen extends StatelessWidget {
  static const route = "UserSideDisplayPhotographerEquipmentsScreen";

  @override
  Widget build(BuildContext context) {
    List<PhotographerEquipment>? equipments = ModalRoute.of(context)!
        .settings
        .arguments as List<PhotographerEquipment>;

    return Scaffold(
      appBar: CustomAppBar(title: "Equipments and Gear", action: []),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: equipments.length == 0
            ? Center(child: EquipmentNotFound())
            : Container(
                // color: Colors.red.shade50,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: equipments.length,
                  // photographerBookings.length,
                  itemBuilder: (context, index) {
                    var equipment = equipments[index];
                    return Container(
                        decoration: BoxDecoration(
                            color: AppColors.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.only(
                            left: 15, top: 15, bottom: 15),
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: FadeInImage.assetNetwork(
                                placeholder: ImageAsset.PlaceholderImg,
                                image: equipment.equipmentImagePath,
                                // .replaceFirst('https', 'http'),
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.15,
                                height:
                                    MediaQuery.of(context).size.width * 0.15,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                    ImageAsset.PlaceholderImg,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    height: MediaQuery.of(context).size.width *
                                        0.15,
                                  );
                                },
                              ),
                            ),
                            10.SpaceX,
                            Expanded(
                              flex: 4,
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
                                      style: MyTextStyle.semiBoldBlack
                                          .copyWith(fontSize: 15),
                                    ),
                                  ),
                                  8.SpaceY,
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      "Price: ${equipment.amount} / ${equipment.amountPer}",
                                      style: MyTextStyle.semiBoldBlack.copyWith(
                                          fontSize: 12, color: AppColors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ));
                  },
                ),
              ),
      ),
    );
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
      ],
    );
  }
}
