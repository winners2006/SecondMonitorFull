import 'CheckItem.dart';
import 'LoyaltyProgram.dart';
import 'PaymentQRCode.dart';
import 'Summary.dart';

class Message1C {
  final String messageType;
  final List<CheckItem> items;
  final LoyaltyProgram loyalty;
  final PaymentQRCode payment;
  final Summary summary;

  Message1C({
    required this.messageType,
    required this.items,
    required this.loyalty,
    required this.payment,
    required this.summary,
  });

  factory Message1C.fromJson(Map<String, dynamic> json) {
    return Message1C(
      messageType: json['messageType'],
      items: (json['items'] as List)
          .map((item) => CheckItem.fromJson(item))
          .toList(),
      loyalty: LoyaltyProgram.fromJson(json['loyalty']),
      payment: PaymentQRCode.fromJson(json['payment']),
      summary: Summary.fromJson(json['summary']),
    );
  }
} 