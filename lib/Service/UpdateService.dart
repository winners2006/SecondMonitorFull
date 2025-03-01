import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:process_run/shell.dart';

class UpdateService {
  static const String _baseUrl = 'http://31.31.207.104:8080';
  static const String _currentVersionEndpoint = '/api/updates/current';
  static const String _checkUpdatesEndpoint = '/api/updates/check';
  static const String _downloadEndpoint = '/api/updates/download';

  // Проверка наличия обновлений
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse('$_baseUrl$_checkUpdatesEndpoint'),
        headers: {'current-version': currentVersion},
      );

      if (response.statusCode == 204) {
        // Нет доступных обновлений
        return null;
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw Exception('Ошибка при проверке обновлений: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка при проверке обновлений: $e');
    }
  }

  // Загрузка обновления
  static Future<String> downloadUpdate(
    void Function(int received, int total) onProgress,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_downloadEndpoint'),
      );

      if (response.statusCode == 200) {
        // Получаем директорию для временных файлов
        final tempDir = await getTemporaryDirectory();
        final fileName = response.headers['content-disposition']
            ?.split('filename=')
            .last
            .replaceAll('"', '') ??
            'SecondMonitor_update.exe';
        final file = File('${tempDir.path}\\$fileName');

        // Записываем файл
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }

      throw Exception('Ошибка при загрузке обновления: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка при загрузке обновления: $e');
    }
  }

  // Установка обновления
  static Future<void> installUpdate(String installerPath) async {
    try {
      final shell = Shell();
      // Запускаем установщик и закрываем текущее приложение
      await shell.run(installerPath);
      exit(0);
    } catch (e) {
      throw Exception('Ошибка при установке обновления: $e');
    }
  }
} 