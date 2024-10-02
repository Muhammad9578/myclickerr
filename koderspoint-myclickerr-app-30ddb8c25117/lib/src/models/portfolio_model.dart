import 'dart:io';

class PortfolioModel {
  late int photographerId;
  late String title;
  late int date;
  List<String> images;
  int? portfolioId;

  PortfolioModel({
    required this.photographerId,
    required this.title,
    required this.date,
    required this.images,
    this.portfolioId,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    // print("json['portfolio_date'] type: ${json['portfolio_date'].runtimeType}");
    // int datee;
    // if(json['portfolio_date'].){
    //   datee = json['portfolio_date'];
    // }else{
    //   datee = int.parse(json['portfolio_date']);
    // }
    return PortfolioModel(
        photographerId: json['photographer_id'],
        title: json['title'],
        date: int.parse(json['portfolio_date'].toString()),
        images: new List<String>.from(json['media']),
        portfolioId: json['id']);
  }
}
