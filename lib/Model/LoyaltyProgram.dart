class LoyaltyProgram {
  final String cardNumber;
  final String customerName;
  final double bonusBalance;
  final double bonusForCheck;
  final double discount;

  LoyaltyProgram({
    required this.cardNumber,
    required this.customerName,
    required this.bonusBalance,
    required this.bonusForCheck,
    required this.discount,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      cardNumber: json['cardNumber'],
      customerName: json['customerName'],
      bonusBalance: json['bonusBalance'].toDouble(),
      bonusForCheck: json['bonusForCheck'].toDouble(),
      discount: json['discount'].toDouble(),
    );
  }
}