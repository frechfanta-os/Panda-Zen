import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/audio/sfx_manager.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/models/cell.dart';
import 'package:panda_zen/game/models/game_session.dart';
import 'package:panda_zen/game/providers/game_provider.dart';

class TestSfxManager implements SfxManager {
  @override
  bool isEnabled = false;

  @override
  double volume = 0.0;

  @override
  Future<void> init() async {}

  @override
  Future<void> playCorrect() async {}

  @override
  Future<void> playHint() async {}

  @override
  Future<void> playInvalidMove() async {}

  @override
  Future<void> playPandaReveal() async {}

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final generator = PuzzleGenerator();

  for (final size in [8, 10]) {
    final sizeLabel = '${size}x$size';

    group('Gameplay Interaction & Discovery Tests ($sizeLabel)', () {
      late GameNotifier notifier;
      late GameSession session;

      setUp(() {
        final puzzle = generator.generate(size: size, customSeed: 'interaction_$size');
        notifier = GameNotifier(puzzle: puzzle, sfx: TestSfxManager());
        session = notifier.state;
      });

      tearDown(() {
        notifier.dispose();
      });

      test('Initial state: all cells hidden and solution is hidden', () {
        expect(session.status, equals(GameStatus.playing));
        expect(session.foundPandas, isEmpty);
        expect(session.revealedCells, isEmpty);
        expect(session.mistakes, equals(0));
        expect(session.puzzle.size, equals(size));

        for (int r = 0; r < size; r++) {
          for (int c = 0; c < size; c++) {
            expect(session.cellStates[Position(r, c)], equals(CellState.hidden));
          }
        }
      });

      test('Tap hidden panda discovers panda and increases progress', () async {
        final targetPanda = session.puzzle.solution.pandaPositions.first;
        await notifier.tapCell(targetPanda.row, targetPanda.col);

        final updated = notifier.state;
        expect(updated.cellStates[targetPanda], equals(CellState.revealedPanda));
        expect(updated.foundPandas.contains(targetPanda), isTrue);
        expect(updated.foundPandas.length, equals(1));
        expect(updated.mistakes, equals(0));
        expect(updated.status, equals(GameStatus.playing));
      });

      test('Tap hidden empty reveals empty, increments mistakes, does not increase progress, does not fail immediately', () async {
        // Find an empty cell
        Position? emptyPos;
        for (int r = 0; r < size; r++) {
          for (int c = 0; c < size; c++) {
            final p = Position(r, c);
            if (!session.puzzle.solution.hasPanda(p)) {
              emptyPos = p;
              break;
            }
          }
          if (emptyPos != null) break;
        }

        expect(emptyPos, isNotNull);
        await notifier.tapCell(emptyPos!.row, emptyPos.col);

        final updated = notifier.state;
        expect(updated.cellStates[emptyPos], equals(CellState.revealedEmpty));
        expect(updated.foundPandas, isEmpty); // Panda progress remains 0
        expect(updated.mistakes, equals(1));
        expect(updated.status, equals(GameStatus.playing)); // Continues playing
      });

      test('Repeated tap on revealed panda does nothing', () async {
        final panda = session.puzzle.solution.pandaPositions.first;
        await notifier.tapCell(panda.row, panda.col);
        expect(notifier.state.foundPandas.length, equals(1));

        // Tap again
        await notifier.tapCell(panda.row, panda.col);
        expect(notifier.state.foundPandas.length, equals(1));
        expect(notifier.state.mistakes, equals(0));
      });

      test('Repeated tap on revealed empty does not consume additional lives', () async {
        Position? emptyPos;
        for (int r = 0; r < size; r++) {
          for (int c = 0; c < size; c++) {
            final p = Position(r, c);
            if (!session.puzzle.solution.hasPanda(p)) {
              emptyPos = p;
              break;
            }
          }
          if (emptyPos != null) break;
        }

        await notifier.tapCell(emptyPos!.row, emptyPos.col);
        expect(notifier.state.mistakes, equals(1));

        // Tapping repeatedly must not consume more lives
        await notifier.tapCell(emptyPos.row, emptyPos.col);
        await notifier.tapCell(emptyPos.row, emptyPos.col);
        expect(notifier.state.mistakes, equals(1));
      });

      test('Level completes when all N pandas discovered, without requiring all empty cells to be tapped', () async {
        final allPandas = session.puzzle.solution.pandaPositions.toList();
        expect(allPandas.length, equals(size));

        for (int i = 0; i < allPandas.length; i++) {
          final p = allPandas[i];
          await notifier.tapCell(p.row, p.col);
          if (i < allPandas.length - 1) {
            expect(notifier.state.status, equals(GameStatus.playing));
          }
        }

        expect(notifier.state.foundPandas.length, equals(size));
        expect(notifier.state.isCompleted, isTrue);
        expect(notifier.state.status, equals(GameStatus.completed));

        // Untouched empty cells remain hidden
        int hiddenCount = 0;
        for (final state in notifier.state.cellStates.values) {
          if (state == CellState.hidden) hiddenCount++;
        }
        expect(hiddenCount, equals(size * size - size));
      });

      test('Reaching maxMistakes transitions to failed state and stops further input', () async {
        final emptyCells = <Position>[];
        for (int r = 0; r < size; r++) {
          for (int c = 0; c < size; c++) {
            final p = Position(r, c);
            if (!session.puzzle.solution.hasPanda(p)) {
              emptyCells.add(p);
            }
          }
        }

        // Tap 3 different empty cells to exhaust 3 lives
        await notifier.tapCell(emptyCells[0].row, emptyCells[0].col);
        expect(notifier.state.status, equals(GameStatus.playing));

        await notifier.tapCell(emptyCells[1].row, emptyCells[1].col);
        expect(notifier.state.status, equals(GameStatus.playing));

        await notifier.tapCell(emptyCells[2].row, emptyCells[2].col);
        expect(notifier.state.status, equals(GameStatus.failed));
        expect(notifier.state.isFailed, isTrue);

        // Subsequent taps ignored
        final panda = session.puzzle.solution.pandaPositions.first;
        await notifier.tapCell(panda.row, panda.col);
        expect(notifier.state.foundPandas, isEmpty);
      });

      test('Hint system highlights candidate panda and progressive hint discovers it', () async {
        expect(notifier.state.hintsUsed, equals(0));

        // First hint highlights an unrevealed candidate cell
        notifier.useHint();
        expect(notifier.state.hintsUsed, equals(1));

        final hintedEntries = notifier.state.cellStates.entries.where((e) => e.value == CellState.hinted).toList();
        expect(hintedEntries.length, equals(1));
        final hintedPos = hintedEntries.first.key;
        expect(session.puzzle.solution.hasPanda(hintedPos), isTrue);

        // Second hint on already-hinted cell reveals the logically forced panda
        notifier.useHint();
        expect(notifier.state.foundPandas.contains(hintedPos), isTrue);
        expect(notifier.state.cellStates[hintedPos], equals(CellState.revealedPanda));
      });

      test('Undo restores empty cell, hidden state, and restores mistake/life count', () async {
        Position? emptyPos;
        for (int r = 0; r < size; r++) {
          for (int c = 0; c < size; c++) {
            final p = Position(r, c);
            if (!session.puzzle.solution.hasPanda(p)) {
              emptyPos = p;
              break;
            }
          }
          if (emptyPos != null) break;
        }

        await notifier.tapCell(emptyPos!.row, emptyPos.col);
        expect(notifier.state.mistakes, equals(1));
        expect(notifier.state.cellStates[emptyPos], equals(CellState.revealedEmpty));

        // Undo
        notifier.undo();
        expect(notifier.state.mistakes, equals(0));
        expect(notifier.state.cellStates[emptyPos], equals(CellState.hidden));
        expect(notifier.state.revealedCells.contains(emptyPos), isFalse);
      });

      test('Undo restores panda discovery, decreases progress, and restores hidden state', () async {
        final panda = session.puzzle.solution.pandaPositions.first;
        await notifier.tapCell(panda.row, panda.col);
        expect(notifier.state.foundPandas.length, equals(1));
        expect(notifier.state.cellStates[panda], equals(CellState.revealedPanda));

        // Undo
        notifier.undo();
        expect(notifier.state.foundPandas.length, equals(0));
        expect(notifier.state.cellStates[panda], equals(CellState.hidden));
        expect(notifier.state.revealedCells.contains(panda), isFalse);
      });

      test('Restart preserves the exact same puzzle and solution while resetting game state', () async {
        final initialPuzzleId = session.puzzle.id;
        final initialSolutionPandas = Set<Position>.from(session.puzzle.solution.pandaPositions);

        // Make moves
        final panda = session.puzzle.solution.pandaPositions.first;
        await notifier.tapCell(panda.row, panda.col);
        notifier.useHint();

        // Restart
        notifier.restart();

        final restarted = notifier.state;
        expect(restarted.puzzle.id, equals(initialPuzzleId));
        expect(restarted.puzzle.solution.pandaPositions, equals(initialSolutionPandas));
        expect(restarted.foundPandas, isEmpty);
        expect(restarted.revealedCells, isEmpty);
        expect(restarted.mistakes, equals(0));
        expect(restarted.hintsUsed, equals(0));
        expect(restarted.status, equals(GameStatus.playing));
      });
    });
  }

  group('Regression Tests — Player Cannot Place or Mutate Solution', () {
    test('Puzzle solution is immutable and cannot be altered by gameplay actions', () {
      final puzzle = generator.generate(size: 8, customSeed: 'immutable_check');
      final originalPositions = Set<Position>.from(puzzle.solution.pandaPositions);

      final notifier = GameNotifier(puzzle: puzzle, sfx: TestSfxManager());
      addTearDown(() => notifier.dispose());

      // Attempt multiple taps and state mutations
      final panda = originalPositions.first;
      notifier.tapCell(panda.row, panda.col);
      notifier.undo();
      notifier.restart();

      // Verify the solution remains identical
      expect(puzzle.solution.pandaPositions, equals(originalPositions));
      expect(notifier.state.puzzle.solution.pandaPositions, equals(originalPositions));
    });
  });
}
