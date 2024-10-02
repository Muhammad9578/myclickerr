import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_lab/src/models/photographer_performance_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyBarGraph extends StatelessWidget {
  const MyBarGraph({Key? key, required this.chartData}) : super(key: key);
  final List<PhotographerChart> chartData;

  @override
  Widget build(BuildContext context) {
       return Container(
        height: 250,
        child: SfCartesianChart(
          enableSideBySideSeriesPlacement: false,
          borderWidth: 0,
          borderColor: Colors.transparent,
          enableAxisAnimation: true,
          primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.compact(),
          ),
          primaryXAxis: CategoryAxis(),
          series: [
            StackedColumnSeries(
                borderWidth: 0,
                borderColor: Colors.orange,
                isTrackVisible: true,
                trackColor: Color(0xffF2F2F2),
                isVisible: true,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(13),
                    topLeft: Radius.circular(13)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff002F9D), Color(0xff3B69D3)]),
                color: Colors.pink,
                dataSource: chartData,
                xValueMapper: (PhotographerChart ch, _) => ch.x,
                yValueMapper: (PhotographerChart ch, _) => ch.y1),
          ],
        ));
  }
}
