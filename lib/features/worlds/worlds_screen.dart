import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assets/environment_assets.dart';
import '../../assets/ui_assets.dart';
import '../../game/providers/progression_provider.dart';
import '../levels/levels_screen.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

class WorldsScreen extends ConsumerWidget {
  const WorldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final save = ref.watch(saveServiceProvider);

    final List<(int, String, String)> worlds = [
      (1, l10n.world1Name, EnvironmentAssets.world1BambooForest),
      (2, l10n.world2Name, EnvironmentAssets.world2MoonlightForest),
      (3, l10n.world3Name, EnvironmentAssets.world3SnowBamboo),
      (4, l10n.world4Name, EnvironmentAssets.world4PandaTemple),
      (5, l10n.world5Name, EnvironmentAssets.world5SpringValley),
      (6, l10n.world6Name, EnvironmentAssets.world6RainyForest),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              EnvironmentAssets.world1BambooForest,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          UiAssets.getSprite(UiSprite.btnBack, locale),
                          width: 44,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.worlds,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                ),

                // World list cards
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: worlds.length,
                    itemBuilder: (context, index) {
                      final (worldId, name, bg) = worlds[index];

                      int starsEarned = 0;
                      for (int lvl = 1; lvl <= 10; lvl++) {
                        starsEarned += save.getLevelStars('PZ_W${worldId}_L$lvl');
                      }

                      return GestureDetector(
                        onTap: () {
                          ref.read(progressionProvider.notifier).selectWorld(worldId);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LevelsScreen(
                                world: worldId,
                                worldName: name,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(bg, fit: BoxFit.cover),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.65),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.world} $worldId',
                                      style: const TextStyle(
                                        color: Color(0xFFFFD54F),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Color(0xFFFFD54F), size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$starsEarned/30',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
