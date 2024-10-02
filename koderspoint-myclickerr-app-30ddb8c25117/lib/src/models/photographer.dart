import 'dart:convert';

import 'package:photo_lab/src/models/photographer_equipment.dart';
import 'package:photo_lab/src/models/portfolio_model.dart';
import 'package:photo_lab/src/models/rating.dart';

import '../helpers/utils.dart';

class Photographer {
  int? id;
  String name;
  String? description;
  String imageURL;
  String city;
  String state;
  String country;
  String postalCode;
  String address;
  double latitude;
  double longitude;
  String? email;
  String? equipmentDetails;
  String? paidEquipments;
  int perHourPrice;
  int equipmentCharges;
  String? skills;
  String shortBio;
  int totalBookings;
  double averageRating;
  int totalClient;
  double? distance;
  List<PhotographerEquipment> photographerEquipment;
  List<PortfolioModel> photographerPortfolio;

  List<PhotographerRating> photographerRating;
  String isAvailable;
  List<String> timeslots;

  Photographer({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURL,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.email,
    required this.perHourPrice,
    required this.equipmentDetails,
    required this.paidEquipments,
    required this.equipmentCharges,
    this.distance,
    required this.shortBio,
    required this.skills,
    required this.totalBookings,
    required this.totalClient,
    required this.averageRating,
    required this.photographerRating,
    required this.isAvailable,
    required this.timeslots,
    required this.photographerEquipment,
    required this.photographerPortfolio,
  });

  factory Photographer.fromJson(Map<String, dynamic> json,
      {bool fromSessionClass = false}) {
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

    //************** in case of equipment ***************
    List<PhotographerEquipment> equipmentList = [];
    var equipment = json['equipment'] as List<dynamic>;
    for (var item in equipment) {
      equipmentList.add(PhotographerEquipment.fromJson(item));
    }
    //************** in case of portfolio ***************
    List<PortfolioModel> portfolioList = [];
    var portfolio = json['portfolio'] as List<dynamic>;
    for (var item in portfolio) {
      portfolioList.add(PortfolioModel.fromJson(item));
    }

    //************** in case of rating ***************
    List<PhotographerRating> ratingList = [];
    var rating = json['ratings'] as List<dynamic>;

    // // print("equipment list length: ${rating.length}");
    for (var item in rating) {
      ratingList.add(PhotographerRating.fromJson(item));
    }

    List<String> slots = [];
    // // print("json['timeslots']: ${json['timeslots'].runtimeType}");

    if (fromSessionClass) {
      jsonDecode(json['timeslots']).forEach((element) {
        slots.add(element['time']!);
      });
    } else {
      json['timeslots'].forEach((element) {
        slots.add(element['time']!);
      });
    }

    return Photographer(
      id: json['id'] as int,
      name: json['name'] as String,
      imageURL: photoUrl,
      latitude: checkDouble(json['latitude']),
      longitude: checkDouble(json['longitude']),
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      address: json['home_address'] as String? ?? '',
      description: json['about'] as String?,
      perHourPrice:
          int.parse(json['per_hour_price'].toString().replaceAll('\$', '')),
      skills: json['skills'] ?? 'Skills not provided',
      shortBio: json['short_bio'] ?? 'Bio not provided',
      equipmentCharges: int.parse(json['equipment_charges'].toString() != ''
          ? json['equipment_charges'].toString()
          : '0'),
      equipmentDetails: json['equipment_details'] as String?,
      paidEquipments: json['paid_equipments'] as String?,
      isAvailable: json['is_available'].toString(),
      timeslots: slots,
      distance: double.parse(json['distance'].toString()),
      totalBookings: json['total_bookings'],
      averageRating: double.parse(json['average_rating'].toString()),
      totalClient: json['total_clients'],
      photographerEquipment: equipmentList,
      photographerRating: ratingList,
      photographerPortfolio: portfolioList,
      postalCode: json['postal_code'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'about': description,
      'profile_image': imageURL,
      'city': city,
      'country': country,
      'state': state,
      'postal_code': postalCode,
      'home_address': address,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'per_hour_price': perHourPrice,
      'equipment_charges': equipmentCharges,
      'equipment_details': equipmentDetails,
      'paid_equipments': paidEquipments,
      'skills': skills,
      'short_bio': shortBio,
      'total_bookings': totalBookings,
      'total_clients': totalClient,
      'distance': distance,
      'average_rating': averageRating,
      'is_available': isAvailable,
      'timeslots': jsonEncode(creatingTimeSLotJson(timeslots)),
    };

    return data;
  }

  List<Map<String, String>> creatingTimeSLotJson(slots) {
    List<Map<String, String>> timeSlots = [];
    slots.forEach((element) {
      Map<String, String> slot = {'time': element};
      timeSlots.add(slot);
    });

    // print(" jsonEncode in last: ${jsonEncode(timeSlots)}");
    return timeSlots;
  }
}
