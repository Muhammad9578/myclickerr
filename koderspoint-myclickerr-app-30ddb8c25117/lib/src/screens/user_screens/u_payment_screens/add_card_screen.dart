import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:photo_lab/src/models/card.dart';
import 'package:photo_lab/src/controllers/user_side_controllers/user_controller.dart';
import 'package:photo_lab/src/helpers/cards_manager.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

import '../../../models/user.dart';
import '../../../helpers/helpers.dart';
import '../../../helpers/session_helper.dart';

class AddCardScreen extends StatefulWidget {
  static const String route = "add_card_screen";

  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  //String cardNumber = '4242 4242 4242 4242'; //test card number
  String cardNumber = '';
  String cardHolderName = '';

  // String bankName = "Bank Name";
  String expiry = '';
  String cvv = '';

  bool isLoading = false;
  bool isCvvFocused = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController cardNumberController = TextEditingController();
  User? loggedInUser;
  late UserController userProvider;

  @override
  void initState() {
    super.initState();
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
    userProvider = context.read<UserController>();
    //userProvider = Provider.of<UserProvider>(context);
    cardNumberController.text = cardNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add Payment Card",
        action: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CreditCardWidget(
                        cardBgColor: AppColors.orange,
                        cardNumber: cardNumber,
                        height: 220,
                        expiryDate: expiry,
                        cardHolderName: cardHolderName,
                        cvvCode: cvv,
                        isHolderNameVisible: true,
                        showBackView: isCvvFocused,
                        onCreditCardWidgetChange: (creditCardBrand) {},
                      ),
                      const SizedBox(
                        height: kDefaultSpace,
                      ),
                      // PrimaryTextField(
                      //   labelText: "Bank Name",
                      //   'Bank Name',
                      //   validator: (value) => value == null || value.isEmpty
                      //       ? 'Please enter bank name'
                      //       : null,
                      //   onChange: (value) {
                      //     setState(() => bankName = value);
                      //   },
                      // ),
                      PrimaryTextField(
                        labelText: "Card Holder Name",
                        'Card Holder Name',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter card holder name'
                            : null,
                        onChange: (value) {
                          setState(() => cardHolderName = value);
                        },
                      ),
                      PrimaryTextField(
                        labelText: "Card Number",
                        '4242 4242 4242 4242',
                        controller: cardNumberController,
                        inputFormatters: [
                          MaskedTextInputFormatter(
                              mask: 'xxxx xxxx xxxx xxxx', separator: ' ')
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          } else if (value.length < 16) {
                            return 'Enter valid card number';
                          }
                          return null;
                        },
                        onChange: (value) {
                          setState(() => cardNumber = value);
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: kDefaultSpace * 0.8,
                          bottom: kDefaultSpace * 0.8,
                        ),
                        child: TextFormField(
                          style:
                              MyTextStyle.semiBoldBlack.copyWith(fontSize: 18),
                          // fillColor: kInputBackgroundColor,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          /*inputFormatters: [
                            CardExpirationFormatter(),
                          ],*/
                          inputFormatters: [
                            MaskedTextInputFormatter(
                                mask: 'xx/xx', separator: '/')
                          ],
                          validator: (value) {
                            // print("exp date: $value");
                            if (value == null || value.isEmpty) {
                              return 'Please enter card expiry';
                            }
                            var expDteLst = value.split('/');
                            if (int.parse(expDteLst[0]) > 12 ||
                                int.parse(expDteLst[0]) <= 0) {
                              return 'Invalid expiry month';
                            }

                            if ((int.parse(expDteLst[1]) + 2000) <=
                                DateTime.now().year - 1) {
                              return 'Invalid expiry year';
                            }
                            if ((int.parse(expDteLst[1]) + 2000) ==
                                DateTime.now().year) {
                              if (int.parse(expDteLst[0]) <
                                  DateTime.now().month + 1) {
                                return 'Invalid expiry month';
                              }
                            }
                            if (value.length < 4) {
                              return 'Invalid date';
                            }
                            if (value.contains('.') ||
                                value.contains('-') ||
                                value.contains(',')) {
                              return 'Invalid card expiry date';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelStyle: MyTextStyle.medium07Black
                                .copyWith(fontSize: 16),
                            hintStyle: MyTextStyle.medium07Black
                                .copyWith(fontSize: 16),
                            // fillColor: kInputBackgroundColor,
                            hintText: 'Expiry Date (MM/YY)',
                            // filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(kInputBorderRadius),
                              borderSide: BorderSide(
                                //strokeAlign: StrokeAlign.center,
                                width: 1,
                                // color: kInputBackgroundColor.withOpacity(0.9),
                              ),
                            ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(kInputBorderRadius),
                                borderSide: BorderSide(
                                    width: 1, color: AppColors.lightGrey)),
                          ),
                          onChanged: (value) {
                            setState(() => expiry = value);
                          },
                        ),
                      ),
                      PrimaryTextField(
                        'Security Code (CVV)',
                        inputFormatters: [
                          MaskedTextInputFormatter(mask: 'xxx', separator: '')
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.length < 3) {
                            return 'Enter valid CVV';
                          }

                          if (value.contains('.') ||
                              value.contains('-') ||
                              value.contains(',')) {
                            return 'Enter valid CVV';
                          }

                          return null;
                        },
                        onChange: (value) {
                          setState(() => cvv = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: kDefaultSpace),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.orange,
                  ))
                : GradientButton(
                    text: 'Add',
                    onPress: () async {
                      if (_formKey.currentState!.validate()) {
                        await CardsManager.addCard(
                          CardModel(
                              loggedInUser?.id ?? 0,
                              cardNumber,
                              cardHolderName,
                              expiry.split('/')[0],
                              expiry.split('/')[1],
                              cvv,
                              'No bank name'),
                        );
                        //Toasty.success('Card Added');
                        Navigator.of(context).pop();
                      }
                    },
                  ),
            const SizedBox(
              height: kDefaultSpace,
            )
          ],
        ),
      ),
    );
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final contains = valueToReturn.contains(RegExp(r'\/'));
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}
