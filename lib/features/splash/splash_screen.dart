import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/audio_manager.dart';
import '../../core/storage/save_service.dart';
import '../home/home_screen.dart';
import 'widgets/app_splash_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    final save = SaveService();
    await save.init();

    final audio = AudioManager();
    await audio.init();
    audio.music.setEnabled(save.musicEnabled);
    audio.music.setVolume(save.musicVolume);
    audio.sfx.isEnabled = save.sfxEnabled;
    audio.sfx.volume = save.sfxVolume;

    if (save.musicEnabled) {
      await audio.music.startBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSplashScreen(
      appName: 'Panda Zen',
      appLogo: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/ui/panda_zen_icon.png',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
      companyPrefix: 'from',
      companyName: 'ghdinteractivestudio',
      companyNameGradient: AppSplashScreen.zenJadeGradient,
      preloadFuture: _initFuture,
      duration: const Duration(milliseconds: 2400),
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF142B20),
          Color(0xFF1B3B2B),
          Color(0xFF0F1F17),
        ],
      ),
      onFinish: () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            AppSplashScreen.fadeRoute(
              page: const HomeScreen(),
            ),
          );
        }
      },
    );
  }
}
