import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assets/panda_assets.dart';
import '../../audio/audio_manager.dart';
import '../../core/storage/save_service.dart';
import '../home/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _initializeApp();
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

    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim, secAnim) => const HomeScreen(),
          transitionsBuilder: (context, animation, secAnim, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3B2B),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                PandaAssets.loadingRelaxed,
                height: 160,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'Panda Zen',
                style: TextStyle(
                  color: Color(0xFFE8F5E9),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
