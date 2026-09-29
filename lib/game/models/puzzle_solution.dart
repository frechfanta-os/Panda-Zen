import 'cell.dart';

class PuzzleSolution {
  final Set<Position> pandaPositions;

  const PuzzleSolution({required this.pandaPositions});

  bool hasPandaAt(int row, int col) {
    return pandaPositions.contains(Position(row, col));
  }

  bool hasPanda(Position pos) {
    return pandaPositions.contains(pos);
  }

  int get count => pandaPositions.length;
}
