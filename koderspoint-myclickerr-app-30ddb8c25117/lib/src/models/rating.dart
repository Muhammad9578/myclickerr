import 'package:intl/intl.dart';

class PhotographerRating {
  int id;
  int userId;
  int photographerId;
  double rating;
  String description;
  String userName;
  String imgPath;
  String dateTime;

  PhotographerRating(
      {required this.imgPath,
      required this.id,
      required this.photographerId,
      required this.userId,
      required this.dateTime,
      required this.description,
      required this.userName,
      required this.rating});

  factory PhotographerRating.fromJson(Map<String, dynamic> json) {
    String dateStr = json['created_at'];
    DateTime dateTime = DateTime.parse(dateStr);

    String formattedDate =
        DateFormat('d MMM, y - h:mm a').format(dateTime.toLocal());

    return PhotographerRating(
      imgPath: json['profile_image'],
      userId: json['user_id'],
      description: json['description'],
      id: json['id'],
      photographerId: json['photographer_id'],
      rating: double.parse(json['rating'].toString()),
      userName: json['user_name'],
      dateTime: formattedDate.toString(),
    );
  }
}
