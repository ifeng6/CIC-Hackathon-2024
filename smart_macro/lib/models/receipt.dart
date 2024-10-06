import 'package:smart_macro/models/macro.dart';
import 'package:smart_macro/models/pantry_item.dart';

class Receipt {
  final double cost;
  final Macro macros;
  final List<PantryItem> items;


  Receipt({required this.cost, required this.macros, required this.items});
}