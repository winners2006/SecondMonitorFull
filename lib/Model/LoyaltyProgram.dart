class LoyaltyProgram {
  final String customerName;
  final double bonusBalance;

  LoyaltyProgram({
    required this.customerName,
    required this.bonusBalance,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      customerName: json['customerName'],
      bonusBalance: json['bonusBalance'].toDouble(),
    );
  }
}