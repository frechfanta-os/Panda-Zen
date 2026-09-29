import '../models/cell.dart';
import '../models/puzzle.dart';
import '../models/puzzle_solution.dart';

class PuzzleValidator {
  const PuzzleValidator();

  /// Validates whether a set of panda positions adheres to all puzzle rules:
  /// 1. Exactly 1 panda per region (if regions provided)
  /// 2. Exactly 1 panda per row (or at most 1 for partial)
  /// 3. Exactly 1 panda per column (or at most 1 for partial)
  /// 4. No diagonal adjacency between any two pandas
  static bool isValidSolution(Puzzle puzzle, PuzzleSolution solution) {
    if (solution.pandaPositions.length != puzzle.size) {
      return false;
    }

    final rows = <int>{};
    final cols = <int>{};
    final regions = <int>{};

    final pandas = solution.pandaPositions.toList();

    for (int i = 0; i < pandas.length; i++) {
      final p1 = pandas[i];

      // Check bounds
      if (p1.row < 0 || p1.row >= puzzle.size || p1.col < 0 || p1.col >= puzzle.size) {
        return false;
      }

      // Check row & col uniqueness
      if (!rows.add(p1.row)) return false;
      if (!cols.add(p1.col)) return false;

      // Check region uniqueness
      final regId = puzzle.getRegionId(p1.row, p1.col);
      if (!regions.add(regId)) return false;

      // Check diagonal adjacency with all other pandas
      for (int j = i + 1; j < pandas.length; j++) {
        final p2 = pandas[j];
        final rowDiff = (p1.row - p2.row).abs();
        final colDiff = (p1.col - p2.col).abs();

        // Diagonal touching: rowDiff == 1 && colDiff == 1
        // Orthogonal touching: (rowDiff == 1 && colDiff == 0) or (rowDiff == 0 && colDiff == 1)
        if (rowDiff <= 1 && colDiff <= 1) {
          return false;
        }
      }
    }

    return rows.length == puzzle.size &&
        cols.length == puzzle.size &&
        regions.length == puzzle.size;
  }

  /// Checks if adding a panda at [pos] would violate row, col, or diagonal constraints
  /// against existing pandas in [currentPandas].
  static bool canPlacePanda({
    required Position pos,
    required Iterable<Position> currentPandas,
    required int boardSize,
    int? regionId,
    Puzzle? puzzle,
  }) {
    if (pos.row < 0 || pos.row >= boardSize || pos.col < 0 || pos.col >= boardSize) {
      return false;
    }

    for (final other in currentPandas) {
      if (other == pos) return false;
      if (other.row == pos.row) return false;
      if (other.col == pos.col) return false;

      final rowDiff = (other.row - pos.row).abs();
      final colDiff = (other.col - pos.col).abs();
      // No diagonal adjacency
      if (rowDiff == 1 && colDiff == 1) return false;
      // No orthogonal adjacency
      if (rowDiff + colDiff == 1) return false;

      if (puzzle != null) {
        if (puzzle.getRegionId(pos.row, pos.col) == puzzle.getRegionId(other.row, other.col)) {
          return false;
        }
      }
    }

    return true;
  }
}
