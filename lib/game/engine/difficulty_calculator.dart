import '../models/puzzle.dart';

class DifficultyCalculator {
  const DifficultyCalculator();

  static PuzzleDifficulty calculate({
    required int boardSize,
    required int maxRegionSize,
    required double averageRegionSize,
    required int branchPoints,
  }) {
    if (boardSize <= 4) {
      return PuzzleDifficulty.easy;
    }
    if (boardSize == 5) {
      if (branchPoints > 4) return PuzzleDifficulty.medium;
      return PuzzleDifficulty.easy;
    }
    if (boardSize == 6) {
      if (branchPoints > 8) return PuzzleDifficulty.hard;
      return PuzzleDifficulty.medium;
    }
    if (boardSize >= 7) {
      if (branchPoints > 14) return PuzzleDifficulty.expert;
      return PuzzleDifficulty.hard;
    }
    return PuzzleDifficulty.medium;
  }
}
