class PaymentQRCode {
  final String qrData;

  PaymentQRCode({
    required this.qrData,
  });

  factory PaymentQRCode.fromJson(Map<String, dynamic> json) {
    return PaymentQRCode(
      qrData: json['qrData'],
    );
  }
}