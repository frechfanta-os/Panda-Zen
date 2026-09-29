import 'cell.dart';

class PuzzleMove {
  final Position position;
  final bool wasPanda;
  final CellState previousState;
  final DateTime timestamp;

  PuzzleMove({
    required this.position,
    required this.wasPanda,
    required this.previousState,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
