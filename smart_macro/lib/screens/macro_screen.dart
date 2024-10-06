import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_macro/models/macro.dart';
import 'package:smart_macro/models/pantry_item.dart';


class MacroScreen extends StatelessWidget {
  final List<PantryItem> pantryItems;
  final Macro macro;

  MacroScreen({required this.pantryItems, required this.macro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Macros and Pantry Items'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: pantryItems.length,
                itemBuilder: (context, index) {
                  final item = pantryItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.quantity}, Expires in ${item.daysLeftToExpire} days',
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Macros Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: macro.protein,
                      color: Colors.blue,
                      title: '${macro.protein.toStringAsFixed(1)}g Protein',
                      titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: macro.carbohydrates,
                      color: Colors.green,
                      title: '${macro.carbohydrates.toStringAsFixed(1)}g Carbs',
                      titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: macro.fats,
                      color: Colors.orange,
                      title: '${macro.fats.toStringAsFixed(1)}g Fats',
                      titleStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      radius: 50,
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
