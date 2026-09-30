import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/engine/puzzle_solver.dart';
import 'package:panda_zen/game/engine/puzzle_validator.dart';

void main() {
  group('PuzzleGenerator Tests', () {
    const generator = PuzzleGenerator();
    const solver = PuzzleSolver();

    test('generate(8) returns size 8 with unique solution and valid rules', () {
      final puzzle = generator.generate(size: 8, customSeed: 'test_seed_8x8');
      expect(puzzle.size, equals(8));
      expect(puzzle.regions.length, equals(8));
      expect(puzzle.solution.pandaPositions.length, equals(8));
      expect(solver.hasUniqueSolution(puzzle), isTrue);
      expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);
    });

    test('generate(10) returns size 10 with unique solution and valid rules', () {
      final puzzle = generator.generate(size: 10, customSeed: 'test_seed_10x10');
      expect(puzzle.size, equals(10));
      expect(puzzle.regions.length, equals(10));
      expect(puzzle.solution.pandaPositions.length, equals(10));
      expect(solver.hasUniqueSolution(puzzle), isTrue);
      expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);
    });

    test('REGRESSION TEST: generate(8) and generate(10) NEVER return 5x5 fallback', () {
      // Test over multiple distinct seeds
      for (int i = 0; i < 5; i++) {
        final p8 = generator.generate(size: 8, customSeed: 'regression_test_8_$i');
        expect(p8.size, equals(8));
        expect(p8.size, isNot(equals(5)));
        expect(p8.id, isNot(contains('fallback_5x5')));

        final p10 = generator.generate(size: 10, customSeed: 'regression_test_10_$i');
        expect(p10.size, equals(10));
        expect(p10.size, isNot(equals(5)));
        expect(p10.id, isNot(contains('fallback_5x5')));
      }
    });

    test('Generator is deterministic when given the same seed', () {
      final p1 = generator.generate(size: 8, customSeed: 'deterministic_seed_8');
      final p2 = generator.generate(size: 8, customSeed: 'deterministic_seed_8');

      expect(p1.solution.pandaPositions, equals(p2.solution.pandaPositions));
      expect(p1.regions.length, equals(p2.regions.length));
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          expect(p1.getRegionId(r, c), equals(p2.getRegionId(r, c)));
        }
      }
    });

    test('tryGenerate provides controlled failure instead of corrupting state', () {
      // Invalid board size 2 fails cleanly without throwing or corrupting
      final result = generator.tryGenerate(size: 2);
      expect(result.isSuccess, isFalse);
      expect(result.puzzle, isNull);
      expect(result.errorMessage, contains('Unsupported board size 2'));
    });

    test('generate throws PuzzleGenerationException on controlled failure', () {
      expect(
        () => generator.generate(size: 2),
        throwsA(isA<PuzzleGenerationException>()),
      );
    });
  });
}
