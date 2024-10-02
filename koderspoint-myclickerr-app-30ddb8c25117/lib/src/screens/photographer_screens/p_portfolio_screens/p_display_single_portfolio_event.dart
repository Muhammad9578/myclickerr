import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:photo_lab/src/screens/photographer_screens/p_portfolio_screens/p_add_work_image_screen.dart';
import 'package:photo_lab/src/widgets/portfolio_widget.dart';

import '../../../models/portfolio_model.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/session_helper.dart';
import '../../../helpers/utils.dart';

class PhotographerSinglePortfolioScreen extends StatelessWidget {
  static const route = "photographerSinglePortfolioScreen";

  const PhotographerSinglePortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PortfolioModel portfolioModel =
        ModalRoute.of(context)!.settings.arguments as PortfolioModel;
    double width = MediaQuery.of(context).size.width;
    double w = width;
    print("width: $w");

    // subtracting padding from left and right of width other padding (50)
    w -= width <= 400
        ? 45 // 3 images
        : width <= 600
            ? 65 // 5 images
            : 85; // 7 images

    int imagePerLine = w <= 400
        ? 2
        : w <= 600
            ? 4
            : 6;

    return Scaffold(
      appBar: CustomAppBar(title: "", elevation: 0, action: [
        SessionHelper.userType == '1'
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, PhotographerPickWorkImageScreen.route,
                          arguments: {
                            'edit': true,
                            'portfolioModel': portfolioModel
                          });
                    },
                    icon: Text(
                      'Edit',
                      style: MyTextStyle.boldBlack
                          .copyWith(fontSize: 14, color: AppColors.orange),
                    )),
              )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${portfolioModel.title}',
              style: TextStyle(
                  fontSize: 26,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black),
            ),
            14.SpaceY,
            Text(
              'Uploaded on ${prettyDateTimePortfolio(portfolioModel.date)}',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black),
            ),
            14.SpaceY,
            Expanded(
              child: GridView.count(
                primary: false,
                // physics: NeverScrollableScrollPhysics(),
                // padding: const EdgeInsets.all(15),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                crossAxisCount: imagePerLine,
                children: List.generate(
                  // w <= 400 && portfolioModel.images.length > 6
                  //     ? 6
                  //     : w <= 600 && portfolioModel.images.length > 10
                  //         ? 10
                  //         :
                  portfolioModel.images.length,
                  // <= imagePerLine * 2
                  // ? portfolioModel.images.length - imagePerLine
                  // : imagePerLine,
                  (index) {
                    print("index: ${index}");
                    return imageContainer(
                        portfolioModel.images[index], w, imagePerLine);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  imageContainer(String path, w, imagePerLine) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGreen.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: FadeTransition(
          opacity: AlwaysStoppedAnimation(1.0),
          child: Image.network(
            path,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                print("loadingProgress: $loadingProgress , child:$child");
                // _handleImageLoaded();
                return child;
              }
              return CupertinoActivityIndicator(
                animating: false,
              );
            },
          ),
        ),

        // FadeInImage.assetNetwork(
        //   placeholder: ImageAsset.LogoImage,
        //   image: path,
        //   // .replaceFirst('https', 'http'),
        //   fit: BoxFit.fill,
        //   fadeInDuration: Duration(milliseconds: 300),
        //   fadeOutDuration: Duration(milliseconds: 100),
        //   imageErrorBuilder: (context, error, stackTrace) {
        //     return
        //         // CupertinoActivityIndicator(
        //         //   animating: true,
        //         //   // value: downloadProgress.progress,
        //         // );
        //         Image.asset(
        //       ImageAsset.PlaceholderImg,
        //       fit: BoxFit.fitWidth,
        //       width: 100,
        //       height: 100,
        //     );
        //   },
        // ),

        //     CachedNetworkImage(
        //   // placeholder: (context, url) => Image.asset(ImageAsset.LogoImage),
        //   // Custom progress indicator
        //   imageUrl: path,
        //   // Replace with the actual image URL
        //   imageBuilder: (context, imageProvider) => FadeInImage(
        //     placeholder: AssetImage(ImageAsset.LogoImage),
        //     image: imageProvider,
        //     fit: BoxFit.fill,
        //     fadeInDuration: Duration(milliseconds: 300),
        //     fadeOutDuration: Duration(milliseconds: 100),
        //     // width: 200,
        //     // height: 200,
        //   ),
        //   progressIndicatorBuilder: (context, url, downloadProgress) {
        //     // Custom progress indicator builder
        //     return Center(
        //       child: CupertinoActivityIndicator(
        //         animating: true,
        //         // value: downloadProgress.progress,
        //       ),
        //     );
        //   },
        // ),
      ),

      // Image.network(path, errorBuilder: (context, error, stackTrace) {
      //   return Text(
      //     'Uploaded on ${path}',
      //     style: TextStyle(fontSize: 12, color: AppColors.white),
      //   );
      // }, fit: BoxFit.fill),
      // ),
    );
  }
}
