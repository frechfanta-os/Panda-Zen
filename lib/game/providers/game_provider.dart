import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import '../../audio/sfx_manager.dart';
import '../../core/storage/save_service.dart';
import '../models/cell.dart';
import '../models/game_session.dart';
import '../models/puzzle.dart';
import '../models/puzzle_move.dart';

class GameNotifier extends StateNotifier<GameSession> {
  final SfxManager _sfx;
  final SaveService _saveService;
  Timer? _timer;

  GameNotifier({
    required Puzzle puzzle,
    SfxManager? sfx,
    SaveService? saveService,
  })  : _sfx = sfx ?? SfxManager(),
        _saveService = saveService ?? SaveService(),
        super(GameSession.initial(puzzle)) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void pauseGame() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  Future<void> tapCell(int row, int col) async {
    if (state.status != GameStatus.playing) return;

    final pos = Position(row, col);
    final currentState = state.cellStates[pos] ?? CellState.hidden;

    // Only hidden or hinted cells can be searched
    if (currentState != CellState.hidden && currentState != CellState.hinted) {
      return;
    }

    final isPanda = state.puzzle.solution.hasPanda(pos);
    final move = PuzzleMove(
      position: pos,
      wasPanda: isPanda,
      previousState: currentState,
    );

    final newCellStates = Map<Position, CellState>.from(state.cellStates);
    final newRevealed = Set<Position>.from(state.revealedCells)..add(pos);
    final newHistory = List<PuzzleMove>.from(state.history)..add(move);

    if (isPanda) {
      newCellStates[pos] = CellState.revealedPanda;
      final newFound = Set<Position>.from(state.foundPandas)..add(pos);
      _sfx.playPandaReveal();

      final completed = newFound.length == state.puzzle.size;
      final newStatus = completed ? GameStatus.completed : GameStatus.playing;

      state = state.copyWith(
        cellStates: newCellStates,
        revealedCells: newRevealed,
        foundPandas: newFound,
        status: newStatus,
        history: newHistory,
      );

      if (completed) {
        _timer?.cancel();
        _sfx.playCorrect();
        final stars = state.calculateStars();

        final (worldId, levelId) = _parseWorldAndLevel(state.puzzle.seed);
        if (worldId != null && levelId != null) {
          await _saveService.recordLevelCompletion(
            worldId: worldId,
            levelId: levelId,
            stars: stars,
            timeSeconds: state.elapsedSeconds,
            mistakes: state.mistakes,
            hintsUsed: state.hintsUsed,
          );
        } else {
          final key = state.puzzle.seed.isNotEmpty ? state.puzzle.seed : state.puzzle.id;
          await _saveService.setLevelStars(key, stars);
          await _saveService.setLevelBestTime(key, state.elapsedSeconds);

          if (state.puzzle.seed.startsWith('PANDA_ZEN_')) {
            final dateKey = state.puzzle.seed.substring('PANDA_ZEN_'.length);
            await _saveService.saveDailyChallenge(
              date: dateKey,
              completed: true,
              time: state.elapsedSeconds,
              mistakes: state.mistakes,
              hints: state.hintsUsed,
            );
          }
        }
      }
    } else {
      newCellStates[pos] = CellState.revealedEmpty;
      _sfx.playInvalidMove();

      final newMistakes = state.mistakes + 1;
      final failed = newMistakes >= state.maxMistakes;
      final newStatus = failed ? GameStatus.failed : GameStatus.playing;

      state = state.copyWith(
        cellStates: newCellStates,
        revealedCells: newRevealed,
        mistakes: newMistakes,
        status: newStatus,
        history: newHistory,
      );

      if (failed) {
        _timer?.cancel();
      }
    }
  }

  void undo() {
    if (state.history.isEmpty || state.status != GameStatus.playing) return;

    final lastMove = state.history.last;
    final newHistory = List<PuzzleMove>.from(state.history)..removeLast();
    final newCellStates = Map<Position, CellState>.from(state.cellStates);
    newCellStates[lastMove.position] = lastMove.previousState;

    final newRevealed = Set<Position>.from(state.revealedCells)..remove(lastMove.position);
    final newFound = Set<Position>.from(state.foundPandas);
    int newMistakes = state.mistakes;

    if (lastMove.wasPanda) {
      newFound.remove(lastMove.position);
    } else {
      if (newMistakes > 0) newMistakes--;
    }

    state = state.copyWith(
      cellStates: newCellStates,
      revealedCells: newRevealed,
      foundPandas: newFound,
      mistakes: newMistakes,
      history: newHistory,
    );
  }

  void restart() {
    _timer?.cancel();
    state = GameSession.initial(state.puzzle, maxMistakes: state.maxMistakes);
    _startTimer();
  }

  void useHint() {
    if (state.status != GameStatus.playing) return;

    // Check if there is already an active hinted cell awaiting discovery
    Position? alreadyHinted;
    for (final entry in state.cellStates.entries) {
      if (entry.value == CellState.hinted) {
        alreadyHinted = entry.key;
        break;
      }
    }

    if (alreadyHinted != null) {
      // Progressively reveal the logically forced panda position
      tapCell(alreadyHinted.row, alreadyHinted.col);
      return;
    }

    // Find an unrevealed panda from the solution
    Position? targetPanda;
    for (final p in state.puzzle.solution.pandaPositions) {
      if (!state.foundPandas.contains(p)) {
        targetPanda = p;
        break;
      }
    }

    if (targetPanda == null) return;

    _sfx.playHint();

    final newStates = Map<Position, CellState>.from(state.cellStates);
    newStates[targetPanda] = CellState.hinted;

    state = state.copyWith(
      cellStates: newStates,
      hintsUsed: state.hintsUsed + 1,
    );
  }

  (int?, int?) _parseWorldAndLevel(String seed) {
    final match = RegExp(r'^PZ_W(\d+)_L(\d+)$').firstMatch(seed);
    if (match != null) {
      final world = int.tryParse(match.group(1)!);
      final level = int.tryParse(match.group(2)!);
      return (world, level);
    }
    return (null, null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProviderFamily =
    StateNotifierProvider.family.autoDispose<GameNotifier, GameSession, Puzzle>(
  (ref, puzzle) => GameNotifier(puzzle: puzzle),
);
