import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoManager {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  Future<void> initialize({
    required bool isVideoFromInternet,
    required String videoSource,
  }) async {
    if (videoSource.isEmpty) return;

    try {
      // Освобождаем предыдущий контроллер
      await dispose();

      // Создаем новый контроллер
      _videoController = isVideoFromInternet
          ? VideoPlayerController.networkUrl(Uri.parse(videoSource))
          : VideoPlayerController.file(File(videoSource));

      // Инициализируем контроллер
      await _videoController!.initialize();
      
      // Только после успешной инициализации настраиваем параметры
      if (_videoController != null && _videoController!.value.isInitialized) {
        await _videoController!.setLooping(true);
        await _videoController!.setVolume(0.0);
        _isInitialized = true;
        // Автоматически начинаем воспроизведение
        await _videoController!.play();
      }
    } catch (e) {
      print('Error initializing video: $e');
      _isInitialized = false;
    }
  }

  void play() {
    if (_isInitialized && _videoController != null) {
      _videoController!.play();
    }
  }

  void pause() {
    if (_isInitialized && _videoController != null) {
      _videoController!.pause();
    }
  }

  Widget buildVideoPlayer() {
    if (!_isInitialized || _videoController == null) {
      return const SizedBox.shrink();
    }
    return VideoPlayer(_videoController!);  // Убрали AspectRatio для полноэкранного отображения
  }

  Future<void> dispose() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;
}