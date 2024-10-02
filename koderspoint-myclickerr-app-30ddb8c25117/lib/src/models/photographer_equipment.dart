class PhotographerEquipment {
  int id;
  String amount;
  String name;
  String amountPer;
  String equipmentImagePath;
  int count;

  PhotographerEquipment({
    required this.id,
    required this.amount,
    required this.name,
    required this.amountPer,
    required this.equipmentImagePath,
    this.count = 0,
  });

  // factory PhotographerEquipment.fromJson(Map<String, dynamic> json) {
  //   return PhotographerEquipment(
  //     id: json['id'],
  //     name: json['equipment_name'],
  //     amount: json['amount'].toString(),
  //     amountPer: json['amount_per'],
  //     equipmentImagePath: json['equipment_photo'],
  //     count: 0,
  //   );}

  factory PhotographerEquipment.fromJson(Map<String, dynamic> json) {
    return PhotographerEquipment(
      id: json['id'],
      name: json['equipment_name'],
      amount: json['amount'].toString(),
      amountPer: json['amount_per'],
      equipmentImagePath: json['equipment_photo'],
      count: 0,
    );
  }
}

class Booking1 {
  int id;
  int userId;

  Booking1({required this.id, required this.userId});

  factory Booking1.fromJson(Map<String, dynamic> json) {
    return Booking1(
      id: json['id'],
      userId: json['user_id'],
    );
  }
}
