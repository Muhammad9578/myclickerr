class NotificationModel {

  int id;
  String text;
  int time;
  String type;
  int bookingId;
  int notificationFrom;
  int notificationTo;


  NotificationModel({
    required this.id,
    required this.text,
    required this.time,
    required this.type,
    required this.bookingId,
    required this.notificationFrom,
    required this.notificationTo
  });

  factory NotificationModel.fromJson(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'],
      bookingId: data['booking_id'],
      text: data['notification'],
      time: data['notification_time'],
      type: data['notification_type'],
      notificationFrom:data['notification_from'],
      notificationTo: data['notification_to'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'booking_id': bookingId,
      'notification': text,
      'notification_time': time,
      'notification_type': type,
      'notification_from':notificationFrom,
      'notification_to':notificationTo,
    };

    return data;
  }
}
