import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assets/environment_assets.dart';
import '../../assets/ui_assets.dart';
import '../../core/storage/save_service.dart';
import '../../game/providers/progression_provider.dart';
import '../gameplay/gameplay_screen.dart';

class LevelsScreen extends ConsumerWidget {
  final int world;
  final String worldName;

  const LevelsScreen({
    super.key,
    required this.world,
    required this.worldName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final save = ref.watch(saveServiceProvider);

    final bgImage = EnvironmentAssets.forWorld(world);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(bgImage, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header
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
                      Expanded(
                        child: Text(
                          worldName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Level grid (1..10)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: SaveService.levelsPerWorld,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final record = save.getLevelRecord(world, level);
                      final isUnlocked = !record.isLocked;
                      final stars = record.stars;

                      return GestureDetector(
                        onTap: isUnlocked
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GameplayScreen(
                                      world: world,
                                      level: level,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color(0xFF4CAF50).withValues(alpha: 0.9)
                                : Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isUnlocked
                                  ? const Color(0xFFFFD54F)
                                  : Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isUnlocked) ...[
                                Text(
                                  '$level',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (s) {
                                    return Icon(
                                      Icons.star,
                                      size: 16,
                                      color: s < stars
                                          ? const Color(0xFFFFD54F)
                                          : Colors.white38,
                                    );
                                  }),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.lock,
                                  size: 32,
                                  color: Colors.white60,
                                ),
                              ],
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
