import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_solver.dart';
import 'package:panda_zen/game/models/cell.dart';
import 'package:panda_zen/game/models/puzzle.dart';
import 'package:panda_zen/game/models/puzzle_solution.dart';
import 'package:panda_zen/game/models/region.dart';
import 'package:panda_zen/assets/region_assets.dart';

void main() {
  group('PuzzleSolver Tests', () {
    const solver = PuzzleSolver();

    test('Solves 4x4 unique puzzle and identifies unique solution', () {
      final regions = [
        Region(
          id: 1,
          visualType: RegionVisualType.bamboo,
          cells: [const Position(0, 0), const Position(0, 1), const Position(1, 0), const Position(2, 0)],
        ),
        Region(
          id: 2,
          visualType: RegionVisualType.water,
          cells: [const Position(0, 2), const Position(0, 3), const Position(1, 1), const Position(1, 2)],
        ),
        Region(
          id: 3,
          visualType: RegionVisualType.stones,
          cells: [const Position(1, 3), const Position(2, 2), const Position(2, 3), const Position(3, 3)],
        ),
        Region(
          id: 4,
          visualType: RegionVisualType.flowers,
          cells: [const Position(2, 1), const Position(3, 0), const Position(3, 1), const Position(3, 2)],
        ),
      ];

      final puzzle = Puzzle(
        id: 'test_4x4',
        seed: 'test_seed',
        size: 4,
        difficulty: PuzzleDifficulty.easy,
        regions: regions,
        solution: PuzzleSolution(
          pandaPositions: {
            const Position(0, 2),
            const Position(1, 0),
            const Position(2, 3),
            const Position(3, 1),
          },
        ),
      );

      expect(solver.hasSolution(puzzle), isTrue);
      expect(solver.countSolutions(puzzle), equals(1));
      expect(solver.hasUniqueSolution(puzzle), isTrue);

      final solution = solver.solve(puzzle);
      expect(solution, isNotNull);
      expect(solution!.pandaPositions.length, equals(4));
      expect(solution.pandaPositions.contains(const Position(0, 2)), isTrue);
      expect(solution.pandaPositions.contains(const Position(1, 0)), isTrue);
      expect(solution.pandaPositions.contains(const Position(2, 3)), isTrue);
      expect(solution.pandaPositions.contains(const Position(3, 1)), isTrue);
    });

    test('Detects unsolvable puzzle', () {
      // Create impossible puzzle where a region has 0 candidates
      final regions = [
        Region(
          id: 1,
          visualType: RegionVisualType.bamboo,
          cells: [const Position(0, 0)],
        ),
        Region(
          id: 2,
          visualType: RegionVisualType.bamboo,
          cells: [const Position(0, 1)], // Same row as region 1!
        ),
        Region(
          id: 3,
          visualType: RegionVisualType.water,
          cells: [const Position(1, 0), const Position(1, 1)],
        ),
        Region(
          id: 4,
          visualType: RegionVisualType.stones,
          cells: [
            const Position(2, 0), const Position(2, 1), const Position(2, 2), const Position(2, 3),
            const Position(3, 0), const Position(3, 1), const Position(3, 2), const Position(3, 3),
            const Position(0, 2), const Position(0, 3), const Position(1, 2), const Position(1, 3),
          ],
        ),
      ];

      final unsolvable = Puzzle(
        id: 'impossible',
        seed: 'seed',
        size: 4,
        difficulty: PuzzleDifficulty.easy,
        regions: regions,
        solution: PuzzleSolution(pandaPositions: {}),
      );

      // Region 1 and 2 are both in row 0 of size 1, so row 0 must contain 2 pandas -> impossible!
      expect(solver.hasSolution(unsolvable), isFalse);
      expect(solver.hasUniqueSolution(unsolvable), isFalse);
    });
  });
}
