import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/daily_puzzle_generator.dart';
import '../engine/puzzle_generator.dart';
import '../models/puzzle.dart';

final puzzleGeneratorProvider = Provider<PuzzleGenerator>((ref) => const PuzzleGenerator());
final dailyPuzzleGeneratorProvider = Provider<DailyPuzzleGenerator>(
  (ref) => DailyPuzzleGenerator(generator: ref.watch(puzzleGeneratorProvider)),
);

class LevelSpec {
  final int world;
  final int level;

  const LevelSpec(this.world, this.level);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelSpec && runtimeType == other.runtimeType && world == other.world && level == other.level;

  @override
  int get hashCode => world.hashCode ^ level.hashCode;
}

final puzzleForLevelProvider = Provider.family<Puzzle, LevelSpec>((ref, spec) {
  final generator = ref.watch(puzzleGeneratorProvider);
  final size = switch (spec.world) {
    1 => 4,
    2 => 5,
    3 => 5,
    4 => 6,
    5 => 6,
    _ => 7,
  };

  final difficulty = switch (spec.world) {
    1 => PuzzleDifficulty.easy,
    2 => PuzzleDifficulty.easy,
    3 => PuzzleDifficulty.medium,
    4 => PuzzleDifficulty.medium,
    5 => PuzzleDifficulty.hard,
    _ => PuzzleDifficulty.expert,
  };

  return generator.generate(
    size: size,
    difficulty: difficulty,
    customSeed: 'PZ_W${spec.world}_L${spec.level}',
  );
});
