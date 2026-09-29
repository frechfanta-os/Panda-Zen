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

  const Puzzle({
    required this.id,
    required this.seed,
    required this.size,
    required this.difficulty,
    required this.regions,
    required this.solution,
    this.metadata = const {},
  });

  Region? getRegion(int regionId) {
    for (final r in regions) {
      if (r.id == regionId) return r;
    }
    return null;
  }

  Region? getRegionForPosition(Position pos) {
    for (final r in regions) {
      if (r.contains(pos)) return r;
    }
    return null;
  }

  int getRegionId(int row, int col) {
    final reg = getRegionForPosition(Position(row, col));
    return reg?.id ?? 0;
  }
}
