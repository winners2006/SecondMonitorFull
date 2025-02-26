class CheckItem {
  final String name;
  final double quantity;
  final double price;
  final double amount;

  CheckItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.amount,
  });

  factory CheckItem.fromJson(Map<String, dynamic> json) {
    return CheckItem(
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}