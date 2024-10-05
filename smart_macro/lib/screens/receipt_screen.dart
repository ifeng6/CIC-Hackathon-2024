import 'package:flutter/material.dart';
import 'package:smart_macro/models/receipt.dart';

class ReceiptScreen extends StatelessWidget {
  final List<Receipt> receipts = [
    Receipt(
      vendor: 'Pizzeria',
      date: '2/13/2018',
      items: [
        ReceiptItem(name: 'Cheese Pizza', quantity: '1'),
        ReceiptItem(name: 'Tax', quantity: '1'),
      ],
    ),
    Receipt(
      vendor: 'Grocery Store',
      date: '3/15/2018',
      items: [
        ReceiptItem(name: 'Bread', quantity: '1 loaf'),
        ReceiptItem(name: 'Milk', quantity: '1 liter'),
      ],
    ),
    // Add more receipts as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Receipts'),
      ),
      body: ListView.builder(
        itemCount: receipts.length,
        itemBuilder: (context, index) {
          final receipt = receipts[index];
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
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
                itemCount: receipt.items.length,
                itemBuilder: (context, index) {
                  final item = receipt.items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.quantity),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}