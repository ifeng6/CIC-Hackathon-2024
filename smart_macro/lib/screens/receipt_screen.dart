import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_macro/models/item_type.dart';
import 'package:smart_macro/models/receipt.dart';

class ReceiptScreen extends StatefulWidget {
  final List<Receipt> receipts;

  const ReceiptScreen({Key? key, required this.receipts}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Receipts'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.green[100],
      ),
      body: ListView.builder(
        itemCount: widget.receipts.length,
        itemBuilder: (context, index) {
          final receipt = widget.receipts[index];
          return GestureDetector(
            onTap: () {
              _showReceiptDetails(context, receipt);
            },
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ListTile(
                title: Text(receipt.vendor),
                subtitle: Text(receipt.date),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReceiptDetails(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Allow the modal to take up more height
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // Set desired height
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Receipt Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Vendor: ${receipt.vendor}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Date: ${receipt.date}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Prevent scrolling conflict
                  itemCount: receipt.items.length,
                  itemBuilder: (context, index) {
                    final item = receipt.items[index];
                    String quantityWithUnit;

                    // Add the appropriate prefix based on the item type
                    switch (item.type) {
                      case ItemType.countable:
                        quantityWithUnit = '${item.quantity} pcs'; // Countable items
                        break;
                      case ItemType.liquid:
                        quantityWithUnit = '${item.quantity} ml'; // Liquid items
                        break;
                      case ItemType.weight:
                        quantityWithUnit = '${item.quantity} kg'; // Weight items
                        break;
                      default:
                        quantityWithUnit = item.quantity.toString(); // Fallback
                    }

                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(quantityWithUnit),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Pie Chart of Macronutrients
                Text(
                  'Macronutrient Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: receipt.macros.protein.toDouble(),
                          color: Colors.blue,
                          title: '${receipt.macros.protein}g',
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: receipt.macros.carbohydrates.toDouble(),
                          color: Colors.green,
                          title: '${receipt.macros.carbohydrates}g',
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: receipt.macros.fats.toDouble(),
                          color: Colors.orange,
                          title: '${receipt.macros.fats}g',
                          radius: 60,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Color Legend
                _buildColorLegend(),
              ],
            ),
          ),
        );
      },
    );
  }


  // Helper method to build the color legend for the pie chart
  Widget _buildColorLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildLegendColorCircle(Colors.blue),
            SizedBox(width: 8),
            Text('Protein'),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildLegendColorCircle(Colors.green),
            SizedBox(width: 8),
            Text('Carbohydrates'),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildLegendColorCircle(Colors.orange),
            SizedBox(width: 8),
            Text('Fats'),
          ],
        ),
      ],
    );
  }

  // Helper method to create a circular color legend item
  Widget _buildLegendColorCircle(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle, // Makes the container circular
      ),
    );
  }

}
