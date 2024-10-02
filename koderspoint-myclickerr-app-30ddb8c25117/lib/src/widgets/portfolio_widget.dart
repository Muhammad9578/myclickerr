import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/portfolio_model.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

import '../helpers/utils.dart';

class PortfolioWidget extends StatelessWidget {
  final PortfolioModel portfolioModel;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const PortfolioWidget(
      {super.key,
      required this.portfolioModel,
      required this.onTap,
      required this.onLongPress});

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

    // print(
    //     "width: $w , imagePerLine:$imagePerLine , imgWidth: ${w /
    //         imagePerLine}");
    // print(
    //     "imageLength: ${portfolioModel.images} \n len: ${portfolioModel.images.length}");
    return SizedBox(
      height: w <= 400
          ? portfolioModel.images.length <= imagePerLine
              ? (w / imagePerLine) + 11
              : ((w / imagePerLine) * 2) + 14
          : portfolioModel.images.length <= imagePerLine
              ? (w / imagePerLine) + 23
              : ((w / imagePerLine) * 2) + 29,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              Positioned(
                  left: 10,
                  bottom: 10,
                  right: 10,
                  top: 10,
                  child:
                      // 1st row
                      GridView.count(
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    // padding: const EdgeInsets.all(15),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    crossAxisCount: imagePerLine,
                    children: List.generate(
                        w <= 400 && portfolioModel.images.length > 6
                            ? 6
                            : w <= 600 && portfolioModel.images.length > 10
                                ? 10
                                : portfolioModel.images.length,
                        // <= imagePerLine * 2
                        // ? portfolioModel.images.length - imagePerLine
                        // : imagePerLine,
                        (index) {
                      // print("index: ${index}");
                      return imageContainer(
                          portfolioModel.images[index], w, imagePerLine);
                    }),
                  )),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                top: 0,
                child: Container(
                  // height:
                  //     portfolioModel.images.length <= 3 ? w + 20 / 3 : w + 20 / 4,
                  decoration: BoxDecoration(
                      // color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.shaderBlue.withOpacity(0.5)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 1],
                        colors: [
                          Color(0xff0D0D0D00),
                          Color(0xff0D0D0D).withOpacity(0.8)
                        ],
                      )),
                ),
              ),
              Positioned(
                left: 17,
                bottom: 34,
                child: Text(
                  portfolioModel.title,
                  style: TextStyle(
                      fontSize: 17,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Positioned(
                  left: 17,
                  bottom: 14,
                  child: Text(
                    'Uploaded on ${prettyDateTimePortfolio(portfolioModel.date)}',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  imageContainer(String path, w, imagePerLine) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: AppColors.senderCardLightGreen.withOpacity(0.3),
          blurRadius: 5,
          offset: Offset.zero,
        )
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: FadeTransition(
          opacity: AlwaysStoppedAnimation(1.0),
          child: Image.network(
            path, // Replace with the actual image URL

            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons
                  .error); // Display an error icon if the image fails to load
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                // _handleImageLoaded();
                return child;
              }
              return CupertinoActivityIndicator(
                animating: true,
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
