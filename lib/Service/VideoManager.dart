import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:second_monitor/Service/logger.dart';

class VideoManager {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  Future<void> initialize({
    required bool isVideoFromInternet,
    required String videoSource,
  }) async {
    log('VideoManager: Starting initialization');
    if (videoSource.isEmpty) {
      log('VideoManager: Empty video source');
      return;
    }

    try {
      await dispose();  // Очищаем предыдущий контроллер

      log('VideoManager: Creating controller for: $videoSource');
      _videoController = isVideoFromInternet
          ? VideoPlayerController.networkUrl(Uri.parse(videoSource))
          : VideoPlayerController.file(File(videoSource));

      log('VideoManager: Initializing controller');
      await _videoController!.initialize();
      
      if (_videoController!.value.isInitialized) {
        log('VideoManager: Controller initialized successfully');
        await _videoController!.setLooping(true);
        await _videoController!.setVolume(0.0);
        _isInitialized = true;
      } else {
        log('VideoManager: Controller failed to initialize');
        _isInitialized = false;
      }
    } catch (e) {
      log('VideoManager: Error during initialization: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Widget buildVideoPlayer(BuildContext context) {
    if (!_isInitialized || _videoController == null) {
      log('VideoManager: Cannot build player - not initialized');
      return const SizedBox.shrink();
    }
    
    log('VideoManager: Building video player widget');
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

  void play() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      log('VideoManager: Playing video');
      _videoController!.play();
    } else {
      log('VideoManager: Cannot play - controller not ready');
    }
  }

  void pause() {
    if (_isInitialized && _videoController != null) {
      _videoController!.pause();
    }
  }

  Future<void> dispose() async {
    if (_videoController != null) {
      log('VideoManager: Disposing controller');
      await _videoController!.dispose();
      _videoController = null;
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;
}