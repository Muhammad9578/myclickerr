import 'package:flutter/material.dart';

import '../helpers/helpers.dart';
import '../screens/photographer_screens/p_portfolio_screens/p_add_work_image_screen.dart';
import 'buttons.dart';

class EmptyPortfolio extends StatelessWidget {
  const EmptyPortfolio({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(
                  Icons.work_history_outlined,
                  size: 28,
                  color: AppColors.black,
                )),
            20.SpaceY,
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0),
              child: Text(
                textAlign: TextAlign.center,
                "There are no work of you visible. Add your work to get discovered more.",
                style: MyTextStyle.mediumBlack.copyWith(fontSize: 18),
              ),
            ),
            30.SpaceY,
            GradientButton(
                text: "+ Add Your Work",
                onPress: onTap ??
                    () {
                      Navigator.pushNamed(
                          context, PhotographerPickWorkImageScreen.route);
                    }),
          ],
        ),
      ),
    );
  }
}
