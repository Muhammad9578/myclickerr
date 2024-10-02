import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_lab/src/controllers/shared_controllers/sharedcontroller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/models/category.dart';
import 'package:photo_lab/src/models/product.dart';
import 'package:photo_lab/src/screens/market_place_screens/product_detail_screen.dart';
import 'package:photo_lab/src/widgets/category_list_item.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

class MarketplaceScreen1 extends StatefulWidget {
  // final UserType userType;

  const MarketplaceScreen1({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen1> createState() => _MarketplaceScreen1State();
}

class _MarketplaceScreen1State extends State<MarketplaceScreen1> {
  // bool isLoading = false;
  Future<List<Category>?>? _value;
  Future<List<Product>?>? _futureProducts;

  List<Product> backupProductsList = [];
  List<Product> productList = [];

  // String searchController.text = '';
  String searchBy = 'name';

  var searchController = TextEditingController();

  late SharedController sharedController;
  @override
  void initState() {
    super.initState();
    sharedController = Provider.of<SharedController>(context, listen: false);
    // print("_value: $_value");
    _value = sharedController.fetchCategories();
    _futureProducts = sharedController.fetchProducts(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kScreenPadding),
      child: _value == null
          ? const Center(
              child: Text("Daa not available. Please refresh!"),

              // CircularProgressIndicator(color: AppColors.orange),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PrimaryTextField(
                        controller: searchController,
                        "Search...",
                        suffixIcon: Icons.search,
                        onChange: (value) {
                          //filterSearchResults(value);
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
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 40,
                  child: FutureBuilder(
                    future: _value,
                    builder:
                        (context, AsyncSnapshot<List<Category>?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            // child: CircularProgressIndicator(
                            //     color: AppColors.orange),
                            );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data != null) {
                          List<Category> categoryList = snapshot.data!;
                          // if (!categoriesAvailable) {
                          //   if (mounted)
                          //     setState(() {
                          //       categoriesAvailable = true;
                          //     });
                          // }

                          return ListView.builder(
                            itemCount: categoryList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return CategoryListItem(
                                categoryList[index].name,
                                isSelected: categoryList[index].isSelected,
                                onPress: () {
                                  searchController.text = '';

                                  setState(() {
                                    for (int i = 0;
                                        i < categoryList.length;
                                        i++) {
                                      categoryList[i].isSelected = i == index;
                                    }
                                    _futureProducts = sharedController
                                        .fetchProducts(categoryList[index].id);
                                    // print("_futureProducts: $_futureProducts");
                                  });
                                },
                              );
                            },
                          );
                        } else {
                          return const Text('No data available');
                        }
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                // !categoriesAvailable
                //     ? SizedBox.shrink()
                //     :
                FutureBuilder(
                  future: _futureProducts,
                  builder: (context, AsyncSnapshot<List<Product>?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data != null) {
                        productList.clear();
                        productList.addAll(snapshot.data!.where((element) =>
                            searchController.text.isEmpty ||
                            element.name.toLowerCase().contains(
                                searchController.text.toLowerCase())));
                        //backupProductsList.addAll(snapshot.data!);
                        // print("productList: ${productList}");
                        if (productList.isEmpty) {
                          return const Expanded(
                              child: Center(
                            child: Text('No products available'),
                          ));
                        }
                        return Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.zero,
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: productList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ProductDetailScreen.route,
                                      arguments: productList[index]);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  color: const Color(0xFFE7E7E7),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                            width: 100,
                                            margin: const EdgeInsets.only(
                                                top: 2, bottom: 2, left: 2),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              /*border: Border(
                                        top: BorderSide(width: 0.25),
                                        left: BorderSide(width: 0.25),
                                        bottom: BorderSide(width: 0.25),
                                      ),*/
                                            ),
                                            child: Image.network(
                                              productList[index].imageURL,
                                              width: 100,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return Image.asset(
                                                  ImageAsset.PlaceholderImg,
                                                  width: 100,
                                                );
                                              },
                                            )),
                                        //const SizedBox(width: 12),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  productList[index].name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.orange,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  productList[index]
                                                      .description,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                /*const SizedBox(height: 10),
                                          Row(
                                            children: const [
                                              Text(
                                                '',
                                                style: TextStyle(
                                                    color:
                                                    orange),
                                              ),
                                              */ /*const Spacer(),
                                              Text(
                                                "\u{20B9}${productList[index].price}",
                                                style: const TextStyle(
                                                    color:
                                                    orange),
                                              ),*/ /*
                                            ],
                                          )*/
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Text('No data available');
                      }
                    } else {
                      return Expanded(child: Container());
                    }
                  },
                ),
              ],
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
                MaterialButton(
                    color: AppColors.cardBackgroundColor,
                    onPressed: () {
                      searchController.text = '';
                      Navigator.pop(context);
                      setState(() {
                        searchBy = 'name';
                      });
                    },
                    child: Text("Product name")),
              ],
            ),
          );
        });
  }
}
