class BankAccount {
  String accountNumber;
  String accountHolderName;
  String country;
  String bankName;
  String panNumber;


  BankAccount({
    required this.accountNumber,
    required this.accountHolderName,
    required this.country,
    required this.bankName,
    required this.panNumber,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountNumber: json['account_number'],
      accountHolderName: json['account_holder_name'],
      country: json['bank_country'],
      bankName: json['bank_name'],
      panNumber: json['pan_number'],
    );
  }
}
