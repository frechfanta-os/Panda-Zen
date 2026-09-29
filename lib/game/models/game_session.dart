import 'cell.dart';
import 'puzzle.dart';
import 'puzzle_move.dart';

enum GameStatus {
  playing,
  paused,
  completed,
  failed,
}

class GameSession {
  final Puzzle puzzle;
  final Map<Position, CellState> cellStates;
  final Set<Position> revealedCells;
  final Set<Position> foundPandas;
  final int mistakes;
  final int maxMistakes;
  final int hintsUsed;
  final int elapsedSeconds;
  final GameStatus status;
  final List<PuzzleMove> history;

  const GameSession({
    required this.puzzle,
    required this.cellStates,
    required this.revealedCells,
    required this.foundPandas,
    this.mistakes = 0,
    this.maxMistakes = 3,
    this.hintsUsed = 0,
    this.elapsedSeconds = 0,
    this.status = GameStatus.playing,
    this.history = const [],
  });

  factory GameSession.initial(Puzzle puzzle, {int maxMistakes = 3}) {
    final states = <Position, CellState>{};
    for (int r = 0; r < puzzle.size; r++) {
      for (int c = 0; c < puzzle.size; c++) {
        states[Position(r, c)] = CellState.hidden;
      }
    }
    return GameSession(
      puzzle: puzzle,
      cellStates: states,
      revealedCells: {},
      foundPandas: {},
      mistakes: 0,
      maxMistakes: maxMistakes,
      hintsUsed: 0,
      elapsedSeconds: 0,
      status: GameStatus.playing,
      history: [],
    );
  }

  bool get isCompleted => foundPandas.length == puzzle.size;
  bool get isFailed => mistakes >= maxMistakes;

  int calculateStars() {
    if (!isCompleted) return 0;
    if (mistakes == 0 && hintsUsed == 0) return 3;
    if (mistakes <= 1 && hintsUsed <= 1) return 2;
    return 1;
  }

  GameSession copyWith({
    Puzzle? puzzle,
    Map<Position, CellState>? cellStates,
    Set<Position> ? revealedCells,
    Set<Position>? foundPandas,
    int? mistakes,
    int? maxMistakes,
    int? hintsUsed,
    int? elapsedSeconds,
    GameStatus? status,
    List<PuzzleMove>? history,
  }) {
    return GameSession(
      puzzle: puzzle ?? this.puzzle,
      cellStates: cellStates ?? Map.from(this.cellStates),
      revealedCells: revealedCells ?? Set.from(this.revealedCells),
      foundPandas: foundPandas ?? Set.from(this.foundPandas),
      mistakes: mistakes ?? this.mistakes,
      maxMistakes: maxMistakes ?? this.maxMistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
      history: history ?? List.from(this.history),
    );
  }
}
