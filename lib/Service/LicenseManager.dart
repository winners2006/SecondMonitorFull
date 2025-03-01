import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:second_monitor/Service/logger.dart';
import 'package:http/http.dart' as http;
import '../Config/config.dart';

class LicenseManager {
  static String get _serverUrl => 
    '${Config.licenseServerUrl}:${Config.licenseServerPort}';
  static const String _licenseKey = 'license_key';
  static const String _licenseExpiry = 'license_expiry';
  static const String _licenseType = 'license_type';
  static const String _activationDate = 'activation_date';
  static const String _trialKey = 'trial_active';
  static const String _lastCheckDate = 'last_check_date';
  static const String _hardwareId = 'hardware_id';
  static const String _offlineMode = 'offline_mode';
  
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
        log('Error getting hardware ID: $e');
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
      log('Error getting WMI value: $e');
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

  // Проверка лицензии с учетом онлайн/офлайн режима
  static Future<Map<String, dynamic>> checkLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_licenseKey);
      final type = prefs.getString(_licenseType);
      
      // Проверяем наличие базовых данных лицензии
      if (key == null || type == null) {
        return {'valid': false, 'message': 'Лицензия не найдена'};
      }

      // Проверяем тестовый период (только локально)
      if (type == 'trial') {
        final expiryStr = prefs.getString(_licenseExpiry);
        if (expiryStr == null) return {'valid': false, 'message': 'Ошибка тестового периода'};
        
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isAfter(expiry)) {
          await revokeLicense(); // Очищаем истекшую пробную лицензию
          return {'valid': false, 'message': 'Тестовый период истек'};
        }
        return {'valid': true, 'message': 'Тестовый период активен'};
      }

      // Для обычных лицензий проверяем на сервере
      try {
        final response = await _checkLicenseOnServer(key);
        await prefs.setString(_lastCheckDate, DateTime.now().toIso8601String());
        await prefs.setBool(_offlineMode, false);
        return response;
      } catch (e) {
        // Сервер недоступен, проверяем возможность офлайн работы
        final lastCheck = prefs.getString(_lastCheckDate);
        final isOfflineMode = prefs.getBool(_offlineMode) ?? false;
        
        if (lastCheck != null) {
          final lastCheckDate = DateTime.parse(lastCheck);
          final offlinePeriodValid = DateTime.now().difference(lastCheckDate) <= Config.offlinePeriod;
          
          if (offlinePeriodValid || isOfflineMode) {
            await prefs.setBool(_offlineMode, true);
            return {'valid': true, 'message': 'Офлайн режим активен'};
          }
        }
        
        return {
          'valid': false,
          'message': 'Сервер лицензий недоступен. Превышен период автономной работы'
        };
      }
    } catch (e) {
      log('Error checking license: $e');
      return {'valid': false, 'message': 'Ошибка проверки лицензии'};
    }
  }

  // Проверка лицензии на сервере
  static Future<Map<String, dynamic>> _checkLicenseOnServer(String key) async {
    try {
      final hardwareId = await getHardwareId();
      final response = await http.post(
        Uri.parse('$_serverUrl${Config.verifyEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'license_key': key,
          'hardware_id': hardwareId,
        }),
      ).timeout(Config.connectionTimeout);

      log('Verify response status: ${response.statusCode}');
      log('Verify response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['valid']) {
          await _updateLicenseData({
            'type': data['type'],
            'expires_at': data['expiresAt'],
            'customer_name': data['customerName'] ?? 'Unknown',
            'is_active': true,
          });
          return {'valid': true, 'message': 'Лицензия активна'};
        } else {
          return {'valid': false, 'message': data['message'] ?? 'Лицензия недействительна'};
        }
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      log('Error in _checkLicenseOnServer: $e');
      throw Exception('Ошибка соединения с сервером');
    }
  }

  // Обновление данных лицензии
  static Future<void> _updateLicenseData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseExpiry, data['expires_at']);
    await prefs.setString(_licenseType, data['type']);
    await prefs.setString(_lastCheckDate, DateTime.now().toIso8601String());
  }

  // Активация лицензии
  static Future<Map<String, dynamic>> activateLicense(String key) async {
    try {
      final hardwareId = await getHardwareId();
      final url = '$_serverUrl${Config.activateEndpoint}';
      log('Attempting to activate license at URL: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'license_key': key,
          'hardware_id': hardwareId,
        }),
      ).timeout(Config.connectionTimeout);

      log('Activate response status: ${response.statusCode}');
      log('Activate response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await _updateLicenseData({
            'type': data['type'],
            'expires_at': data['expiresAt'],
            'customer_name': data['customerName'] ?? 'Unknown',
            'is_active': true,
          });
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_licenseKey, key);
          await prefs.setString(_activationDate, DateTime.now().toIso8601String());
          
          return {
            'success': true,
            'type': data['type'],
            'expires_at': data['expiresAt'],
            'customer_name': data['customerName'] ?? 'Unknown',
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? data['message'] ?? 'Ошибка активации'
          };
        }
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      log('Error in activateLicense: $e');
      return {
        'success': false,
        'error': 'Ошибка соединения с сервером'
      };
    }
  }

  // Активация пробного периода
  static Future<void> activateTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final trialExpiry = DateTime.now().add(Config.trialPeriod);
    
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