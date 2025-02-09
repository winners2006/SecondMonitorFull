import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player_win/video_player_win.dart';
import 'package:second_monitor/Service/logger.dart';

class VideoManager {
  late WinVideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isDisposed = false;

  Future<void> initialize({
    required bool isVideoFromInternet,
    required String videoSource,
  }) async {
    try {
      log('Starting video initialization: $videoSource');
      
      if (_isInitialized) {
        await dispose();
      }

      if (!isVideoFromInternet) {
        final file = File(videoSource);
        if (!await file.exists()) {
          log('Video file not found: $videoSource');
          return;
        }
      }

      _videoController = isVideoFromInternet 
          ? WinVideoPlayerController.network(videoSource)
          : WinVideoPlayerController.file(File(videoSource));

      await _videoController.initialize();
      _isInitialized = true;
      _isDisposed = false;

      // Настройка воспроизведения
      await _videoController.setLooping(true);
      await _videoController.setVolume(0.0);
      
      log('Video initialized successfully');
      play();

    } catch (e) {
      log('Error in video initialization: $e');
      _isInitialized = false;
    }
  }

  Widget buildVideoPlayer() {
    if (!_isInitialized) {
      return Container(color: Colors.black);
    }

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: WinVideoPlayer(_videoController),
    );
  }

  void play() {
    if (_isInitialized) {
      _videoController.play();
    }
  }

  void pause() {
    if (_isInitialized) {
      _videoController.pause();
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    if (_isInitialized) {
      await _videoController.dispose();
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;
  WinVideoPlayerController get controller => _videoController;
}