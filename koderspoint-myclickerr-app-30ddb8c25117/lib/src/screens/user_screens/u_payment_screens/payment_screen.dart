import 'package:flutter/material.dart';
import 'package:photo_lab/src/models/card.dart';
import 'package:photo_lab/src/screens/user_screens/u_payment_screens/payment_info_fragment.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';

class PaymentScreen extends StatelessWidget {
  static const String route = "payment_screen";
  final Function(CardModel? selectedCard)? onCardSelected;

  const PaymentScreen({Key? key, this.onCardSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Payment Cards",
        action: [],
      ),
      body: PaymentInfoFragment(
        onCardSelected: (selectedCard) {
          if (onCardSelected != null) {
            onCardSelected!(selectedCard);
          } else {
            Navigator.pop(context, selectedCard);
          }
        },
      ),
    );
  }
}
