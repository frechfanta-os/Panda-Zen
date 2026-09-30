import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_validator.dart';
import 'package:panda_zen/game/models/cell.dart';
import 'package:panda_zen/game/models/puzzle.dart';
import 'package:panda_zen/game/models/puzzle_solution.dart';
import 'package:panda_zen/game/models/region.dart';
import 'package:panda_zen/assets/region_assets.dart';

void main() {
  group('PuzzleValidator 8x8 Tests', () {
    late Puzzle puzzle8x8;
    late Set<Position> valid8x8Positions;

    setUp(() {
      valid8x8Positions = {
        const Position(0, 2),
        const Position(1, 5),
        const Position(2, 1),
        const Position(3, 7),
        const Position(4, 4),
        const Position(5, 0),
        const Position(6, 3),
        const Position(7, 6),
      };

      // Create 8 regions (rows 0..7 as regions)
      final regions = List.generate(8, (r) {
        return Region(
          id: r + 1,
          visualType: RegionVisualType.bamboo,
          cells: List.generate(8, (c) => Position(r, c)),
        );
      });

      puzzle8x8 = Puzzle(
        id: 'test_8x8',
        seed: 'seed_8x8',
        size: 8,
        difficulty: PuzzleDifficulty.medium,
        regions: regions,
        solution: PuzzleSolution(pandaPositions: valid8x8Positions),
      );
    });

    test('8x8 valid solution passes all rules', () {
      final solution = PuzzleSolution(pandaPositions: valid8x8Positions);
      expect(PuzzleValidator.isValidSolution(puzzle8x8, solution), isTrue);
    });

    test('8x8 invalid solution with wrong count fails', () {
      final solution = PuzzleSolution(pandaPositions: valid8x8Positions.take(7).toSet());
      expect(PuzzleValidator.isValidSolution(puzzle8x8, solution), isFalse);
    });

    test('8x8 row constraint violation fails', () {
      final invalid = Set<Position>.from(valid8x8Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(0, 5)); // Two pandas in row 0
      expect(PuzzleValidator.isValidSolution(puzzle8x8, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });

    test('8x8 column constraint violation fails', () {
      final invalid = Set<Position>.from(valid8x8Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(1, 2)); // Two pandas in col 2
      expect(PuzzleValidator.isValidSolution(puzzle8x8, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });

    test('8x8 diagonal constraint violation fails', () {
      final invalid = Set<Position>.from(valid8x8Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(1, 3)); // Touches (0,2) diagonally: diff (1, 1)
      expect(PuzzleValidator.isValidSolution(puzzle8x8, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });

    test('8x8 region constraint violation fails', () {
      final invalid = Set<Position>.from(valid8x8Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(0, 7)); // Both in region 1 (row 0)
      expect(PuzzleValidator.isValidSolution(puzzle8x8, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });
  });

  group('PuzzleValidator 10x10 Tests', () {
    late Puzzle puzzle10x10;
    late Set<Position> valid10x10Positions;

    setUp(() {
      valid10x10Positions = {
        const Position(0, 2),
        const Position(1, 5),
        const Position(2, 1),
        const Position(3, 7),
        const Position(4, 4),
        const Position(5, 9),
        const Position(6, 0),
        const Position(7, 3),
        const Position(8, 6),
        const Position(9, 8),
      };

      // 10 regions (each row is a region)
      final regions = List.generate(10, (r) {
        return Region(
          id: r + 1,
          visualType: RegionVisualType.bamboo,
          cells: List.generate(10, (c) => Position(r, c)),
        );
      });

      puzzle10x10 = Puzzle(
        id: 'test_10x10',
        seed: 'seed_10x10',
        size: 10,
        difficulty: PuzzleDifficulty.expert,
        regions: regions,
        solution: PuzzleSolution(pandaPositions: valid10x10Positions),
      );
    });

    test('10x10 valid solution passes all rules', () {
      final solution = PuzzleSolution(pandaPositions: valid10x10Positions);
      expect(PuzzleValidator.isValidSolution(puzzle10x10, solution), isTrue);
    });

    test('10x10 invalid solution with wrong count fails', () {
      final solution = PuzzleSolution(pandaPositions: valid10x10Positions.take(9).toSet());
      expect(PuzzleValidator.isValidSolution(puzzle10x10, solution), isFalse);
    });

    test('10x10 row constraint violation fails', () {
      final invalid = Set<Position>.from(valid10x10Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(0, 5)); // Two pandas in row 0
      expect(PuzzleValidator.isValidSolution(puzzle10x10, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });

    test('10x10 column constraint violation fails', () {
      final invalid = Set<Position>.from(valid10x10Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(1, 2)); // Two pandas in col 2
      expect(PuzzleValidator.isValidSolution(puzzle10x10, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });

    test('10x10 diagonal constraint violation fails', () {
      final invalid = Set<Position>.from(valid10x10Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(1, 3)); // Touches (0,2) diagonally
      expect(PuzzleValidator.isValidSolution(puzzle10x10, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });

    test('10x10 region constraint violation fails', () {
      final invalid = Set<Position>.from(valid10x10Positions)
        ..remove(const Position(1, 5))
        ..add(const Position(0, 7)); // Both in region 1
      expect(PuzzleValidator.isValidSolution(puzzle10x10, PuzzleSolution(pandaPositions: invalid)), isFalse);
    });
  });
}
