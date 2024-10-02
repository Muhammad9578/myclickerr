import 'package:cloud_firestore/cloud_firestore.dart';

class BookingSession {
  late int bookingId;
  String? documentId;
  late int startTime;
  late int endTime;
  double? totalHours;
  late bool onGoing;
  int? otp;
  late int photographerId;
  late int userId;

  BookingSession(
      {required this.bookingId,
      this.documentId,
      required this.startTime,
      required this.endTime,
      required this.onGoing,
      required this.userId,
      required this.photographerId,
      this.otp,
      this.totalHours});

  factory BookingSession.fromJson(DocumentSnapshot json) {
    return BookingSession(
      bookingId: json.get('bookingId'),
      startTime: json.get('startTime'),
      endTime: json.get('endTime'),
      onGoing: json.get('onGoing'),
      userId: json.get('userId'),
      photographerId: json.get('photographerId'),
      documentId: json.id,
      otp: json.get('otp'),
      totalHours: json.get('totalHours'),
    );
  }
}
