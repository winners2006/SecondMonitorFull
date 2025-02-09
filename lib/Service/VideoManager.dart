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
    if (videoSource.isEmpty) return;

    try {
      log('Starting video initialization: $videoSource');
      
      await dispose();

      _videoController = isVideoFromInternet
          ? VideoPlayerController.networkUrl(Uri.parse(videoSource))
          : VideoPlayerController.file(File(videoSource));

      await _videoController!.initialize();
      
      if (_videoController != null && _videoController!.value.isInitialized) {
        await _videoController!.setLooping(true);
        await _videoController!.setVolume(0.0);
        _isInitialized = true;
        await _videoController!.play();
      }
    } catch (e) {
      log('Error initializing video: $e');
      _isInitialized = false;
    }
  }

  Widget buildVideoPlayer(BuildContext context) {
    if (!_isInitialized || _videoController == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
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