import '../models/cell.dart';
import '../models/puzzle.dart';
import '../models/puzzle_solution.dart';
import 'puzzle_validator.dart';

/// High-performance dimension-independent Star Battle logic solver.
///
/// Employs Minimum Remaining Values (MRV) heuristic with forward constraint propagation
/// and compact flat indexing to solve 8x8 and 10x10 boards efficiently.
class PuzzleSolver {
  const PuzzleSolver();

  /// Solves the puzzle and returns the first valid solution found, or null if none.
  PuzzleSolution? solve(Puzzle puzzle) {
    final solutions = <PuzzleSolution>[];
    _solveInternal(puzzle: puzzle, solutions: solutions, limit: 1);
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
    _solveInternal(puzzle: puzzle, solutions: solutions, limit: limit);
    return solutions.length;
  }

  /// Validates a candidate solution against the puzzle.
  bool validateSolution(Puzzle puzzle, PuzzleSolution solution) {
    return PuzzleValidator.isValidSolution(puzzle, solution);
  }

  void _solveInternal({
    required Puzzle puzzle,
    required List<PuzzleSolution> solutions,
    required int limit,
  }) {
    final size = puzzle.size;
    final regionCount = puzzle.regions.length;

    // A valid puzzle must have exactly `size` regions for `size` pandas (1 per region).
    if (regionCount != size || size <= 0) return;

    // Precompute region cell indices using flat representation: index = row * size + col
    final regionCells = List.generate(regionCount, (_) => <int>[]);
    final regionIndexMap = <int, int>{};
    for (int i = 0; i < regionCount; i++) {
      regionIndexMap[puzzle.regions[i].id] = i;
    }

    for (int r = 0; r < regionCount; r++) {
      for (final pos in puzzle.regions[r].cells) {
        if (pos.row >= 0 && pos.row < size && pos.col >= 0 && pos.col < size) {
          regionCells[r].add(pos.row * size + pos.col);
        }
      }
    }

    // Flat constraint arrays
    final totalCells = size * size;
    final blocked = List.filled(totalCells, 0);
    final regionAssigned = List.filled(regionCount, false);
    final rowAssigned = List.filled(size, false);
    final colAssigned = List.filled(size, false);
    final currentStars = <int>[];

    void backtrack(int starsPlaced) {
      if (solutions.length >= limit) return;
      if (starsPlaced == size) {
        final positions = currentStars.map((idx) => Position(idx ~/ size, idx % size)).toSet();
        solutions.add(PuzzleSolution(pandaPositions: positions));
        return;
      }

      // MRV (Minimum Remaining Values): Select unassigned region with fewest candidates
      int bestRegion = -1;
      int minCandidateCount = 999999;
      List<int>? bestCandidates;

      for (int reg = 0; reg < regionCount; reg++) {
        if (regionAssigned[reg]) continue;

        final candidates = <int>[];
        for (final cellIdx in regionCells[reg]) {
          if (blocked[cellIdx] == 0) {
            candidates.add(cellIdx);
          }
        }

        // Contradiction: This unassigned region has zero legal candidate cells left
        if (candidates.isEmpty) return;

        if (candidates.length < minCandidateCount) {
          minCandidateCount = candidates.length;
          bestRegion = reg;
          bestCandidates = candidates;
          if (minCandidateCount == 1) break; // Forced move
        }
      }

      if (bestRegion == -1 || bestCandidates == null) return;

      regionAssigned[bestRegion] = true;

      for (final cellIdx in bestCandidates) {
        final row = cellIdx ~/ size;
        final col = cellIdx % size;

        rowAssigned[row] = true;
        colAssigned[col] = true;
        currentStars.add(cellIdx);

        // Forward checking: Block row, col, region, and 8 surrounding neighbors
        final newlyBlocked = <int>[];
        void blockCell(int idx) {
          newlyBlocked.add(idx);
          blocked[idx]++;
        }

        // 1. Block row
        final rowOffset = row * size;
        for (int c = 0; c < size; c++) {
          blockCell(rowOffset + c);
        }

        // 2. Block column
        for (int r = 0; r < size; r++) {
          blockCell(r * size + col);
        }

        // 3. Block current region
        for (final cIdx in regionCells[bestRegion]) {
          blockCell(cIdx);
        }

        // 4. Block 8 adjacent neighbors (including diagonal touch)
        for (int dr = -1; dr <= 1; dr++) {
          final nr = row + dr;
          if (nr < 0 || nr >= size) continue;
          final nOffset = nr * size;
          for (int dc = -1; dc <= 1; dc++) {
            final nc = col + dc;
            if (nc >= 0 && nc < size) {
              blockCell(nOffset + nc);
            }
          }
        }

        // Recurse
        backtrack(starsPlaced + 1);

        // Unchoose & backtrack
        currentStars.removeLast();
        for (final idx in newlyBlocked) {
          blocked[idx]--;
        }
        rowAssigned[row] = false;
        colAssigned[col] = false;

        if (solutions.length >= limit) break;
      }

      regionAssigned[bestRegion] = false;
    }

    backtrack(0);
  }
}
