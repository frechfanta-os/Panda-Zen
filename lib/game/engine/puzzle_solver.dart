import '../models/cell.dart';
import '../models/puzzle.dart';
import '../models/puzzle_solution.dart';
import 'puzzle_validator.dart';

class PuzzleSolver {
  const PuzzleSolver();

  /// Solves the puzzle and returns the first valid solution found, or null if none.
  PuzzleSolution? solve(Puzzle puzzle) {
    final solutions = <PuzzleSolution>[];
    _backtrack(
      puzzle: puzzle,
      currentRow: 0,
      currentPandas: <Position>[],
      usedCols: List.filled(puzzle.size, false),
      usedRegions: List.filled(puzzle.regions.length + 1, false),
      solutions: solutions,
      limit: 1,
    );
    return solutions.isNotEmpty ? solutions.first : null;
  }

  /// Returns true if the puzzle has at least one valid solution.
  bool hasSolution(Puzzle puzzle) {
    return solve(puzzle) != null;
  }

  /// Returns true if the puzzle has exactly one valid solution.
  bool hasUniqueSolution(Puzzle puzzle) {
    return countSolutions(puzzle, limit: 2) == 1;
  }

  /// Counts valid solutions up to [limit].
  int countSolutions(Puzzle puzzle, {int limit = 2}) {
    final solutions = <PuzzleSolution>[];
    _backtrack(
      puzzle: puzzle,
      currentRow: 0,
      currentPandas: <Position>[],
      usedCols: List.filled(puzzle.size, false),
      usedRegions: List.filled(puzzle.regions.length + 1, false),
      solutions: solutions,
      limit: limit,
    );
    return solutions.length;
  }

  /// Validates a candidate solution against the puzzle.
  bool validateSolution(Puzzle puzzle, PuzzleSolution solution) {
    return PuzzleValidator.isValidSolution(puzzle, solution);
  }

  void _backtrack({
    required Puzzle puzzle,
    required int currentRow,
    required List<Position> currentPandas,
    required List<bool> usedCols,
    required List<bool> usedRegions,
    required List<PuzzleSolution> solutions,
    required int limit,
  }) {
    if (solutions.length >= limit) return;

    if (currentRow == puzzle.size) {
      solutions.add(PuzzleSolution(pandaPositions: currentPandas.toSet()));
      return;
    }

    for (int col = 0; col < puzzle.size; col++) {
      if (usedCols[col]) continue;

      final regId = puzzle.getRegionId(currentRow, col);
      if (regId > 0 && regId < usedRegions.length && usedRegions[regId]) continue;

      final pos = Position(currentRow, col);

      // Check diagonal constraints with previous rows
      bool diagonalConflict = false;
      for (final prev in currentPandas) {
        final rowDiff = (prev.row - currentRow).abs();
        final colDiff = (prev.col - col).abs();
        if (rowDiff <= 1 && colDiff <= 1) {
          diagonalConflict = true;
          break;
        }
      }
      if (diagonalConflict) continue;

      // Choose
      currentPandas.add(pos);
      usedCols[col] = true;
      if (regId > 0 && regId < usedRegions.length) usedRegions[regId] = true;

      // Recurse
      _backtrack(
        puzzle: puzzle,
        currentRow: currentRow + 1,
        currentPandas: currentPandas,
        usedCols: usedCols,
        usedRegions: usedRegions,
        solutions: solutions,
        limit: limit,
      );

      // Unchoose
      currentPandas.removeLast();
      usedCols[col] = false;
      if (regId > 0 && regId < usedRegions.length) usedRegions[regId] = false;

      if (solutions.length >= limit) return;
    }
  }
}
