import 'package:photo_lab/src/helpers/utils.dart';

class Booking {
  int id;
  int userId;
  int photographerId;
  String eventDetails;
  String eventDate;
  String eventTime;
  String eventCategory;
  String location;
  String totalTime;
  bool paidEquipments;
  String totalAmount;
  String totalAmountCurrency;
  String transactionId;
  String profileImage;
  String username;
  String status;
  String fileLink;
  String eventTitle;
  String endDate;
  String endTime;
  String latitude;
  String longitude;
  String addressLane1;
  String addressLane2;
  String city;
  String state;
  String pinCode;
  String country;
  double photographerAmount;
  String recieptUrl;
  int eventCategoryId;
  String taxAmount, totalEquipmentAmount, couponCodeDiscount, bidAmount;
  List<Map<String, dynamic>> selectedEquipments;
  int? bookedTime,
      rescheduledTime,
      acceptedTime,
      rejectedTime,
      cancelledTime,
      completedTime;

  String? rejectedBy;
  double? rating;
  String? ratingDescription;
  Booking(
      {required this.id,
      required this.userId,
      required this.photographerId,
      required this.eventDetails,
      required this.eventDate,
      required this.eventTime,
      required this.eventCategory,
      required this.location,
      required this.totalTime,
      required this.paidEquipments,
      required this.totalAmount,
      required this.totalAmountCurrency,
      required this.transactionId,
      required this.profileImage,
      required this.username,
      required this.status,
      required this.fileLink,
      required this.state,
      required this.addressLane2,
      required this.addressLane1,
      required this.country,
      required this.city,
      required this.latitude,
      required this.endTime,
      required this.endDate,
      required this.longitude,
      required this.eventCategoryId,
      required this.eventTitle,
      required this.photographerAmount,
      required this.recieptUrl,
      required this.pinCode,
      required this.totalEquipmentAmount,
      required this.taxAmount,
      required this.couponCodeDiscount,
      required this.bidAmount,
      this.rating,
      this.ratingDescription,
      this.rejectedBy,
      required this.selectedEquipments,
      required this.bookedTime,
      required this.rescheduledTime,
      required this.acceptedTime,
      required this.rejectedTime,
      required this.cancelledTime,
      required this.completedTime});

  factory Booking.fromJson(Map<String, dynamic> json) {
    // debugLog("Booking.fromJson: $json");
    String photoUrl = '';
    if (json['profile_image'].toString().contains('shanzycollection')) {
      photoUrl = json['profile_image'].toString().replaceFirst(
          'http://shanzycollection.com/photolab/public/',
          'https://myclickerr.info/public/api');
    } else if (json['profile_image'].toString().contains('tap4trip')) {
      photoUrl = json['profile_image'].toString().replaceFirst(
          'https://tap4trip.com/photolab/public/',
          'https://myclickerr.info/public/api');
    } else if (json['profile_image']
        .toString()
        .contains('app.myclickerr.com')) {
      photoUrl = json['profile_image']
          .toString()
          .replaceFirst('https://app.myclickerr.com/',
              'http://myclickerr.info/public/api')
          .replaceFirst('http://app.myclickerr.com/',
              'http://myclickerr.info/public/api');
    } else {
      photoUrl = json['profile_image'].toString();
    }

    List<Map<String, dynamic>> eqpList = [];
    // // print(
    //     "json['selected_equipments']: ${json['selected_equipments']} , type: ${json['selected_equipments'].runtimeType}");

    if (json['selected_equipments'] != null &&
        json['selected_equipments'] != '') {
      json['selected_equipments'].forEach((elem) {
        eqpList.add(elem);
      });
    }
    // // print("eqpList: $eqpList");
    return Booking(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        photographerId: json['photographer_id'] as int,
        eventDetails: json['event_details'] as String,
        eventDate: json['event_date'] as String,
        eventTime: json['event_time'] as String,
        eventCategory: json['event_category_name'] as String,
        location: json['location'] ?? "",
        totalTime: json['total_time'].toString(),
        paidEquipments: json['paid_equipments'] as int == 1 ? true : false,
        totalAmount: json['total_amount'].toString(),
        totalAmountCurrency: json['total_amount_currency'] as String,
        transactionId: json['transaction_id'] as String,
        profileImage: photoUrl,
        // json['profile_image'] as String? ?? '',
        username: json['user_name'] as String? ?? '',
        status: json['status'] as String,
        fileLink: json['file_link'] as String? ?? '',
        // *****************
        eventTitle: json['event_title'] == ""
            ? "Booking Title"
            : json['event_title'].toString(),
        endDate: json['event_end_date'].toString(),
        endTime: json['event_end_time'].toString(),
        latitude: json['latitude'].toString(),
        longitude: json['longitude'].toString(),
        addressLane1: json['address_line1'].toString(),
        addressLane2: json['address_line2'].toString(),
        city: json['city'],
        state: json['state'],
        country: json['country'],
        pinCode: json['pin_code'].toString(),
        photographerAmount: double.parse(
            json['photographer_amount'].toString().isEmpty
                ? '0'
                : json['photographer_amount'].toString()),
        recieptUrl: json['receipt_url'],
        eventCategoryId: json['event_category_id'] ?? 0,
        totalEquipmentAmount: json['total_equipment_amount'].toString(),
        bidAmount: json['bid_amount'].toString(),
        couponCodeDiscount: json['coupon_code_discount'].toString(),
        selectedEquipments: eqpList,
        rating: json['rating'] == null
            ? null
            : double.parse(json['rating'].toString()),
        ratingDescription: json['rating_description'],
        rejectedBy: json['rejected_by'].toString(),

        // jsonDecode(json['selected_equipments']) ?? [],

        taxAmount: json['tax_amount'].toString(),
        bookedTime: json['booked'],
        rescheduledTime: json['rescheduled'],
        acceptedTime: json['accepted'],
        rejectedTime: json['rejected'],
        cancelledTime: json['cancelled'],
        completedTime: json['completed']);
  }

/*Booking(this.userName, this.eventDetails, this.eventDate, this.location,
      this.totalAmount, this.profileImage, this.isComplete);*/
}
