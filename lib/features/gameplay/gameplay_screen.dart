import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assets/environment_assets.dart';
import '../../assets/panda_assets.dart';
import '../../assets/ui_assets.dart';
import '../../game/models/game_session.dart';
import '../../game/models/puzzle.dart';
import '../../game/providers/game_provider.dart';
import '../../game/providers/progression_provider.dart';
import '../../game/providers/puzzle_provider.dart';
import '../../game/widgets/puzzle_board.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final int world;
  final int level;
  final Puzzle? customPuzzle;
  final String? customTitle;

  const GameplayScreen({
    super.key,
    required this.world,
    required this.level,
    this.customPuzzle,
    this.customTitle,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  bool _modalShown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final Puzzle puzzle = widget.customPuzzle ??
        ref.watch(puzzleForLevelProvider(LevelSpec(widget.world, widget.level)));

    final session = ref.watch(gameProviderFamily(puzzle));
    final notifier = ref.read(gameProviderFamily(puzzle).notifier);

    // Completion or failure triggers
    ref.listen<GameSession>(gameProviderFamily(puzzle), (previous, current) {
      if (!_modalShown) {
        if (current.status == GameStatus.completed) {
          _modalShown = true;
          ref.read(progressionProvider.notifier).unlockNextLevel(widget.world, widget.level);
          _showVictoryDialog(context, current, l10n);
        } else if (current.status == GameStatus.failed) {
          _modalShown = true;
          _showFailedDialog(context, notifier, l10n);
        }
      }
    });

    final bgImage = EnvironmentAssets.forWorld(widget.world);

    return Scaffold(
      body: Stack(
        children: [
          // Background environment with soft dimming overlay
          Positioned.fill(
            child: Image.asset(
              bgImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          // Safe Area content
          SafeArea(
            child: Column(
              children: [
                // Top HUD
                _buildTopHud(context, session, notifier, l10n, locale),

                const Spacer(),

                // Center Board
                Center(
                  child: PuzzleBoard(
                    puzzle: puzzle,
                    cellStates: session.cellStates,
                    onCellTap: (r, c) => notifier.tapCell(r, c),
                  ),
                ),

                const Spacer(),

                // Bottom Action Bar
                _buildBottomBar(context, session, notifier, l10n, locale),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHud(
    BuildContext context,
    GameSession session,
    GameNotifier notifier,
    AppLocalizations l10n,
    Locale locale,
  ) {
    final title = widget.customTitle ?? '${l10n.level} ${widget.level}';
    final minutes = (session.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (session.elapsedSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset(
              UiAssets.getSprite(UiSprite.btnBack, locale),
              width: 44,
              height: 44,
            ),
          ),
          const SizedBox(width: 8),

          // Level Header Banner
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(PandaAssets.happyWave, width: 26, height: 26),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Mistakes / Hearts indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3E2723).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
            ),
            child: Row(
              children: List.generate(session.maxMistakes, (i) {
                final isAlive = i < (session.maxMistakes - session.mistakes);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.favorite,
                    size: 18,
                    color: isAlive ? Colors.redAccent : Colors.grey.withValues(alpha: 0.6),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),

          // Pause Button
          GestureDetector(
            onTap: () {
              notifier.pauseGame();
              _showPauseDialog(context, notifier, l10n);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    GameSession session,
    GameNotifier notifier,
    AppLocalizations l10n,
    Locale locale,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo Button
          _buildActionButton(
            label: l10n.undo,
            icon: Icons.undo,
            color: const Color(0xFF8D6E63),
            onTap: session.history.isNotEmpty ? () => notifier.undo() : null,
          ),

          // Restart Button
          _buildActionButton(
            label: l10n.restart,
            icon: Icons.refresh,
            color: const Color(0xFFD32F2F),
            onTap: () => notifier.restart(),
          ),

          // Hint Button
          _buildActionButton(
            label: l10n.hint,
            icon: Icons.lightbulb,
            color: const Color(0xFF388E3C),
            badge: session.hintsUsed > 0 ? '${session.hintsUsed}' : null,
            onTap: () => notifier.useHint(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    String? badge,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog(BuildContext context, GameSession session, AppLocalizations l10n) {
    final stars = session.calculateStars();
    final minutes = (session.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (session.elapsedSeconds % 60).toString().padLeft(2, '0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4CAF50), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star rating header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final earned = i < stars;
                    return Icon(
                      Icons.star,
                      size: 40,
                      color: earned ? const Color(0xFFFFB300) : Colors.grey.withValues(alpha: 0.4),
                    );
                  }),
                ),
                const SizedBox(height: 12),

                // Celebrating Panda
                Image.asset(
                  PandaAssets.celebration,
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.levelComplete,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  '${l10n.time}: $minutes:$seconds\n${l10n.hintsUsed}: ${session.hintsUsed}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF5D4037),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons: Home, Replay, Next
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, size: 32, color: Color(0xFF5D4037)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 32, color: Color(0xFFD32F2F)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _modalShown = false;
                        ref.read(gameProviderFamily(session.puzzle).notifier).restart();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => GameplayScreen(
                              world: widget.world,
                              level: widget.level + 1,
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.play_arrow, size: 32, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFailedDialog(BuildContext context, GameNotifier notifier, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF546E7A), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  PandaAssets.mistakeSad,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.failed,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tryAgain,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF455A64),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, size: 32, color: Color(0xFF37474F)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _modalShown = false;
                        notifier.restart();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.refresh, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(l10n.restart, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPauseDialog(BuildContext context, GameNotifier notifier, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF8D6E63), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.pause,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    notifier.resumeGame();
                  },
                  child: Text(
                    l10n.continueGame,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    notifier.restart();
                  },
                  child: Text(l10n.restart),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.quit, style: const TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
