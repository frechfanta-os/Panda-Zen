import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assets/environment_assets.dart';
import '../../assets/panda_assets.dart';
import '../../assets/ui_assets.dart';
import '../../game/providers/progression_provider.dart';
import '../daily_challenge/daily_challenge_screen.dart';
import '../gameplay/gameplay_screen.dart';
import '../settings/settings_screen.dart';
import '../worlds/worlds_screen.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final progression = ref.watch(progressionProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background environment
          Positioned.fill(
            child: Image.asset(
              EnvironmentAssets.world1BambooForest,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header: Currencies & Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coins badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFD54F), size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${progression.totalStars}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
                          ),
                          child: const Icon(Icons.settings, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Title and Panda Mascot
                Column(
                  children: [
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      PandaAssets.calmIdle,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),

                const Spacer(),

                // Main Play Button (using localized UI sprite)
                GestureDetector(
                  onTap: () {
                    final currentWorld = progression.currentWorld;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GameplayScreen(
                          world: currentWorld,
                          level: 1,
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    UiAssets.getSprite(UiSprite.btnPlay, locale),
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Menu action tiles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Worlds
                      _buildMenuTile(
                        imagePath: UiAssets.getSprite(UiSprite.btnWorlds, locale),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WorldsScreen()),
                          );
                        },
                      ),
                      // Daily Challenge
                      _buildMenuTile(
                        imagePath: UiAssets.getSprite(UiSprite.btnDaily, locale),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({required String imagePath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        imagePath,
        height: 52,
        fit: BoxFit.contain,
      ),
    );
  }
}
