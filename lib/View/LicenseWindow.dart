import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Service/LicenseManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseWindow extends StatefulWidget {
  const LicenseWindow({super.key});

  @override
  _LicenseWindowState createState() => _LicenseWindowState();
}

class _LicenseWindowState extends State<LicenseWindow> {
  final _licenseController = TextEditingController();
  bool _isActivating = false;
  Map<String, dynamic>? _licenseInfo;

  @override
  void initState() {
    super.initState();
    _licenseController.addListener(_onLicenseChanged);
    _loadLicenseInfo();
  }

  Future<void> _loadLicenseInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = prefs.getString(LicenseManager.licenseExpiry);
    final licenseKey = prefs.getString(LicenseManager.licenseKey);
    
    if (expiryDate != null && licenseKey != null) {
      setState(() {
        _licenseInfo = {
          'key': licenseKey,
          'expires_at': expiryDate,
          'type': DateTime.parse(expiryDate).year > 2099 ? 'perpetual' : 'annual',
        };
      });
    }
  }

  @override
  void dispose() {
    _licenseController.removeListener(_onLicenseChanged);
    _licenseController.dispose();
    super.dispose();
  }

  void _onLicenseChanged() {
    final text = _licenseController.text.toUpperCase().replaceAll('-', '');
    final formattedText = <String>[];
    
    for (var i = 0; i < text.length; i += 4) {
      if (i + 4 <= text.length) {
        formattedText.add(text.substring(i, i + 4));
      } else {
        formattedText.add(text.substring(i));
      }
    }
    
    final newText = formattedText.join('-');
    if (newText != _licenseController.text) {
      _licenseController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление лицензией'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_licenseInfo != null) ...[
              // Информация о текущей лицензии
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Информация о лицензии',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Ключ: ${_licenseInfo!['key']}'),
                      Text(
                        'Тип: ${_licenseInfo!['type'] == 'perpetual' ? 'Бессрочная' : 'Годовая'}',
                      ),
                      Text(
                        'Действует до: ${_formatDate(_licenseInfo!['expires_at'])}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _licenseController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                LengthLimitingTextInputFormatter(24), // XXXX-XXXX-XXXX-XXXX-XXXX
                UpperCaseTextFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Введите лицензионный ключ',
                hintText: 'XXXX-XXXX-XXXX-XXXX-XXXX',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isActivating ? null : _activateLicense,
              child: _isActivating
                ? const CircularProgressIndicator()
                : Text(
                    'Активировать лицензию',
                    style: TextStyle(color: const Color(0xFF3579A6)),
                  ),
            ),
            if (_licenseInfo == null) ...[
              const SizedBox(height: 16),
              const Text(
                'Пробная версия доступна в течение 3 дней',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _activateTrial,
                child: Text(
                  'Активировать пробную версию',
                  style: TextStyle(color: const Color(0xFF3579A6)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _activateLicense() async {
    setState(() => _isActivating = true);
    
    try {
      final result = await LicenseManager.activateLicense(_licenseController.text);
      
      if (result['success']) {
        if (mounted) {
          final expiryDate = DateTime.parse(result['expires_at']);
          final type = result['type'] == 'perpetual' ? 'бессрочная' : 'годовая';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Лицензия успешно активирована'),
                  const SizedBox(height: 4),
                  Text('Тип: $type'),
                  Text(
                    'Действует до: ${expiryDate.day}.${expiryDate.month}.${expiryDate.year}',
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.pushReplacementNamed(context, '/launch');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка активации лицензии: ${result['error'] ?? 'Неизвестная ошибка'}'
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _activateLicense: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      setState(() => _isActivating = false);
    }
  }

  Future<void> _activateTrial() async {
    try {
      await LicenseManager.activateTrial();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пробный период активирован')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пробный период уже был использован')),
        );
      }
    }
  }
}

// Форматтер для преобразования текста в верхний регистр
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
} 