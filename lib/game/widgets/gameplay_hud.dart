import 'package:flutter/material.dart';
import '../../assets/panda_assets.dart';
import '../../l10n/app_localizations.dart';

/// Responsive Gameplay HUD displaying Level (Left), Timer (Center), and Mistakes + Pause (Right).
///
/// Eliminates text collision between level and timer, centers the timer,
/// and supports French and English localizations across compact and tall screen widths.
class GameplayHud extends StatelessWidget {
  final String title;
  final int elapsedSeconds;
  final int mistakes;
  final int maxMistakes;
  final VoidCallback onPause;

  const GameplayHud({
    super.key,
    required this.title,
    required this.elapsedSeconds,
    required this.mistakes,
    required this.maxMistakes,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levelLabel = l10n?.level ?? 'Level';
    final timeLabel = l10n?.time ?? 'Time';
    final pauseLabel = l10n?.pause ?? 'Pause';
    final mistakesLabel = l10n?.mistakes ?? 'Mistakes';

    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    final remainingLives = (maxMistakes - mistakes).clamp(0, maxMistakes);
    final String semanticTitle;
    if (title.contains(levelLabel)) {
      semanticTitle = title;
    } else if (int.tryParse(title) != null) {
      semanticTitle = '$levelLabel $title';
    } else {
      semanticTitle = title;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          // LEFT: [ 🐼 Level X ]
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                label: semanticTitle,
                excludeSemantics: true,
                readOnly: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        PandaAssets.happyWave,
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CENTER: [ 00:03 ]
          Semantics(
            label: '$timeLabel $minutes:$seconds',
            readOnly: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Color(0xFFFFD54F),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT: [ ❤️❤️❤️ ] [ Pause ]
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mistakes / Lives
                  Semantics(
                    label: '$remainingLives $mistakesLabel',
                    readOnly: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(maxMistakes, (i) {
                          final isAlive = i < remainingLives;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1.5),
                            child: Icon(
                              Icons.favorite,
                              size: 13,
                              color: isAlive
                                  ? const Color(0xFFE53935)
                                  : Colors.grey.withValues(alpha: 0.45),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),

                  // Pause Button
                  Semantics(
                    button: true,
                    label: pauseLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onPause,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2723).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.pause, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
