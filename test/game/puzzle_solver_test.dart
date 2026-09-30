import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/engine/puzzle_solver.dart';
import 'package:panda_zen/game/models/cell.dart';
import 'package:panda_zen/game/models/puzzle.dart';
import 'package:panda_zen/game/models/puzzle_solution.dart';
import 'package:panda_zen/game/models/region.dart';
import 'package:panda_zen/assets/region_assets.dart';

void main() {
  group('PuzzleSolver 8x8 Tests', () {
    const solver = PuzzleSolver();
    const generator = PuzzleGenerator();

    test('8x8 unique puzzle solves and has unique solution', () {
      final puzzle = generator.generate(size: 8, customSeed: 'solver_test_unique_8');
      expect(puzzle.size, equals(8));
      expect(solver.hasSolution(puzzle), isTrue);
      expect(solver.hasUniqueSolution(puzzle), isTrue);
      expect(solver.countSolutions(puzzle), equals(1));

      final solution = solver.solve(puzzle);
      expect(solution, isNotNull);
      expect(solution!.pandaPositions.length, equals(8));
      expect(solver.validateSolution(puzzle, solution), isTrue);
    });

    test('8x8 unsolvable puzzle returns no solution', () {
      // Create puzzle with conflicting single-cell regions
      final regions = [
        Region(id: 1, visualType: RegionVisualType.bamboo, cells: [const Position(0, 0)]),
        Region(id: 2, visualType: RegionVisualType.water, cells: [const Position(0, 1)]), // Same row!
        for (int r = 2; r < 8; r++)
          Region(
            id: r + 1,
            visualType: RegionVisualType.stones,
            cells: List.generate(8, (c) => Position(r, c)),
          ),
      ];

      final impossible = Puzzle(
        id: 'unsolvable_8x8',
        seed: 'impossible',
        size: 8,
        difficulty: PuzzleDifficulty.hard,
        regions: regions,
        solution: const PuzzleSolution(pandaPositions: {}),
      );

      expect(solver.hasSolution(impossible), isFalse);
      expect(solver.hasUniqueSolution(impossible), isFalse);
      expect(solver.countSolutions(impossible), equals(0));
      expect(solver.solve(impossible), isNull);
    });

    test('8x8 puzzle with multiple solutions detected', () {
      // 8 full row regions allow independent column placements in non-touching permutations
      final regions = List.generate(8, (r) {
        return Region(
          id: r + 1,
          visualType: RegionVisualType.bamboo,
          cells: List.generate(8, (c) => Position(r, c)),
        );
      });

      final multiPuzzle = Puzzle(
        id: 'multi_8x8',
        seed: 'multi',
        size: 8,
        difficulty: PuzzleDifficulty.medium,
        regions: regions,
        solution: const PuzzleSolution(pandaPositions: {}),
      );

      final count = solver.countSolutions(multiPuzzle, limit: 3);
      expect(count, greaterThan(1));
      expect(solver.hasUniqueSolution(multiPuzzle), isFalse);
    });
  });

  group('PuzzleSolver 10x10 Tests', () {
    const solver = PuzzleSolver();
    const generator = PuzzleGenerator();

    test('10x10 unique puzzle solves and has unique solution', () {
      final puzzle = generator.generate(size: 10, customSeed: 'solver_test_unique_10');
      expect(puzzle.size, equals(10));
      expect(solver.hasSolution(puzzle), isTrue);
      expect(solver.hasUniqueSolution(puzzle), isTrue);
      expect(solver.countSolutions(puzzle), equals(1));

      final solution = solver.solve(puzzle);
      expect(solution, isNotNull);
      expect(solution!.pandaPositions.length, equals(10));
      expect(solver.validateSolution(puzzle, solution), isTrue);
    });

    test('10x10 unsolvable puzzle returns no solution', () {
      final regions = [
        Region(id: 1, visualType: RegionVisualType.bamboo, cells: [const Position(0, 0)]),
        Region(id: 2, visualType: RegionVisualType.water, cells: [const Position(0, 1)]),
        for (int r = 2; r < 10; r++)
          Region(
            id: r + 1,
            visualType: RegionVisualType.stones,
            cells: List.generate(10, (c) => Position(r, c)),
          ),
      ];

      final impossible = Puzzle(
        id: 'unsolvable_10x10',
        seed: 'impossible',
        size: 10,
        difficulty: PuzzleDifficulty.expert,
        regions: regions,
        solution: const PuzzleSolution(pandaPositions: {}),
      );

      expect(solver.hasSolution(impossible), isFalse);
      expect(solver.hasUniqueSolution(impossible), isFalse);
      expect(solver.countSolutions(impossible), equals(0));
      expect(solver.solve(impossible), isNull);
    });

    test('10x10 puzzle with multiple solutions detected', () {
      final regions = List.generate(10, (r) {
        return Region(
          id: r + 1,
          visualType: RegionVisualType.bamboo,
          cells: List.generate(10, (c) => Position(r, c)),
        );
      });

      final multiPuzzle = Puzzle(
        id: 'multi_10x10',
        seed: 'multi',
        size: 10,
        difficulty: PuzzleDifficulty.expert,
        regions: regions,
        solution: const PuzzleSolution(pandaPositions: {}),
      );

      final count = solver.countSolutions(multiPuzzle, limit: 3);
      expect(count, greaterThan(1));
      expect(solver.hasUniqueSolution(multiPuzzle), isFalse);
    });
  });
}
