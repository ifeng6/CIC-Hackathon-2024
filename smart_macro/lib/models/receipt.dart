import 'package:smart_macro/models/macro.dart';
import 'package:smart_macro/models/pantry_item.dart';

class Receipt {
  final String vendor;
  final String date;
  final Macro macros;
  final List<PantryItem> items;


  Receipt({required this.vendor, required this.date, required this.macros, required this.items});
}