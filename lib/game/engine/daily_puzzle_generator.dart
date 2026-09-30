import '../models/puzzle.dart';
import 'puzzle_generator.dart';

class DailyPuzzleGenerator {
  final PuzzleGenerator generator;

  const DailyPuzzleGenerator({this.generator = const PuzzleGenerator()});

  static String seedForDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'PANDA_ZEN_$y-$m-$d';
  }

  Puzzle generateForDate(DateTime date, {int size = 8}) {
    final seed = seedForDate(date);
    return generator.generate(
      size: size,
      difficulty: PuzzleDifficulty.medium,
      customSeed: seed,
    );
  }
}
