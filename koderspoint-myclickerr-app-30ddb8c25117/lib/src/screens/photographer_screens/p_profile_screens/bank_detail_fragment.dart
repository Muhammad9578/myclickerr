import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:photo_lab/src/helpers/constants.dart';
import 'package:photo_lab/src/helpers/session_helper.dart';
import 'package:photo_lab/src/models/bank_account.dart';
import 'package:photo_lab/src/models/user.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:photo_lab/src/widgets/custom_appbar.dart';
import 'package:photo_lab/src/widgets/primary_text_field.dart';
import 'package:provider/provider.dart';

class BankDetailFragment extends StatefulWidget {
  static const String route = "bankDetailFragment";
  final BankAccount? bankAccount;

  const BankDetailFragment({Key? key, this.bankAccount}) : super(key: key);

  @override
  State<BankDetailFragment> createState() => _BankDetailFragmentState();
}

class _BankDetailFragmentState extends State<BankDetailFragment> {
  // bool isLoading = false;
  User? loggedInUser;

  BankAccount? bankAccount;
  bool edit = false;

  TextEditingController bankController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late PhotorapherController photorapherController;
  @override
  void initState() {
    super.initState();
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        this.loggedInUser = loggedInUser;
        bankAccount = widget.bankAccount;
        if (bankAccount != null) {
          bankController.text = bankAccount!.bankName;
          accountNumberController.text = bankAccount!.accountNumber;
          nameController.text = bankAccount!.accountHolderName;
          countryController.text = bankAccount!.country;
        }
        setState(() {});
      }
    });
    photorapherController =
        Provider.of<PhotorapherController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Bank Detail', action: []),
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
                      PrimaryTextField(
                        labelText: 'Bank name',
                        'Bank name',
                        controller: bankController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                        onChange: (value) {
                          if (bankAccount != null) {
                            bankAccount!.bankName = value;
                          }
                        },
                      ),
                      PrimaryTextField(
                        labelText: 'Account Number',
                        'Account Number',
                        controller: accountNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          return null;
                        },
                        onChange: (value) {
                          if (bankAccount != null) {
                            bankAccount!.accountNumber = value;
                          }
                        },
                      ),
                      PrimaryTextField(
                        labelText: 'Account Holder Name',
                        'Account Holder Name',
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Account Holder Name';
                          }
                          return null;
                        },
                        onChange: (value) {
                          if (bankAccount != null) {
                            bankAccount!.accountHolderName = value;
                          }
                        },
                      ),
                      PrimaryTextField(
                        labelText: "Country",
                        'Country',
                        controller: countryController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Country Name';
                          }
                          return null;
                        },
                        onChange: (value) {
                          if (bankAccount != null) {
                            bankAccount!.country = value;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Consumer<PhotorapherController>(
                builder: (context, photographercontroller, _) {
              return photographercontroller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    )
                  : GradientButton(
                      text: 'Save',
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          if (bankAccount != null) {
                            photographercontroller.updateBankDetails(
                                context, bankAccount!, loggedInUser!.id);
                          }
                        }
                      },
                    );
            }),
          ],
        ),
      ),
    );
  }
}
