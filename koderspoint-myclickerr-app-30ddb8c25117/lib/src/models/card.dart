class CardModel {
  int userId;
  String? bankName;
  String number;
  String name;
  String expiryMonth;
  String expiryYear;
  String cvv;
  bool isDefault;

  CardModel(this.userId, this.number, this.name, this.expiryMonth,
      this.expiryYear, this.cvv, this.bankName,
      [this.isDefault = false]);

  factory CardModel.fromJson(Map<String, dynamic> data) {
    return CardModel(
        data['userId'] ?? 0,
        data['number'],
        data['name'],
        data['expiryMonth'],
        data['expiryYear'],
        data['cvv'],
        data['bankName'] ?? "Bank Name not found",
        data['is_default'] ?? false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'number': number,
      'name': name,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'bankName': bankName ?? "Bank Name not found",
      'is_default': isDefault,
    };

    return data;
  }
}
