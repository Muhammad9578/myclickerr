import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/widgets/portfolio_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controllers/photographer_side_controllers/photographer_portfolio_controller.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/utils.dart';
import '../../../models/portfolio_model.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/empty_portfolio_widget.dart';
import 'p_add_work_image_screen.dart';
import 'p_display_single_portfolio_event.dart';

class PhotographerPortfolioMainScreen extends StatefulWidget {
  static const route = "photographerPortfolioMainScreen";
  final int? photographerId;

  const PhotographerPortfolioMainScreen({Key? key, this.photographerId})
      : super(key: key);

  @override
  State<PhotographerPortfolioMainScreen> createState() =>
      _PhotographerPortfolioMainScreenState();
}

class _PhotographerPortfolioMainScreenState
    extends State<PhotographerPortfolioMainScreen> {
  User? loggedInUser;
  // bool isLoading = true;
  late PhotographerPortfolioController photographerPortfolioController;

  Future<void> deleteDialog(id) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                // color: AppColors.orange,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffFF8E3C), Color(0xffB96C34)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Delete Event',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to delete this event?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.cancel,
                        color: AppColors.black.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.red,
                      ),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(
                          color: AppColors.red, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        photographerPortfolioController.deletePortfolio(id);
        break;
    }
  }

  @override
  initState() {
    super.initState();
    debugLog("photographerId: ${widget.photographerId}");
    photographerPortfolioController =
        Provider.of<PhotographerPortfolioController>(context, listen: false);
    SessionHelper.getUser().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            loggedInUser = value;
            photographerPortfolioController.isloading = false;
            // todo verify this with photographer having empty portfolio
            if (photographerPortfolioController.photographerPortfolio != null) {
              if (photographerPortfolioController
                  .photographerPortfolio!.isEmpty)
                photographerPortfolioController.setPhotographerPortfolio(null);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Portfolio", action: [
        SessionHelper.userType == '1'
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: SizedBox(
                  height: 30,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, PhotographerPickWorkImageScreen.route);
                    },
                    child: Text(
                      "+ Add More",
                      style: MyTextStyle.boldBlack
                          .copyWith(fontSize: 14, color: AppColors.orange),
                    ),
                  ),
                ),
              ),
      ]),
      body: Consumer<PhotographerPortfolioController>(
          builder: (context, portfoliocontroller, _) {
        return loggedInUser == null
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.orange,
                ),
              )
            : SmartRefresher(
                controller: photographerPortfolioRefreshController,
                onRefresh: () {
                  photographerPortfolioController
                      .getPortfolio(widget.photographerId ?? loggedInUser!.id);
                },
                child: Consumer<PhotographerPortfolioController>(
                    builder: (context, portfolioPrvdr, child) {
                  debugLog(
                      "portfolioPrvdr.photographerPortfolio: ${portfolioPrvdr.photographerPortfolio}");
                  if (portfolioPrvdr.photographerPortfolio == null) {
                    portfolioPrvdr.getPortfolio(
                        widget.photographerId ?? loggedInUser!.id);
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    );
                  } else
                    return portfolioPrvdr.photographerPortfolio!.isEmpty
                        ? EmptyPortfolio()
                        : Container(
                            padding: EdgeInsets.only(top: 15),
                            child: portfoliocontroller.isloading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.orange,
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: portfolioPrvdr
                                        .photographerPortfolio!.length,
                                    itemBuilder: (context, index) {
                                      PortfolioModel portfolioModel =
                                          portfolioPrvdr
                                              .photographerPortfolio![index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: PortfolioWidget(
                                          portfolioModel: portfolioModel,
                                          onLongPress: SessionHelper.userType ==
                                                  '1'
                                              ? null
                                              : () {
                                                  deleteDialog(portfolioModel
                                                      .portfolioId);
                                                },
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context,
                                                PhotographerSinglePortfolioScreen
                                                    .route,
                                                arguments: portfolioModel);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          );
                }),
              );
      }),
    );
  }
}
