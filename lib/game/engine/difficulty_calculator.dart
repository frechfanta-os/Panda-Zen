import '../models/puzzle.dart';

class DifficultyCalculator {
  const DifficultyCalculator();

  /// Calculates puzzle difficulty dynamically based on board size, region topology, and branch points.
  /// Designed for 8x8 (Standard) and 10x10 (Advanced), while scaling smoothly for any board dimension.
  static PuzzleDifficulty calculate({
    required int boardSize,
    required int maxRegionSize,
    required double averageRegionSize,
    required int branchPoints,
  }) {
    if (boardSize <= 8) {
      if (branchPoints > 8) return PuzzleDifficulty.hard;
      if (branchPoints > 3) return PuzzleDifficulty.medium;
      return PuzzleDifficulty.easy;
    } else {
      // 10x10 and above (Advanced / Expert)
      if (branchPoints > 12) return PuzzleDifficulty.expert;
      return PuzzleDifficulty.hard;
    }
  }
}
