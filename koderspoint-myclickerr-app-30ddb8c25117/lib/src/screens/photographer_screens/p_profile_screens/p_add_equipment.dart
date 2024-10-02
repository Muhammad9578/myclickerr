import 'package:flutter/material.dart';
import 'package:photo_lab/src/controllers/photographer_side_controllers/photographer_controller.dart';
import 'package:photo_lab/src/helpers/functions.dart';
import 'package:photo_lab/src/helpers/helpers.dart';
import 'package:photo_lab/src/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../helpers/utils.dart';
import '../../../models/photographer_equipment.dart';
import '../../../models/user.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_drop_down.dart';
import '../../../widgets/primary_text_field.dart';

class PhotographerAddEquipmentsScreen extends StatefulWidget {
  static const route = "photographerAddEquipmentsScreen";
  PhotographerEquipment? equipment;

  PhotographerAddEquipmentsScreen({Key? key, this.equipment}) : super(key: key);

  @override
  State<PhotographerAddEquipmentsScreen> createState() =>
      _PhotographerAddEquipmentsScreenState();
}

class _PhotographerAddEquipmentsScreenState
    extends State<PhotographerAddEquipmentsScreen> {
  String amount = '';
  String name = '';
  String amountPer = 'Day';
  Image? equipmentImage;
  final _formKey = GlobalKey<FormState>();

  late User loggedInUser;

  dropdownSelectedValue(val) {
    setState(() {
      amountPer = val;
    });
  }

  @override
  void initState() {
    super.initState();
    AppFunctions.imagepath = '';
    if (widget.equipment != null) {
      debugLog("not null");
      name = widget.equipment!.name;
      amount = widget.equipment!.amount;
      equipmentImage = Image.network(
        width: 120,
        height: 120,
        widget.equipment!.equipmentImagePath,
        fit: BoxFit.cover,
      );
    }
    SessionHelper.getUser().then((loggedInUser) {
      if (loggedInUser != null) {
        setState(() {
          this.loggedInUser = loggedInUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add new equipments",
        action: [],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      25.SpaceY,
                      Text(
                        "Equipment Photo",
                        style: MyTextStyle.medium07Black.copyWith(fontSize: 14),
                      ),
                      8.SpaceY,
                      InkWell(
                        onTap: () async {
                          equipmentImage =
                              await AppFunctions.choosePhoto(context);
                          setState(() {});
                        },
                        child: Container(
                          padding:
                              EdgeInsets.all(equipmentImage == null ? 30 : 0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(kInputBorderRadius),
                              border: Border.all(
                                color: AppColors.black.withOpacity(0.4),
                              )),
                          child: equipmentImage == null
                              ? Icon(
                                  Icons.camera_alt_outlined,
                                  size: 30,
                                  color: AppColors.black.withOpacity(0.4),
                                )
                              : equipmentImage,
                        ),
                      ),
                      15.SpaceY,
                      PrimaryTextField(
                        'Name',
                        initialValue: name,
                        labelText: "Equipment name",
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Equipment name';
                          }
                          return null;
                        },
                        onChange: (value) {
                          name = value.trim();
                        },
                      ),
                      5.SpaceY,
                      PrimaryTextField(
                        'Enter amount',
                        initialValue: amount,
                        labelText: "Amount",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter amount';
                          }
                          if (!value.trim().isValidNumbers()) {
                            return 'Only numbers are allowed';
                          }
                          return null;
                        },
                        onChange: (value) {
                          amount = value.trim().toString();
                        },
                      ),
                      15.SpaceY,
                      //todo change this dropdown class to flutter builtin dropdown
                      CustomDropdown(
                          items: ['Day', 'Week'],
                          hint: 'Amount Per day',
                          selectedValue: amountPer,
                          onSubmit: dropdownSelectedValue),
                      80.SpaceY,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Consumer<PhotorapherController>(
                    builder: (context, photoraphercontroller, _) {
                  return photoraphercontroller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange),
                        )
                      : GradientButton(
                          onPress: () {
                            // if (equipmentImagePath.isEmpty) {
                            //   Toasty.error('Choose profile photo');
                            // } else
                            closeKeyboard(context);
                            if (_formKey.currentState!.validate()) {
                              photoraphercontroller.addNewEquipment(
                                  context,
                                  widget.equipment,
                                  loggedInUser.id,
                                  name,
                                  amountPer,
                                  amount);
                            }
                          },
                          text: widget.equipment != null ? 'Update' : 'Add',
                        );
                })),
          ],
        ),
      ),
    );
  }
}
