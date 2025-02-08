class CheckItem {
  final String name;
  final double quantity;
  final double price;

  CheckItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CheckItem.fromJson(Map<String, dynamic> json) {
    return CheckItem(
      name: json['name'],
      quantity: json['quantity'].toDouble(),
      price: json['price'].toDouble(),
    );
  }
}