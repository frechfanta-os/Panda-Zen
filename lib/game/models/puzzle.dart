import 'cell.dart';
import 'puzzle_solution.dart';
import 'region.dart';

enum PuzzleDifficulty {
  easy,
  medium,
  hard,
  expert,
}

class Puzzle {
  final String id;
  final String seed;
  final int size;
  final PuzzleDifficulty difficulty;
  final List<Region> regions;
  final PuzzleSolution solution;
  final Map<String, dynamic> metadata;

  // Precomputed O(1) lookups
  final List<int> _regionGrid;
  final Map<int, Region> _regionMap;

  Puzzle({
    required this.id,
    required this.seed,
    required this.size,
    required this.difficulty,
    required this.regions,
    required this.solution,
    this.metadata = const {},
  })  : _regionGrid = List.filled(size * size, 0),
        _regionMap = {for (final r in regions) r.id: r} {
    for (final r in regions) {
      for (final cell in r.cells) {
        if (cell.row >= 0 && cell.row < size && cell.col >= 0 && cell.col < size) {
          _regionGrid[cell.row * size + cell.col] = r.id;
        }
      }
    }
  }

  /// O(1) lookup of Region by its ID
  Region? getRegion(int regionId) => _regionMap[regionId];

  /// O(1) lookup of Region for a Position
  Region? getRegionForPosition(Position pos) {
    final regId = getRegionId(pos.row, pos.col);
    return regId != 0 ? _regionMap[regId] : null;
  }

  /// O(1) lookup of Region ID by row and column
  int getRegionId(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) return 0;
    return _regionGrid[row * size + col];
  }
}
