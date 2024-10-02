class PhotographerBookingHistory {

  int id;
  String userId;
  String photographerId;
  String eventDetails;
  String eventDate;
  String eventTime;
  String location;
  String totalTime;
  bool paidEquipments;
  double totalAmount;
  String totalAmountCurrency;
  String transactionId;
  String receiptUrl;
  String profileImage;
  String username;
  String status;

  PhotographerBookingHistory({
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
    required this.receiptUrl,
    required this.profileImage,
    required this.username,
    required this.status,
  });

  factory PhotographerBookingHistory.fromJson(Map<String, dynamic> json) {
    return PhotographerBookingHistory(
        id: json['id'] as int,
        userId: '${(json['user_id'] as int)}',
        photographerId: '${(json['photographer_id'] as int)}',
        //cardId: json['card_id'] as String,
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
        receiptUrl: json['receipt_url'] as String,
        profileImage: json['profile_image'] as String? ?? '',
        username: json['user_name'] as String? ?? '',
        status: json['status'] as String);
  }

/*Booking(this.userName, this.eventDetails, this.eventDate, this.location,
      this.totalAmount, this.profileImage, this.isComplete);*/

}
