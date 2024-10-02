import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/helpers.dart';

class DisplayEquipmentWidget extends StatelessWidget {
  const DisplayEquipmentWidget({super.key, required this.equipment});

  final equipment;

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    return Container(
        // width: sw-60,

        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset.zero)
            ]),
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FadeInImage.assetNetwork(
                placeholder: ImageAsset.PlaceholderImg,
                image: '${equipment.equipmentImagePath}',
                // .replaceFirst('https', 'http'),
                fit: BoxFit.cover,
                // width:  sh*0.08,
                // height:  sh*0.08,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    ImageAsset.PlaceholderImg,
                    fit: BoxFit.cover,

                    // width:  sh*0.10,
                    // height:  sh*0.10,
                  );
                },
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
          ],
        ));
  }
}
