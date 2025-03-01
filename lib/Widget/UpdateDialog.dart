import 'package:flutter/material.dart';
import '../Service/UpdateService.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;

  const UpdateDialog({
    Key? key,
    required this.updateInfo,
  }) : super(key: key);

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Доступно обновление'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Новая версия: ${widget.updateInfo['version']}'),
          const SizedBox(height: 8),
          Text('Что нового:\n${widget.updateInfo['description']}'),
          const SizedBox(height: 16),
          if (_isDownloading) ...[
            const Text('Загрузка обновления...'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Позже'),
        ),
        if (!_isDownloading)
          ElevatedButton(
            onPressed: _downloadAndInstall,
            child: const Text('Обновить'),
          ),
      ],
    );
  }

  Future<void> _downloadAndInstall() async {
    try {
      setState(() => _isDownloading = true);

      final installerPath = await UpdateService.downloadUpdate(
        (received, total) {
          if (total != 0) {
            setState(() => _progress = received / total);
          }
        },
      );

      if (mounted) {
        // Показываем подтверждение перед установкой
        final shouldInstall = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Установка обновления'),
            content: const Text(
              'Обновление загружено. Программа будет закрыта для установки обновления. Продолжить?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Установить'),
              ),
            ],
          ),
        );

        if (shouldInstall == true) {
          await UpdateService.installUpdate(installerPath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
} 