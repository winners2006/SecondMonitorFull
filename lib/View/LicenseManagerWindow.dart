import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class LicenseManagerWindow extends StatefulWidget {
  const LicenseManagerWindow({super.key});

  @override
  _LicenseManagerWindowState createState() => _LicenseManagerWindowState();
}

class _LicenseManagerWindowState extends State<LicenseManagerWindow> {
  List<dynamic> _licenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/licenses/export'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _licenses = data['licenses'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading licenses: $e');
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скопировано в буфер обмена')),
    );
  }

  Future<void> _downloadCsv() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/licenses/export?format=csv'),
      );

      if (response.statusCode == 200) {
        // Здесь можно добавить логику сохранения файла
        print('CSV downloaded successfully');
      }
    } catch (e) {
      print('Error downloading CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление лицензиями'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Экспорт в CSV',
            onPressed: _downloadCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _loadLicenses,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Ключ')),
                  DataColumn(label: Text('Тип')),
                  DataColumn(label: Text('Hardware ID')),
                  DataColumn(label: Text('Дата активации')),
                  DataColumn(label: Text('Действует до')),
                  DataColumn(label: Text('Статус')),
                  DataColumn(label: Text('Действия')),
                ],
                rows: _licenses.map<DataRow>((license) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(license['key']),
                        onTap: () => _copyToClipboard(license['key']),
                      ),
                      DataCell(Text(license['type'] == 'perpetual' ? 'Бессрочная' : 'Годовая')),
                      DataCell(
                        Text(license['hardware_id'] ?? 'Не активирована'),
                        onTap: () => license['hardware_id'] != null 
                            ? _copyToClipboard(license['hardware_id'])
                            : null,
                      ),
                      DataCell(Text(_formatDate(license['activated_at']))),
                      DataCell(Text(_formatDate(license['expires_at']))),
                      DataCell(
                        Text(
                          license['status'] == 'active' ? 'Активна' : 'Истекла',
                          style: TextStyle(
                            color: license['status'] == 'active' 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Копировать ключ',
                            onPressed: () => _copyToClipboard(license['key']),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Не указано';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
} 