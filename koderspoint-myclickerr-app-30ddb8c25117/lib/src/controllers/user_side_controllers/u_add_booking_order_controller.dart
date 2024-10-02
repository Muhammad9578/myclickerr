import 'package:flutter/cupertino.dart';
import 'package:photo_lab/src/modules/chat/models/custom_order.dart';
import 'package:photo_lab/src/models/order.dart';

import '../../models/photographer_equipment.dart';

class UserAddBookingOrderController extends ChangeNotifier {
  List<Map<String, dynamic>> availableCoupons = [
    {'MYC8T9Z2': '5'},
    {'MYC9P2Q8': '10'},
    {'MYC2F8H1': '15'},
    {'MYC1J9U6': '20'},
    {'MYC9R4S6': '25'},
    {'MYC6B2N4': '30'},
    {'MYC9X2Y6': '35'},
    {'MYC6J8K4': '40'},
  ];

  CustomOrder? customOrder;

  late Order? newOrder;
  List<PhotographerEquipment> allPhotographerEquipments = [];
  double selectedEquipmentPrice = 0;
  int selectedEquipmentCount = 0;
  double totalAmount = 0;
  double subTotal = 0;
  double taxPercentage = 18; // 18 percent tax
  double taxAmount = 18; // 18 percent tax

  double couponCodeDiscount = 0;
  double couponCodeAmount = 0;

  List<Map<String, String>> finalSelectedEquipments = [];

  calculateSelectedEquipmentPrice() {
    selectedEquipmentPrice = 0;
    selectedEquipmentCount = 0;
    finalSelectedEquipments.clear();
    allPhotographerEquipments.forEach((element) {
      selectedEquipmentPrice += element.count * double.parse(element.amount);

      if (element.count != 0) {
        finalSelectedEquipments.add({
          'equipment_id': element.id.toString(),
          'count': element.count.toString()
        });
        selectedEquipmentCount++;
      }
    });
    calculateTotal();
  }

  changeSelectedEuipmentCount(id, count) {
    allPhotographerEquipments.forEach((element) {
      if (element.id == id) {
        element.count = count;
      }
    });
    calculateSelectedEquipmentPrice();
  }

  setSelectedEquipments(List<PhotographerEquipment> eqipmentLst) {
    allPhotographerEquipments.clear();
    allPhotographerEquipments = List.from(eqipmentLst);
    notifyListeners();
  }

  calculateTotal() {
    subTotal = 0;
    totalAmount = 0;

    subTotal += customOrder == null
        ? newOrder!.bidAmount! * double.parse(newOrder!.duration)
        : customOrder!.orderTotalPrice * double.parse(newOrder!.duration);

    // print("subTotal 1: $subTotal");
    subTotal += selectedEquipmentPrice;
    // print("subTotal 2: $subTotal");
    taxAmount = (taxPercentage * subTotal) / 100;
    totalAmount = subTotal + (taxPercentage * subTotal) / 100;
    // print("totalAmount 1: $totalAmount");
    couponCodeAmount = (couponCodeDiscount * totalAmount) / 100;
    totalAmount = totalAmount - (couponCodeDiscount * totalAmount) / 100;
    // print("totalAmount 2: $totalAmount , couponCodeAmount: $couponCodeAmount");

    notifyListeners();
  }

  setCouponCodeDiscount(am) {
    couponCodeDiscount = am;
    calculateTotal();
  }

  verifyCoupon(code) {
    // // print("code: $code");
    couponCodeDiscount = 0;
    availableCoupons.forEach((element) {
      if (element.containsKey(code)) {
        couponCodeDiscount = double.parse(element[code]);
        // // print("discount: $couponCodeDiscount");
      }
      // // print("discount: $couponCodeDiscount");
      calculateTotal();
    });
  }

  setNewOrder(ord) {
    newOrder = ord;
    notifyListeners();
  }

  clearPreviousData() {
    selectedEquipmentPrice = 0;
    selectedEquipmentCount = 0;
    totalAmount = 0;
    subTotal = 0;
    taxPercentage = 18; // 18 percent tax
    couponCodeDiscount = 0;

    allPhotographerEquipments.clear();
    finalSelectedEquipments.clear();
    notifyListeners();
  }

  setCustomOrder(ord) {
    customOrder = ord;
    notifyListeners();
  }
}
