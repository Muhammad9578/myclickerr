import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../helpers/constants.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/toast.dart';
import '../../../widgets/primary_text_field.dart';

class PhotographerSignupAddPortfolioScreen extends StatefulWidget {
  static const String route = "photographerSignupAddPortfolioScreen";
  final int photographerId;
  bool? fromPortfolio;

  PhotographerSignupAddPortfolioScreen(
      {Key? key, required this.photographerId, this.fromPortfolio})
      : super(key: key) {
    if (fromPortfolio == null) {
      this.fromPortfolio = false;
    }
  }

  @override
  State<PhotographerSignupAddPortfolioScreen> createState() =>
      _PhotographerSignupAddPortfolioScreenState();
}

class _PhotographerSignupAddPortfolioScreenState
    extends State<PhotographerSignupAddPortfolioScreen> {
  bool terms = false;
  List<File> selectedImages = []; // List of selected image
  final picker = ImagePicker(); // Instance of Image picker
  final _formKey = GlobalKey<FormState>();
  final eventName = TextEditingController();

  Future pickImagesFromGallery() async {
    final pickedFile = await picker.pickMultiImage(
        // imageQuality: 100, // To set quality of images
        // maxHeight: 300, // To set maxheight of images that you want in your app
        // maxWidth: 300
        ); // To set maxheight of images that you want in your app
    List<XFile> xfilePick = pickedFile;

    if (xfilePick.isNotEmpty) {
      for (var i = 0; i < xfilePick.length; i++) {
        selectedImages.add(File(xfilePick[i].path));
      }
      if (!mounted) return;
      setState(
        () {},
      );
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1), content: Text('Nothing selected')));
    }
  }

  late PhotographerPortfolioController photographerportfolio;
  @override
  void initState() {
    super.initState();
    photographerportfolio =
        Provider.of<PhotographerPortfolioController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        if (widget.fromPortfolio!)
          return await true;
        else
          return await false;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                bottom: 60,
                right: 0,
                top: 0,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            width: MediaQuery.of(context).size.width * 0.75,
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
                      30.SpaceY,
                      Text(
                        textAlign: TextAlign.center,
                        "My Portfolio",
                        style: MyTextStyle.boldBlack.copyWith(
                          fontSize: 30,
                        ),
                      ),
                      10.SpaceY,
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10.0),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Add your photos or videos to build a portfolio",
                          style: MyTextStyle.medium07Black.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      20.SpaceY,
                      Form(
                        key: _formKey,
                        child: PrimaryTextField(
                          labelText: "Event name",
                          'Event name',
                          controller: eventName,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter event name'
                              : null,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      10.SpaceY,
                      selectedImages.isEmpty // If no images is selected
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Add Media",
                                    style: MyTextStyle.medium07Black
                                        .copyWith(fontSize: 14),
                                  ),
                                  5.SpaceY,
                                  emptyContainer(h, w),
                                ],
                              ),
                            )
                          // If atleast 1 images is selected
                          : Flexible(
                              fit: FlexFit.loose,
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: selectedImages.length + 1,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  crossAxisCount: w <= 400
                                      ? 2
                                      : w <= 600
                                          ? 4
                                          : 6,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  // TO show selected file
                                  return index == selectedImages.length
                                      ? emptyContainer(h, w)
                                      : Container(
                                          margin: EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors
                                                      .senderCardLightGreen
                                                      .withOpacity(0.3),
                                                  blurRadius: 5,
                                                  offset: Offset.zero,
                                                ),
                                              ],
                                              color: AppColors.orange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: AppColors.black
                                                      .withOpacity(0.05))),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                bottom: 0,
                                                top: 0,
                                                child: kIsWeb
                                                    ? Image.network(
                                                        selectedImages[index]
                                                            .path)
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        child: Image.file(
                                                          selectedImages[index],
                                                          fit: BoxFit.fill,
                                                        )),
                                              ),
                                              Positioned(
                                                right: 6,
                                                bottom: 6,
                                                child: InkWell(
                                                  onTap: () {
                                                    selectedImages
                                                        .removeAt(index);
                                                    if (!mounted) return;
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.white,
                                                    ),
                                                    child: Icon(
                                                      CupertinoIcons
                                                          .delete_simple,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                },
                              ),
                            ),
                      15.SpaceY,
                    ],
                  ),
                ),
              ),
              Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Consumer<PhotographerPortfolioController>(
                      builder: (context, photographerportfolio, _) {
                    return photographerportfolio.isloading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.orange),
                          )
                        : GradientButton(
                            text: "Save your work",
                            onPress: () {
                              closeKeyboard(context);
                              if (_formKey.currentState!.validate()) {
                                if (selectedImages.isEmpty) {
                                  Toasty.error("Please upload event media");
                                  return;
                                }
                                if (!mounted) return;
                                photographerportfolio.savePortfolio1(
                                    context,
                                    selectedImages,
                                    widget.photographerId,
                                    eventName.text.toString(),
                                    widget.fromPortfolio);
                              }
                            },
                          );
                  }))
            ],
          ),
        ),
      ),
    );
  }

  emptyContainer(h, w) {
    return InkWell(
      onTap: () {
        pickImagesFromGallery();
      },
      child: Container(
        height: h * 0.2,
        width: h * 0.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border:
                Border.all(width: 1, color: AppColors.black.withOpacity(0.4))),
        child: Icon(CupertinoIcons.camera,
            size: 32, color: AppColors.black.withOpacity(0.3)),
      ),
    );
  }
}
