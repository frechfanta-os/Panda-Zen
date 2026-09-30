/// Data models for level and world progression in Panda Zen.
library;

enum LevelState {
  locked,
  available,
  completed,
  mastered,
}

class LevelRecord {
  final int worldId;
  final int levelId;
  final LevelState state;
  final int stars;
  final int bestTime;
  final int completionCount;
  final int bestMistakes;
  final int bestHintUsage;

  const LevelRecord({
    required this.worldId,
    required this.levelId,
    required this.state,
    this.stars = 0,
    this.bestTime = 0,
    this.completionCount = 0,
    this.bestMistakes = 0,
    this.bestHintUsage = 0,
  });

  bool get isLocked => state == LevelState.locked;
  bool get isAvailable => state == LevelState.available;
  bool get isCompleted =>
      state == LevelState.completed || state == LevelState.mastered;
  bool get isMastered => state == LevelState.mastered;

  LevelRecord copyWith({
    int? worldId,
    int? levelId,
    LevelState? state,
    int? stars,
    int? bestTime,
    int? completionCount,
    int? bestMistakes,
    int? bestHintUsage,
  }) {
    return LevelRecord(
      worldId: worldId ?? this.worldId,
      levelId: levelId ?? this.levelId,
      state: state ?? this.state,
      stars: stars ?? this.stars,
      bestTime: bestTime ?? this.bestTime,
      completionCount: completionCount ?? this.completionCount,
      bestMistakes: bestMistakes ?? this.bestMistakes,
      bestHintUsage: bestHintUsage ?? this.bestHintUsage,
    );
  }
}

class WorldRecord {
  final int worldId;
  final String name;
  final int totalLevels;
  final int completedLevels;
  final int totalStars;
  final int maxStars;
  final bool isUnlocked;

  const WorldRecord({
    required this.worldId,
    required this.name,
    this.totalLevels = 30,
    required this.completedLevels,
    required this.totalStars,
    this.maxStars = 90,
    this.isUnlocked = true,
  });

  double get progressPercentage =>
      totalLevels == 0 ? 0.0 : (completedLevels / totalLevels).clamp(0.0, 1.0);

  double get starsPercentage =>
      maxStars == 0 ? 0.0 : (totalStars / maxStars).clamp(0.0, 1.0);
}

/// STAR_RULE_DESIGN_PENDING
///
/// Isolated star calculation evaluator to allow product refinement without breaking changes.
///
/// Current interim specification:
/// - 3 stars: mistakes == 0 && hintsUsed == 0
/// - 2 stars: mistakes <= 1 && hintsUsed <= 1 (excluding 0/0)
/// - 1 star: all other successful completions
///
/// Note: Elapsed time currently does NOT affect star calculation.
class StarEvaluator {
  const StarEvaluator._();

  static int evaluate({
    required bool isCompleted,
    required int mistakes,
    required int hintsUsed,
    int? elapsedSeconds,
  }) {
    if (!isCompleted) return 0;

    // STAR_RULE_DESIGN_PENDING:
    // Verify if 2-star threshold should remain (mistakes <= 1 && hintsUsed <= 1)
    // or be adjusted per product requirements.
    if (mistakes == 0 && hintsUsed == 0) return 3;
    if (mistakes <= 1 && hintsUsed <= 1) return 2;
    return 1;
  }
}

