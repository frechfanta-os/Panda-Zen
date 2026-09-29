import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicManager {
  static final MusicManager _instance = MusicManager._internal();
  factory MusicManager() => _instance;
  MusicManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool isEnabled = true;
  double volume = 0.5;
  bool _isPlaying = false;

  static const String mainTheme = 'audio/music/panda_zen_main_theme.mp3';

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(volume);
    } catch (e) {
      debugPrint('MusicManager init error: $e');
    }
  }

  Future<void> startBgm() async {
    if (!isEnabled || _isPlaying) return;
    try {
      await _player.setVolume(volume);
      await _player.play(AssetSource(mainTheme));
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing BGM: $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        _isPlaying = false;
      }
    } catch (e) {
      debugPrint('Error pausing BGM: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (!isEnabled) return;
    try {
      if (!_isPlaying) {
        await _player.resume();
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error resuming BGM: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping BGM: $e');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    isEnabled = enabled;
    if (!enabled) {
      await pauseBgm();
    } else {
      await resumeBgm();
    }
  }

  Future<void> setVolume(double val) async {
    volume = val.clamp(0.0, 1.0);
    try {
      await _player.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting BGM volume: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
