import 'package:flutter/material.dart';
import 'package:smart_macro/models/pantry_item.dart';

class PantryScreen extends StatefulWidget {
  final List<PantryItem> pantryItems;

  const PantryScreen({Key? key, required this.pantryItems}) : super(key: key);

  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  late List<PantryItem> sortedItems;
  String? selectedSortOption = 'Name';

  @override
  void initState() {
    super.initState();
    sortedItems = List.from(widget.pantryItems);
    _sortItems();
  }

  void _sortItems() {
    if (selectedSortOption == 'Name') {
      sortedItems.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSortOption == 'Days Left') {
      sortedItems.sort((a, b) => a.daysLeftToExpire.compareTo(b.daysLeftToExpire));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantry Items'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Colors.green[100],
        actions: [
          DropdownButton<String>(
            value: selectedSortOption,
            icon: Icon(Icons.sort),
            onChanged: (String? newValue) {
              setState(() {
                selectedSortOption = newValue;
                _sortItems();
              });
            },
            items: <String>['Name', 'Days Left']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedItems.length,
        itemBuilder: (context, index) {
          final item = sortedItems[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add some space around each item
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey), // Border color
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text('${item.daysLeftToExpire} days left'),
              // Change the text color to red if only 1 day left
              textColor: (item.daysLeftToExpire == 1 || item.daysLeftToExpire == 2) ? Colors.red : null,
            ),
          );
        },
      ),
    );
  }
}
