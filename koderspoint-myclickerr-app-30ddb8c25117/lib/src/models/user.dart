import 'dart:convert';

class User {
  int id;
  String name;
  String email;
  String profileImage;
  String countryCode;
  String phoneCode;
  String phone;
  String city;
  String password;
  String state;
  String country;
  String address;
  String postalCode;
  String latitude;
  String longitude;
  String? skills;
  String? equipmentDetails;
  String? paidEquipments;
  String perHourPrice;
  String equipmentCharges;
  String? shortBio;
  int isVerified;
  bool hasPortfolio;
  String isAvailable;
  List<String> timeslots;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.countryCode,
    required this.phoneCode,
    required this.phone,
    required this.skills,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.perHourPrice,
    required this.equipmentDetails,
    required this.paidEquipments,
    required this.equipmentCharges,
    required this.password,
    required this.shortBio,
    required this.isAvailable,
    required this.timeslots,
    required this.hasPortfolio,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json,
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

    List<String> slots = [];
    if (fromSessionClass) {
      jsonDecode(json['timeslots']).forEach((element) {
        slots.add(element['time']!);
      });
    } else {
      json['timeslots'].forEach((element) {
        slots.add(element['time']!);
      });
    }

    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      // profileImage: photoUrl,
      profileImage: photoUrl,
      // json['profile_image'] as String,
      countryCode: json['phone_code'] as String,
      phoneCode: json['country_code'] as String,
      phone: json['phone'] as String,
      skills: json['skills'] ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      address: json['home_address'] as String? ?? '',
      latitude: json['latitude'] as String? ?? '0',
      longitude: json['longitude'] as String? ?? '0',
      perHourPrice: json['per_hour_price'],
      equipmentCharges: json['equipment_charges'] as String,
      equipmentDetails: json['equipment_details'] as String?,
      paidEquipments: json['paid_equipments'] as String?,
      password: json['password'].toString(),
      shortBio: json['short_bio'] ?? '',
      isAvailable: json['is_available'].toString(),
      timeslots: slots,
      isVerified: json['is_verified'],
      hasPortfolio: json['has_portfolio'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'country_code': phoneCode,
      'phone_code': countryCode,
      'phone': phone,
      'city': city,
      'country': country,
      'state': state,
      'postal_code': postalCode,
      'home_address': address,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'skills': skills,
      'per_hour_price': perHourPrice,
      'equipment_charges': equipmentCharges,
      'equipment_details': equipmentDetails,
      'paid_equipments': paidEquipments,
      'short_bio': shortBio,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'has_portfolio': hasPortfolio,
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
