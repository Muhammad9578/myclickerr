import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/models/product.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/helpers/utils.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String route = 'product_detail_screen';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Product selectedProduct =
        ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: CustomAppBar(title: "Detail", action: []),
      //
      // CustomAp(
      //   title: const Text('Detail'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 190,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(width: 0.3)),
                      child: Image.network(
                        selectedProduct.imageURL,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(
                      height: kDefaultSpace * 4,
                    ),
                    Text(
                      selectedProduct.name,
                      style: MyTextStyle.mediumBlack
                          .copyWith(fontSize: 21, color: AppColors.orange),
                    ),
                    const SizedBox(
                      height: kDefaultSpace * 4,
                    ),
                    Text(
                      'Description',
                      style: MyTextStyle.mediumBlack.copyWith(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      selectedProduct.description,
                      style: MyTextStyle.regularBlack
                          .copyWith(fontSize: 14.5, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: kDefaultSpace,
            ),
            GradientButton(
              text: 'Buy Now',
              onPress: () {
                launchURL(context, selectedProduct.webURL);
              },
            ),
            const SizedBox(
              height: kDefaultSpace,
            ),
          ],
        ),
      ),
    );
  }
}
