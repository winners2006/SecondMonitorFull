import 'package:flutter/material.dart';
import 'package:second_monitor/Service/LicenseManager.dart';
import 'package:second_monitor/View/LicenseWindow.dart';

abstract class LicenseCheckWidget extends StatefulWidget {
  const LicenseCheckWidget({super.key});
}

abstract class LicenseCheckState<T extends LicenseCheckWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    _checkLicense();
  }

  Future<void> _checkLicense() async {
    final hasValidLicense = await LicenseManager.checkLicense();
    if (!hasValidLicense && mounted) {
      await LicenseManager.revokeLicense();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LicenseWindow()),
        (route) => false, // Удаляем все предыдущие окна из стека
      );
    }
  }
} 