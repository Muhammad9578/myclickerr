import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/utils.dart';
import '../../../models/portfolio_model.dart';
import '../../../models/user.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/primary_text_field.dart';

class PhotographerPickWorkImageScreen extends StatefulWidget {
  PhotographerPickWorkImageScreen({Key? key, this.edit, this.portfolioModel})
      : super(key: key) {
    if (this.edit == null) this.edit = false;
  }

  static const route = "photographerPickWorkImageScreen";
  late bool? edit;
  final PortfolioModel? portfolioModel;

  @override
  State<PhotographerPickWorkImageScreen> createState() =>
      _PhotographerPickWorkImageScreenState();
}

class _PhotographerPickWorkImageScreenState
    extends State<PhotographerPickWorkImageScreen> {
  List<File> selectedImages = []; // List of selected image
  final _formKey = GlobalKey<FormState>();
  // bool isLoading = false;
  bool convertingImagesToFile = false;
  late User loggedInUser;
  final eventName = TextEditingController();

  Future<File> getImage({required String url}) async {
    /// Get Image from server
    final Response res = await Dio().get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    /// Get App local storage
    final Directory appDir = await getApplicationDocumentsDirectory();
    /// Generate Image Name
    final String imageName = url.split('/').last;
    final File file = File(pth.join(appDir.path, imageName));
    file.writeAsBytesSync(res.data as List<int>);
    return file;
  }

  convertingNetworkImageToFile() async {
    if (!mounted) return;
    setState(() {
      convertingImagesToFile = true;
    });
    final images = widget.portfolioModel!.images;
    for (int i = 0; i < images.length; i++) {
      var img = await getImage(url: images[i]);
      selectedImages.add(img);
      if (i == images.length - 1) {
        if (!mounted) return;
        setState(() {
          convertingImagesToFile = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.portfolioModel != null) {
      convertingNetworkImageToFile();
      eventName.text = widget.portfolioModel!.title;
    }
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        if (!mounted) return;
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:
          CustomAppBar(title: widget.edit! ? "Edit Work" : "Add Work", action: []),
      body: Consumer<PhotographerPortfolioController>(
          builder: (context, portfolioPrvdr, child) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
              convertingImagesToFile
                  ? Expanded(
                      child: const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
                      ),
                    )
                  : selectedImages.isEmpty // If no images is selected
                      ? Expanded(
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
                      : Expanded(
                          child: GridView.builder(
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
                                          color:
                                              AppColors.orange.withOpacity(0.1),
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
                                                    selectedImages[index].path)
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
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
                                                selectedImages.removeAt(index);
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
                                                  CupertinoIcons.delete_simple,
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
              convertingImagesToFile
                  ? SizedBox.shrink()
                  : portfolioPrvdr.isloading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        )
                      : GradientButton(
                          text: widget.edit! ? "Update" : "Save Changes",
                          onPress: () {
                            if (_formKey.currentState!.validate()) {
                              if (selectedImages.isEmpty) {
                                Toasty.error("Please upload event media");
                                return;
                              }
                              if (!mounted) return;
                              portfolioPrvdr.savePortfolio(
                                  context: context,
                                  selectedImages: selectedImages,
                                  eventName: eventName.text,
                                  portfolioModel: widget.portfolioModel,
                                  loggedInUser: loggedInUser,
                                  edit: widget.edit);
                            }
                          },
                        )
            ],
          ),
        );
      }),
    );
  }

  emptyContainer(h, w) {
    return InkWell(
      onTap: () async {
        selectedImages = await AppFunctions.pickImagesFromGallery(context);
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
