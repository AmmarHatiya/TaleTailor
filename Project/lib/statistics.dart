import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int ongoingStories = 0; // Placeholder for ongoing stories
  List<ChartData> chartDataList = [];
  double averageTextLength = 0.0;
  double averageWaitingTime = 0.0;
  double averageWritingTimeLimit = 0.0;

  void countStatistics() {
    String? userUID = FirebaseAuth.instance.currentUser?.uid;

    if (userUID != null) {
      // access firebase database to calculate statistics
      FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: userUID)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
        int totalTextLength = 0;
        double totalWaitingTime = 0;
        double totalWritingTimeLimit = 0;

        snapshot.docs.forEach((doc) {
          totalTextLength += (doc['text'] as String).length;

          try {
            num waitingTime = doc['waitingTime'] as num;
            num writingTimeLimit = doc['writingTimeLimit'] as num;

            totalWaitingTime += waitingTime.toDouble();
            totalWritingTimeLimit += writingTimeLimit.toDouble();
          } catch (e) {
            print('Error: $e');
          }
        });

        setState(() {
          ongoingStories = snapshot.size;

          averageTextLength = totalTextLength / snapshot.size;
          averageWaitingTime = totalWaitingTime / snapshot.size;
          averageWritingTimeLimit = totalWritingTimeLimit / snapshot.size;

          chartDataList = snapshot.docs.map((doc) {
            int textLength = (doc['text'] as String).length;
            String title = doc['title'] ?? '';

            return ChartData(title, textLength.toDouble());
          }).toList();
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    countStatistics(); // Call the function to get story count on initialization
  }

  @override
  Widget build(BuildContext context) {
    var series = [
      charts.Series(
        domainFn: (ChartData data, _) => data.category,
        measureFn: (ChartData data, _) => data.value,
        id: 'Statistics',
        data: chartDataList,
        labelAccessorFn: (ChartData data, _) => '${data.value}',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colors.deepPurpleAccent.shade400),
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
      defaultRenderer: charts.BarRendererConfig(
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelAnchor: charts.BarLabelAnchor.end,
          labelPosition: charts.BarLabelPosition.inside,
          insideLabelStyleSpec: charts.TextStyleSpec(
            color: charts.MaterialPalette.white,
            fontSize: 12,
          ),
        ),
      ),
      domainAxis: charts.OrdinalAxisSpec(),
      behaviors: [
        charts.ChartTitle(
          'Character Count',
          behaviorPosition: charts.BehaviorPosition.top,
          titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent.shade400,
        title: Text('Your Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              height: 40,
              child: Row(
                children: [
                  Text(
                    'Ongoing Stories:',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '$ongoingStories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Averages',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        'Story Length (Characters)',
                        'Waiting Time:',
                        'Writing Time Limit',
                      ].map((String text) {
                        return Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            text,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                    TableRow(
                      children: [
                        averageTextLength.toStringAsFixed(2),
                        averageWaitingTime.toStringAsFixed(2),
                        averageWritingTimeLimit.toStringAsFixed(2),
                      ].map((String value) {
                        return Center(
                          child: Text(
                            value,
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList(),
                    ),
                  ].map((TableRow tableRow) {
                    return TableRow(
                      children: tableRow.children!
                          .map<Widget>((dynamic tableCell) => TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Center(
                                  child: tableCell as Widget,
                                ),
                              ))
                          .toList(),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 40),
            Expanded(
              child: SizedBox(
                height: 300,
                child: chart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}
