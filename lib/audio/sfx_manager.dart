import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SfxManager {
  static final SfxManager _instance = SfxManager._internal();
  factory SfxManager() => _instance;
  SfxManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool isEnabled = true;
  double volume = 0.8;

  static const String sfxCorrectTile = 'audio/sfx/correct_tile.mp3';
  static const String sfxHint = 'audio/sfx/hint.mp3';
  static const String sfxInvalidMove = 'audio/sfx/invalid_move.mp3';
  static const String sfxPandaPlace = 'audio/sfx/panda_place.mp3';

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('SfxManager init error: $e');
    }
  }

  Future<void> playCorrect() => _play(sfxCorrectTile);
  Future<void> playHint() => _play(sfxHint);
  Future<void> playInvalidMove() => _play(sfxInvalidMove);
  Future<void> playPandaReveal() => _play(sfxPandaPlace);

  Future<void> _play(String assetPath) async {
    if (!isEnabled) return;
    try {
      await _player.setVolume(volume);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing SFX $assetPath: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
