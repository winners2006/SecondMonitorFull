import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class FontManager {
  static Future<TextStyle> loadCustomFont(String fontPath, TextStyle baseStyle) async {
    try {
      if (fontPath.isEmpty || !File(fontPath).existsSync()) {
        return baseStyle;
      }

      // Загружаем файл шрифта
      final File fontFile = File(fontPath);
      final List<int> fontData = await fontFile.readAsBytes();
      
      // Регистрируем шрифт
      final fontLoader = FontLoader('CustomFont');
      fontLoader.addFont(Future.value(ByteData.view(Uint8List.fromList(fontData).buffer)));
      await fontLoader.load();

      // Применяем шрифт к стилю
      return baseStyle.copyWith(
        fontFamily: 'CustomFont',
      );
    } catch (e) {
      print('Error loading font: $e');
      return baseStyle;
    }
  }
} 