import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:crypto/crypto.dart';

class LicenseManager {
  static const String _serverUrl = 'http://localhost:8080';
  static const String _licenseKey = 'license_key';
  static const String _licenseExpiry = 'license_expiry';
  static const String _lastCheckDate = 'last_check_date';
  static const String _hardwareId = 'hardware_id';
  
  // Получение hardware ID
  static Future<String> getHardwareId() async {
    if (Platform.isWindows) {
      try {
        // Получаем MAC-адрес
        final networkInfo = NetworkInfo();
        final String? macAddress = await networkInfo.getWifiBSSID();

        // Получаем информацию о системе через WMI
        final motherboardSerial = await _getWMIValue('Win32_BaseBoard', 'SerialNumber');
        final processorId = await _getWMIValue('Win32_Processor', 'ProcessorId');
        
        // Комбинируем все идентификаторы
        final combinedId = '$macAddress-$motherboardSerial-$processorId';
        
        // Создаем хеш для безопасности
        final bytes = utf8.encode(combinedId);
        final digest = sha256.convert(bytes);
        
        return digest.toString();
      } catch (e) {
        print('Error getting hardware ID: $e');
        return 'unknown';
      }
    }
    return 'unknown';
  }

  // Метод для получения значений через WMI
  static Future<String> _getWMIValue(String wmiClass, String property) async {
    try {
      final process = await Process.run('powershell', [
        "Get-WmiObject -Class $wmiClass | Select-Object -ExpandProperty $property"
      ]);

      if (process.exitCode == 0 && process.stdout != null) {
        return process.stdout.toString().trim();
      }
    } catch (e) {
      print('Error getting WMI value: $e');
    }
    return 'unknown';
  }

  // Добавляем метод для отвязки лицензии
  static Future<void> revokeLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
    await prefs.remove(_licenseExpiry);
    await prefs.remove(_hardwareId);
    await prefs.remove(_lastCheckDate);
  }

  // Проверка лицензии
  static Future<bool> checkLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_licenseKey);
      final savedHardwareId = prefs.getString(_hardwareId);
      final expiryDate = prefs.getString(_licenseExpiry);
      
      // Проверяем наличие всех необходимых данных
      if (key == null || savedHardwareId == null || expiryDate == null) {
        print('Missing license data');
        await revokeLicense();
        return false;
      }

      // Проверяем срок действия
      final expiry = DateTime.parse(expiryDate);
      if (DateTime.now().isAfter(expiry)) {
        print('License expired');
        await revokeLicense();
        return false;
      }

      // Получаем текущий hardware ID
      final currentHardwareId = await getHardwareId();
      
      // Проверяем соответствие hardware ID
      if (currentHardwareId != savedHardwareId) {
        print('Hardware ID mismatch');
        await revokeLicense();
        return false;
      }

      // Проверяем на сервере
      final response = await http.post(
        Uri.parse('$_serverUrl/api/license/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'license_key': key.trim(),
          'hardware_id': currentHardwareId,
        }),
      );

      if (response.statusCode != 200) {
        print('Server verification failed');
        await revokeLicense();
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking license: $e');
      return false;
    }
  }

  // Активация лицензии
  static Future<Map<String, dynamic>> activateLicense(String key) async {
    try {
      final hardwareId = await getHardwareId();
      print('Activating license with key: ${key.trim()}');
      print('Hardware ID: $hardwareId');
      
      final response = await http.post(
        Uri.parse('$_serverUrl/api/license/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'license_key': key.trim(),
          'hardware_id': hardwareId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_licenseKey, key.trim());
        await prefs.setString(_hardwareId, hardwareId);
        await prefs.setString(_licenseExpiry, data['expiresAt']);
        await prefs.setString(_lastCheckDate, DateTime.now().toIso8601String());
        
        return {
          'success': true,
          'type': data['type'],
          'expires_at': data['expiresAt'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Ошибка активации лицензии',
          'code': response.statusCode
        };
      }
    } catch (e) {
      print('Error activating license: $e');
      return {
        'success': false,
        'error': 'Ошибка сети или сервера: $e',
        'code': -1
      };
    }
  }

  // Активация пробного периода
  static Future<bool> activateTrial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trialUsed = prefs.getBool('trial_used') ?? false;
      if (trialUsed) return false;

      await prefs.setBool('trial_used', true);
      await prefs.setString(_licenseExpiry, DateTime.now().add(const Duration(days: 3)).toIso8601String());
      await prefs.setString(_lastCheckDate, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Добавляем геттеры для доступа к приватным полям
  static String get licenseKey => _licenseKey;
  static String get licenseExpiry => _licenseExpiry;
  static String get hardwareId => _hardwareId;
  static String get lastCheckDate => _lastCheckDate;
} 