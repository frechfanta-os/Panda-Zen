import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/engine/puzzle_solver.dart';
import 'package:panda_zen/game/engine/puzzle_validator.dart';

void main() {
  group('PuzzleGenerator Tests', () {
    const generator = PuzzleGenerator();
    const solver = PuzzleSolver();

    test('Generates valid 4x4 puzzle with unique solution', () {
      final puzzle = generator.generate(size: 4, customSeed: 'test_seed_4x4');
      expect(puzzle.size, equals(4));
      expect(puzzle.regions.length, equals(4));
      expect(solver.hasUniqueSolution(puzzle), isTrue);
      expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);
    });

    test('Generates valid 5x5 puzzle with unique solution', () {
      final puzzle = generator.generate(size: 5, customSeed: 'test_seed_5x5');
      expect(puzzle.size, equals(5));
      expect(puzzle.regions.length, equals(5));
      expect(solver.hasUniqueSolution(puzzle), isTrue);
      expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);
    });

    test('Generator is deterministic when given the same seed', () {
      final p1 = generator.generate(size: 4, customSeed: 'deterministic_seed');
      final p2 = generator.generate(size: 4, customSeed: 'deterministic_seed');

      expect(p1.solution.pandaPositions, equals(p2.solution.pandaPositions));
      expect(p1.regions.length, equals(p2.regions.length));
    });
  });
}
