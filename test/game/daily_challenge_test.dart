import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panda_zen/core/storage/save_service.dart';
import 'package:panda_zen/game/engine/daily_puzzle_generator.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/engine/puzzle_solver.dart';
import 'package:panda_zen/game/engine/puzzle_validator.dart';
import 'package:panda_zen/game/models/game_session.dart';
import 'package:panda_zen/game/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SaveService saveService;
  const generator = PuzzleGenerator();
  const dailyGenerator = DailyPuzzleGenerator(generator: generator);
  const solver = PuzzleSolver();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    saveService = SaveService();
    saveService.resetForTesting();
    await saveService.init();
  });

  group('DAILY CHALLENGE DETERMINISM & QUALITY TESTS', () {
    test('Same date always generates identical puzzle', () {
      final date = DateTime(2026, 9, 29);
      final puzzle1 = dailyGenerator.generateForDate(date);
      final puzzle2 = dailyGenerator.generateForDate(date);

      expect(puzzle1.size, equals(puzzle2.size));
      expect(puzzle1.size, equals(8));
      expect(puzzle1.seed, equals(puzzle2.seed));
      expect(puzzle1.seed, equals('PANDA_ZEN_2026-09-29'));
      expect(puzzle1.regions.length, equals(puzzle2.regions.length));
      expect(puzzle1.solution.pandaPositions, equals(puzzle2.solution.pandaPositions));

      for (int i = 0; i < puzzle1.regions.length; i++) {
        expect(puzzle1.regions[i].cells, equals(puzzle2.regions[i].cells));
      }
    });

    test('Different dates generate independent deterministic puzzles', () {
      final dateA = DateTime(2026, 9, 29);
      final dateB = DateTime(2026, 9, 30);

      final puzzleA = dailyGenerator.generateForDate(dateA);
      final puzzleB = dailyGenerator.generateForDate(dateB);

      expect(puzzleA.seed, equals('PANDA_ZEN_2026-09-29'));
      expect(puzzleB.seed, equals('PANDA_ZEN_2026-09-30'));
      expect(puzzleA.seed, isNot(equals(puzzleB.seed)));

      // Both independently satisfy validity
      expect(PuzzleValidator.isValidSolution(puzzleA, puzzleA.solution), isTrue);
      expect(PuzzleValidator.isValidSolution(puzzleB, puzzleB.solution), isTrue);
    });

    test('Daily challenge seed format strictly adheres to PANDA_ZEN_YYYY-MM-DD', () {
      final date = DateTime(2026, 1, 5);
      final seed = DailyPuzzleGenerator.seedForDate(date);
      expect(seed, equals('PANDA_ZEN_2026-01-05'));
    });

    test('Every generated Daily Challenge satisfies core Panda Zen rules and has unique solution', () {
      final dates = [
        DateTime(2026, 1, 1),
        DateTime(2026, 6, 15),
        DateTime(2026, 9, 29),
        DateTime(2026, 12, 31),
      ];

      for (final date in dates) {
        final puzzle = dailyGenerator.generateForDate(date);

        // Core rules
        expect(puzzle.size, equals(8));
        expect(puzzle.regions.length, equals(8));
        expect(puzzle.solution.pandaPositions.length, equals(8));
        expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);
        expect(solver.hasSolution(puzzle), isTrue);
        expect(solver.hasUniqueSolution(puzzle), isTrue);
      }
    });
  });

  group('DAILY PERSISTENCE, REPLAY & DATE TRANSITION TESTS', () {
    test('Daily completion before, after, and post-restart persistence', () async {
      final date = DateTime(2026, 9, 29);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Before completion
      expect(saveService.dailyChallengeCompleted, isFalse);
      expect(saveService.dailyChallengeDate, isNull);

      // Save completion
      await saveService.saveDailyChallenge(
        date: dateKey,
        completed: true,
        time: 48,
        mistakes: 1,
        hints: 0,
      );

      expect(saveService.dailyChallengeDate, equals(dateKey));
      expect(saveService.dailyChallengeCompleted, isTrue);
      expect(saveService.dailyChallengeTime, equals(48));
      expect(saveService.dailyChallengeMistakes, equals(1));
      expect(saveService.dailyChallengeHints, equals(0));

      // Simulate app restart
      saveService.resetForTesting();
      final freshSave = SaveService();
      await freshSave.init();

      expect(freshSave.dailyChallengeDate, equals(dateKey));
      expect(freshSave.dailyChallengeCompleted, isTrue);
      expect(freshSave.dailyChallengeTime, equals(48));
      expect(freshSave.dailyChallengeMistakes, equals(1));
      expect(freshSave.dailyChallengeHints, equals(0));
    });

    test('Daily date transition: Day A completion does not mark Day B as completed', () async {
      const dayA = '2026-09-29';
      const dayB = '2026-09-30';

      // Complete Day A
      await saveService.saveDailyChallenge(
        date: dayA,
        completed: true,
        time: 50,
        mistakes: 0,
        hints: 0,
      );

      // Check for Day A
      final isDayACompleted = saveService.dailyChallengeDate == dayA && saveService.dailyChallengeCompleted;
      expect(isDayACompleted, isTrue);

      // Check for Day B: starts fresh as not completed
      final isDayBCompleted = saveService.dailyChallengeDate == dayB && saveService.dailyChallengeCompleted;
      expect(isDayBCompleted, isFalse);
    });

    test('Daily challenge gameplay loop completes and persists via GameNotifier', () async {
      final date = DateTime(2026, 9, 29);
      final puzzle = dailyGenerator.generateForDate(date);

      final notifier = GameNotifier(
        puzzle: puzzle,
        saveService: saveService,
      );

      expect(notifier.state.status, equals(GameStatus.playing));

      // Reveal all pandas
      for (final p in puzzle.solution.pandaPositions) {
        await notifier.tapCell(p.row, p.col);
      }

      expect(notifier.state.status, equals(GameStatus.completed));
      expect(saveService.dailyChallengeDate, equals('2026-09-29'));
      expect(saveService.dailyChallengeCompleted, isTrue);
    });
  });

  group('BATCH PUZZLE QUALITY ASSURANCE (100 Standard, 100 Advanced, 100 Daily)', () {
    test('100 Standard (8x8) puzzles batch test', () {
      final times = <double>[];
      int successCount = 0;
      int uniquenessFailures = 0;

      for (int i = 0; i < 100; i++) {
        final sw = Stopwatch()..start();
        final puzzle = generator.generate(
          size: 8,
          customSeed: 'QA_BATCH_8x8_$i',
        );
        sw.stop();
        times.add(sw.elapsedMicroseconds / 1000.0);

        expect(puzzle.size, equals(8));
        expect(puzzle.regions.length, equals(8));
        expect(puzzle.solution.pandaPositions.length, equals(8));
        expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);

        if (solver.hasUniqueSolution(puzzle)) {
          successCount++;
        } else {
          uniquenessFailures++;
        }
      }

      times.sort();
      final minTime = times.first;
      final maxTime = times.last;
      final avgTime = times.reduce((a, b) => a + b) / times.length;

      expect(successCount, equals(100));
      expect(uniquenessFailures, equals(0));
      // Print metrics for the report
      // ignore: avoid_print
      print('Batch 8x8 (100): avg=${avgTime.toStringAsFixed(3)}ms, min=${minTime.toStringAsFixed(3)}ms, max=${maxTime.toStringAsFixed(3)}ms');
    });

    test('100 Advanced (10x10) puzzles batch test', () {
      final times = <double>[];
      int successCount = 0;
      int uniquenessFailures = 0;

      for (int i = 0; i < 100; i++) {
        final sw = Stopwatch()..start();
        final puzzle = generator.generate(
          size: 10,
          customSeed: 'QA_BATCH_10x10_$i',
        );
        sw.stop();
        times.add(sw.elapsedMicroseconds / 1000.0);

        expect(puzzle.size, equals(10));
        expect(puzzle.regions.length, equals(10));
        expect(puzzle.solution.pandaPositions.length, equals(10));
        expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);

        if (solver.hasUniqueSolution(puzzle)) {
          successCount++;
        } else {
          uniquenessFailures++;
        }
      }

      times.sort();
      final minTime = times.first;
      final maxTime = times.last;
      final avgTime = times.reduce((a, b) => a + b) / times.length;

      expect(successCount, equals(100));
      expect(uniquenessFailures, equals(0));
      // Print metrics for the report
      // ignore: avoid_print
      print('Batch 10x10 (100): avg=${avgTime.toStringAsFixed(3)}ms, min=${minTime.toStringAsFixed(3)}ms, max=${maxTime.toStringAsFixed(3)}ms');
    });

    test('100 Daily-seeded puzzles batch test', () {
      final times = <double>[];
      int successCount = 0;
      int uniquenessFailures = 0;
      final baseDate = DateTime(2026, 1, 1);

      for (int i = 0; i < 100; i++) {
        final date = baseDate.add(Duration(days: i));
        final sw = Stopwatch()..start();
        final puzzle = dailyGenerator.generateForDate(date);
        sw.stop();
        times.add(sw.elapsedMicroseconds / 1000.0);

        expect(puzzle.size, equals(8));
        expect(puzzle.regions.length, equals(8));
        expect(puzzle.solution.pandaPositions.length, equals(8));
        expect(PuzzleValidator.isValidSolution(puzzle, puzzle.solution), isTrue);

        if (solver.hasUniqueSolution(puzzle)) {
          successCount++;
        } else {
          uniquenessFailures++;
        }
      }

      times.sort();
      final minTime = times.first;
      final maxTime = times.last;
      final avgTime = times.reduce((a, b) => a + b) / times.length;

      expect(successCount, equals(100));
      expect(uniquenessFailures, equals(0));
      // Print metrics for the report
      // ignore: avoid_print
      print('Batch Daily (100): avg=${avgTime.toStringAsFixed(3)}ms, min=${minTime.toStringAsFixed(3)}ms, max=${maxTime.toStringAsFixed(3)}ms');
    });
  });
}
