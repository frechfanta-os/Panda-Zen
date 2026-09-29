import 'package:flutter/widgets.dart';
import 'music_manager.dart';
import 'sfx_manager.dart';

class AudioManager with WidgetsBindingObserver {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final MusicManager music = MusicManager();
  final SfxManager sfx = SfxManager();

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await music.init();
    await sfx.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      music.pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      if (music.isEnabled) {
        music.resumeBgm();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    music.dispose();
    sfx.dispose();
  }
}
