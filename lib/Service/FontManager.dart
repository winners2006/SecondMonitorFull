import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:second_monitor/Service/logger.dart';

class FontManager {
  static int _fontCounter = 0;
  
  static Future<TextStyle> loadCustomFont(String fontPath, TextStyle baseStyle) async {
    try {
      if (fontPath.isEmpty || !File(fontPath).existsSync()) {
        return baseStyle;
      }

      // Создаем уникальное имя для каждой загрузки шрифта
      final fontName = 'CustomFont${_fontCounter++}';
      
      // Загружаем файл шрифта
      final File fontFile = File(fontPath);
      final List<int> fontData = await fontFile.readAsBytes();
      
      // Регистрируем шрифт с уникальным именем
      final fontLoader = FontLoader(fontName);
      fontLoader.addFont(Future.value(ByteData.view(Uint8List.fromList(fontData).buffer)));
      await fontLoader.load();

      // Применяем шрифт к стилю
      return baseStyle.copyWith(
        fontFamily: fontName,
      );
    } catch (e) {
      log('Error loading font: $e');
      return baseStyle;
    }
  }
} 