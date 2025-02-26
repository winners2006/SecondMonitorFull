import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:second_monitor/Service/logger.dart';

class LicenseManager {
  static const String _serverUrl = 'http://localhost:8080';
  static const String _licenseKey = 'license_key';
  static const String _licenseExpiry = 'license_expiry';
  static const String _licenseType = 'license_type';
  static const String _activationDate = 'activation_date';
  static const String _trialKey = 'trial_active';
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

  // Сохранение данных лицензии
  static Future<void> saveLicense(String licenseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_licenseKey, licenseData);
      await prefs.setString(_activationDate, DateTime.now().toIso8601String());
      log('License saved successfully');
    } catch (e) {
      log('Error saving license: $e');
      rethrow;
    }
  }

  // Проверка лицензии
  static Future<bool> checkLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final key = prefs.getString(_licenseKey);
      final expiry = prefs.getString(_licenseExpiry);
      final type = prefs.getString(_licenseType);
      
      if (key == null || expiry == null || type == null) {
        log('License data missing');
        return false;
      }

      final expiryDate = DateTime.parse(expiry);
      final now = DateTime.now();

      if (type == 'perpetual') {
        return true;
      }

      return now.isBefore(expiryDate);
    } catch (e) {
      log('Error checking license: $e');
      return false;
    }
  }

  // Активация лицензии
  static Future<Map<String, dynamic>> activateLicense(String key) async {
    final prefs = await SharedPreferences.getInstance();
    
    final result = {
      'success': true,
      'type': 'perpetual',
      'expires_at': '2099-12-31',
    };

    if (result['success'] == true) {
      await prefs.setString(_licenseKey, key);
      await prefs.setString(_licenseExpiry, result['expires_at'] as String);
      await prefs.setString(_licenseType, result['type'] as String);
      await prefs.setString(_activationDate, DateTime.now().toIso8601String());
    }

    return result;
  }

  // Активация пробного периода
  static Future<void> activateTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final trialExpiry = DateTime.now().add(const Duration(days: 3));
    
    await prefs.setString(_licenseKey, 'TRIAL');
    await prefs.setString(_licenseExpiry, trialExpiry.toIso8601String());
    await prefs.setString(_licenseType, 'trial');
    await prefs.setString(_activationDate, DateTime.now().toIso8601String());
  }

  // Отзыв лицензии
  static Future<void> revokeLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
    await prefs.remove(_licenseExpiry);
    await prefs.remove(_licenseType);
    await prefs.remove(_activationDate);
  }

  // Геттеры
  static String get licenseKey => _licenseKey;
  static String get licenseExpiry => _licenseExpiry;
  static String get licenseType => _licenseType;
  static String get activationDate => _activationDate;
  static String get hardwareId => _hardwareId;
  static String get lastCheckDate => _lastCheckDate;
} 