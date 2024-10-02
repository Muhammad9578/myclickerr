class PhotographerChart {
  final String x;
  final int y1;

  PhotographerChart({
    required this.x,
    required this.y1,
  });

  factory PhotographerChart.fromJson(Map<String, dynamic> json) {
    return PhotographerChart(
        x: json['month'], y1: double.parse(json['income'].toString()).toInt());
  }
}
