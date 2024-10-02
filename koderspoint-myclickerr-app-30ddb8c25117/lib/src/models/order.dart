class Order {
  final int userId;
  final int photographerId;
  final int eventCategoryId;
  final String details;
  final String? title;
  final String? type;

  final String date;
  final String time;
  String? endDate;
  String? endTime;
   String? location;
  final String duration;
  final bool paidEquipment;
  double totalAmount;

  double latitude;
  double longitude;
  String? addressLane1;
  String? addressLane2;
  String? city;
  String? state;
  String? country;
  String? pinCode;

  double? bidAmount;
  double? couponCodeDiscount;
  double? totalEquipmentAmount;
  double? taxAmount;
  List<Map<String, String>>? selectedEquipment;

  Order(
      {required this.userId,
      required this.photographerId,
      required this.eventCategoryId,
      required this.details,
      required this.date,
      required this.time,
      required this.latitude,
      required this.longitude,
      required this.location,
      required this.duration,
      required this.paidEquipment,
      required this.totalAmount,
      this.endDate,
      this.endTime,
      this.title,
      this.type,
      this.addressLane1,
      this.addressLane2,
      this.city,
      this.state,
      this.country,
      this.pinCode,
      this.taxAmount = 0,
      this.couponCodeDiscount = 0,
      this.bidAmount = 0,
      this.selectedEquipment,
      this.totalEquipmentAmount = 0});
}
