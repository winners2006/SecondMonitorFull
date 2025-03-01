import 'package:flutter/material.dart';
import 'package:video_player_win/video_player_win.dart';
import 'dart:io';
import 'package:second_monitor/Service/logger.dart';

class VideoManager {
  WinVideoPlayerController? _videoController;
  bool _isInitialized = false;

  Future<void> initialize({
    required bool isVideoFromInternet,
    required String videoSource,
  }) async {
    try {
      _videoController = isVideoFromInternet
          ? WinVideoPlayerController.network(videoSource)
          : WinVideoPlayerController.file(File(videoSource));

      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0);
      
      _isInitialized = true;
    } catch (e) {
      log('VideoManager: Initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Widget buildVideoPlayer(BuildContext context) {
    if (!_isInitialized || _videoController == null) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: WinVideoPlayer(_videoController!),
    );
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

  Future<void> dispose() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;
}