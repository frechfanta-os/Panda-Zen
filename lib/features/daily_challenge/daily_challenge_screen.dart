import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../assets/environment_assets.dart';
import '../../assets/panda_assets.dart';
import '../../assets/ui_assets.dart';
import '../../game/engine/daily_puzzle_generator.dart';
import '../../game/providers/progression_provider.dart';
import '../../game/providers/puzzle_provider.dart';
import '../gameplay/gameplay_screen.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final save = ref.watch(saveServiceProvider);

    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isCompletedToday = save.dailyChallengeDate == dateKey && save.dailyChallengeCompleted;

    final formattedDate = DateFormat.yMMMMd(locale.languageCode).format(today);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(EnvironmentAssets.world2MoonlightForest, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
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
                      Text(
                        l10n.dailyChallenge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Daily Card Container
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFB300), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isCompletedToday ? PandaAssets.celebration : PandaAssets.hintButterfly,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seed: ${DailyPuzzleGenerator.seedForDate(today)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isCompletedToday) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            l10n.levelComplete,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                          ),
                          onPressed: () {
                            final dailyGen = ref.read(dailyPuzzleGeneratorProvider);
                            final puzzle = dailyGen.generateForDate(today, size: 5);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GameplayScreen(
                                  world: 2,
                                  level: today.day,
                                  customPuzzle: puzzle,
                                  customTitle: l10n.dailyChallenge,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow, size: 28, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                l10n.play,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
