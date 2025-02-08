class Summary {
  final double subtotal;
  final double discount;
  final double total;

  Summary({
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      subtotal: json['subtotal'].toDouble(),
      discount: json['discount'].toDouble(),
      total: json['total'].toDouble(),
    );
  }
}