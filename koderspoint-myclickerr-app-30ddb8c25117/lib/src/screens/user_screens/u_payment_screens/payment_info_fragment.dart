import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:photo_lab/src/models/card.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/cards_manager.dart';
import 'package:photo_lab/src/helpers/constants.dart';

import 'package:photo_lab/src/helpers/utils.dart';
import 'package:photo_lab/src/screens/user_screens/u_payment_screens/add_card_screen.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/session_helper.dart';

class PaymentInfoFragment extends StatefulWidget {
  final void Function(CardModel)? onCardSelected;

  const PaymentInfoFragment({this.onCardSelected, Key? key}) : super(key: key);

  @override
  State<PaymentInfoFragment> createState() => PaymentInfoFragmentState();
}

class PaymentInfoFragmentState extends State<PaymentInfoFragment> {
  var cardsList = [];

  late UserController userProvider;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
          fetchCards();
        });
      }
    });
    userProvider = context.read<UserController>();
  }

  void fetchCards() {
    CardsManager.getCardsList(loggedInUser!.id).then((value) {
      setState(() {
        cardsList.clear();
        cardsList.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: cardsList.isEmpty
                  ? const Center(
                      child: Text('No cards available'),
                    )
                  : Column(
                      children: [
                        Text(
                          'Select Card to Proceed',
                          style: MyTextStyle.semiBold05Black
                              .copyWith(fontSize: 16, color: AppColors.black),
                        ),
                        15.SpaceY,
                        Expanded(
                          child: ListView.builder(
                            itemCount: cardsList.length,
                            itemBuilder: (context, index) {
                              return CardListItem(
                                cardsList[index],
                                cardsList[index].number,
                                getCardType(cardsList[index].number),
                                '${cardsList[index].expiryMonth}/${cardsList[index].expiryYear}',
                                cardsList[index].isDefault,
                                onTap: () {
                                  CardsManager.setDefaultCard(
                                          index, loggedInUser!.id)
                                      .then(
                                    (value) {
                                      fetchCards();
                                      widget.onCardSelected!(cardsList[index]);
                                    },
                                  );
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete Card'),
                                        content: const Text(
                                            'Do you want to delete this card?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              CardsManager.deleteCard(
                                                      index, loggedInUser!.id)
                                                  .then(
                                                (value) {
                                                  fetchCards();
                                                },
                                              );
                                            },
                                            child: const Text('Yes'),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )),
          GradientButton(
            text: 'Add Payment Card',
            onPress: () async {
              await Navigator.pushNamed(context, AddCardScreen.route);
              fetchCards();
            },
          ),
          const SizedBox(height: kDefaultSpace)
        ],
      ),
    );
  }
}

class CardListItem extends StatelessWidget {
  final String cardNumber;
  final String cardType;
  final String cardExpiry;
  final bool isDefault;
  final void Function() onTap;
  final void Function()? onLongPress;
  final CardModel cardDetail;

  const CardListItem(this.cardDetail, this.cardNumber, this.cardType,
      this.cardExpiry, this.isDefault,
      {required this.onTap, this.onLongPress, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              CreditCardWidget(
                padding: 0,
                cardBgColor: AppColors.orange,
                cardNumber: cardNumber,
                // bankName: cardDetail.bankName,
                height: 220,
                expiryDate:
                    "${cardDetail.expiryMonth}/${cardDetail.expiryYear}",
                cardHolderName: cardDetail.name,
                cvvCode: cardDetail.cvv,
                isHolderNameVisible: true,
                showBackView: false,
                onCreditCardWidgetChange: (creditCardBrand) {},
              ),
              Positioned(
                right: 2,
                top: 2,
                child: SizedBox(
                  height: 24,
                  child: isDefault
                      ? const Icon(Icons.check_circle, color: AppColors.black)
                      : null,
                ),
              )
            ],
          ),
        ),
        const Divider(
          color: Color(0xFF7A7A7A),
        )
      ],
    );
  }
}
