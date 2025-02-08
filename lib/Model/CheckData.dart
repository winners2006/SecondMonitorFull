import 'CheckItem.dart';
import 'LoyaltyProgram.dart';
import 'PaymentQRCode.dart';
import 'Summary.dart';

class CheckData {
  final String checkNumber;
  final String timestamp;
  final List<CheckItem> items;
  final LoyaltyProgram loyalty;
  final PaymentQRCode payment;
  final Summary summary;

  CheckData({
    required this.checkNumber,
    required this.timestamp,
    required this.items,
    required this.loyalty,
    required this.payment,
    required this.summary,
  });

  factory CheckData.fromJson(Map<String, dynamic> json) {
    return CheckData(
      checkNumber: json['checkNumber'],
      timestamp: json['timestamp'],
      items: (json['items'] as List)
          .map((item) => CheckItem.fromJson(item))
          .toList(),
      loyalty: LoyaltyProgram.fromJson(json['loyalty']),
      payment: PaymentQRCode.fromJson(json['payment']),
      summary: Summary.fromJson(json['summary']),
    );
  }
} 