class PhotographerBooking {
  /*"id": 1,
  "user_id": "2",
  "photographer_id": "5",
  "card_id": "1",
  "event_details": "The massive technology conference Techweek references past attendees and sponsors to illustrate how popular and illustrious the event is. If you do not have big names to reference you can include testimonials and reviews from past attendees to create the same effect. ",
  "event_date": "15 Nov 2022",
  "event_time": "10:00 AM",
  "location": "USA, New York",
  "total_time": "30hrs-40hrs / week",
  "paid_equipments": "1",
  "total_amount": "350.00",
  "total_amount_currency": "$",
  "status": "pending",
  "transaction_id": "",
  "receipt_url": "",
  "user_name": "Kamran Abrar",
  "profile_image": "http://shanzycollection.com/photolab/public/profile_images/default.png"*/
  int id;
  int userId;
  int photographerId;
  String eventDetails;
  String eventDate;
  String eventTime;
  String location;
  String totalTime;
  bool paidEquipments;
  double totalAmount;
  String totalAmountCurrency;
  String transactionId;
  String profileImage;
  String username;
  String status;
  String fileLink;

  PhotographerBooking({
    required this.id,
    required this.userId,
    required this.photographerId,
    required this.eventDetails,
    required this.eventDate,
    required this.eventTime,
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
  });

  factory PhotographerBooking.fromJson(Map<String, dynamic> json) {
    return PhotographerBooking(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        photographerId: json['photographer_id'] as int,
        eventDetails: json['event_details'] as String,
        eventDate: json['event_date'] as String,
        eventTime: json['event_time'] as String,
        location: json['location'] as String,
        totalTime: json['total_time'] as String,
        paidEquipments:
            int.parse(json['paid_equipments'] as String) == 1 ? true : false,
        totalAmount: double.parse(json['total_amount'] as String),
        totalAmountCurrency: json['total_amount_currency'] as String,
        transactionId: json['transaction_id'] as String,
        profileImage: json['profile_image'] as String? ?? '',
        username: json['user_name'] as String? ?? '',
        fileLink: json['file_link'] as String? ?? '',
        status: json['status'] as String);
  }

/*Booking(this.userName, this.eventDetails, this.eventDate, this.location,
      this.totalAmount, this.profileImage, this.isComplete);*/

}
