class Receipt {
  final String vendor;
  final String date;
  final List<ReceiptItem> items;

  Receipt({required this.vendor, required this.date, required this.items});
}

class ReceiptItem {
  final String name;
  final String quantity;

  ReceiptItem({required this.name, required this.quantity});
}