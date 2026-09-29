import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_validator.dart';
import 'package:panda_zen/game/models/cell.dart';
import 'package:panda_zen/game/models/puzzle.dart';
import 'package:panda_zen/game/models/puzzle_solution.dart';
import 'package:panda_zen/game/models/region.dart';
import 'package:panda_zen/assets/region_assets.dart';

void main() {
  group('PuzzleValidator Tests', () {
    late Puzzle testPuzzle;

    setUp(() {
      final regions = [
        Region(
          id: 1,
          visualType: RegionVisualType.bamboo,
          cells: [const Position(0, 0), const Position(0, 1), const Position(1, 0), const Position(1, 1)],
        ),
        Region(
          id: 2,
          visualType: RegionVisualType.water,
          cells: [const Position(0, 2), const Position(0, 3), const Position(1, 2), const Position(1, 3)],
        ),
        Region(
          id: 3,
          visualType: RegionVisualType.stones,
          cells: [const Position(2, 0), const Position(2, 1), const Position(3, 0), const Position(3, 1)],
        ),
        Region(
          id: 4,
          visualType: RegionVisualType.flowers,
          cells: [const Position(2, 2), const Position(2, 3), const Position(3, 2), const Position(3, 3)],
        ),
      ];

      testPuzzle = Puzzle(
        id: 'test_4x4',
        seed: 'test_seed',
        size: 4,
        difficulty: PuzzleDifficulty.easy,
        regions: regions,
        solution: PuzzleSolution(
          pandaPositions: {
            const Position(0, 1),
            const Position(1, 3),
            const Position(2, 0),
            const Position(3, 2),
          },
        ),
      );
    });

    test('Valid solution passes all 4 rules', () {
      final validSolution = PuzzleSolution(
        pandaPositions: {
          const Position(0, 1),
          const Position(1, 3),
          const Position(2, 0),
          const Position(3, 2),
        },
      );
      expect(PuzzleValidator.isValidSolution(testPuzzle, validSolution), isTrue);
    });

    test('Rule 2 violation (two pandas in same row) fails', () {
      final invalidSolution = PuzzleSolution(
        pandaPositions: {
          const Position(0, 1),
          const Position(0, 2), // Same row
          const Position(2, 0),
          const Position(3, 2),
        },
      );
      expect(PuzzleValidator.isValidSolution(testPuzzle, invalidSolution), isFalse);
    });

    test('Rule 3 violation (two pandas in same column) fails', () {
      final invalidSolution = PuzzleSolution(
        pandaPositions: {
          const Position(0, 1),
          const Position(1, 1), // Same column
          const Position(2, 0),
          const Position(3, 2),
        },
      );
      expect(PuzzleValidator.isValidSolution(testPuzzle, invalidSolution), isFalse);
    });

    test('Rule 4 violation (diagonal touch) fails', () {
      final invalidSolution = PuzzleSolution(
        pandaPositions: {
          const Position(0, 0),
          const Position(1, 1), // Diagonally touching
          const Position(2, 3),
          const Position(3, 2),
        },
      );
      expect(PuzzleValidator.isValidSolution(testPuzzle, invalidSolution), isFalse);
    });

    test('Rule 1 violation (two pandas in same region) fails', () {
      final invalidSolution = PuzzleSolution(
        pandaPositions: {
          const Position(0, 0),
          const Position(1, 1), // Both in region 1
          const Position(2, 3),
          const Position(3, 2),
        },
      );
      expect(PuzzleValidator.isValidSolution(testPuzzle, invalidSolution), isFalse);
    });
  });
}
