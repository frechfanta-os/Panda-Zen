import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panda_zen/core/storage/save_service.dart';
import 'package:panda_zen/game/models/game_session.dart';
import 'package:panda_zen/game/models/progression_models.dart';
import 'package:panda_zen/game/providers/game_provider.dart';
import 'package:panda_zen/game/providers/progression_provider.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/providers/puzzle_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SaveService saveService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    saveService = SaveService();
    saveService.resetForTesting();
    await saveService.init();
  });

  group('LEVEL PROGRESSION TESTS', () {
    test('Initial level 1 is available and subsequent levels are locked', () {
      expect(saveService.getUnlockedLevel(1), equals(1));

      final level1 = saveService.getLevelRecord(1, 1);
      expect(level1.state, equals(LevelState.available));
      expect(level1.isLocked, isFalse);
      expect(level1.isAvailable, isTrue);

      for (int lvl = 2; lvl <= 30; lvl++) {
        final record = saveService.getLevelRecord(1, lvl);
        expect(record.state, equals(LevelState.locked));
        expect(record.isLocked, isTrue);
      }
    });

    test('Completing level 1 unlocks level 2 and keeps level 3+ locked', () async {
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 1,
        stars: 3,
        timeSeconds: 45,
        mistakes: 0,
        hintsUsed: 0,
      );

      expect(saveService.getUnlockedLevel(1), equals(2));

      final level1 = saveService.getLevelRecord(1, 1);
      expect(level1.state, equals(LevelState.mastered));
      expect(level1.isCompleted, isTrue);
      expect(level1.stars, equals(3));

      final level2 = saveService.getLevelRecord(1, 2);
      expect(level2.state, equals(LevelState.available));
      expect(level2.isLocked, isFalse);

      final level3 = saveService.getLevelRecord(1, 3);
      expect(level3.state, equals(LevelState.locked));
      expect(level3.isLocked, isTrue);
    });

    test('Progression notifier respects bounds and does not exceed level 30', () {
      final container = ProviderContainer(
        overrides: [
          saveServiceProvider.overrideWithValue(saveService),
        ],
      );
      final notifier = container.read(progressionProvider.notifier);

      notifier.unlockNextLevel(1, 1);
      expect(saveService.getUnlockedLevel(1), equals(2));

      notifier.unlockNextLevel(1, 29);
      expect(saveService.getUnlockedLevel(1), equals(30));

      // Attempting to unlock beyond 30 must not overflow
      notifier.unlockNextLevel(1, 30);
      expect(saveService.getUnlockedLevel(1), equals(30));

      container.dispose();
    });
  });

  group('STAR CALCULATION & REPLAY TESTS', () {
    test('Star calculation: 3 stars requires 0 mistakes and 0 hints', () {
      final puzzle = const PuzzleGenerator().generate(size: 8);
      var session = GameSession.initial(puzzle);

      // Empty session is not completed
      expect(session.calculateStars(), equals(0));

      // Discovered all pandas with 0 mistakes, 0 hints
      session = session.copyWith(
        foundPandas: puzzle.solution.pandaPositions,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(session.isCompleted, isTrue);
      expect(session.calculateStars(), equals(3));

      // 1 mistake, 0 hints -> 2 stars
      session = session.copyWith(mistakes: 1, hintsUsed: 0);
      expect(session.calculateStars(), equals(2));

      // 0 mistakes, 1 hint -> 2 stars
      session = session.copyWith(mistakes: 0, hintsUsed: 1);
      expect(session.calculateStars(), equals(2));

      // 1 mistake, 1 hint -> 2 stars
      session = session.copyWith(mistakes: 1, hintsUsed: 1);
      expect(session.calculateStars(), equals(2));

      // 2 mistakes -> 1 star
      session = session.copyWith(mistakes: 2, hintsUsed: 0);
      expect(session.calculateStars(), equals(1));

      // 2 hints -> 1 star
      session = session.copyWith(mistakes: 0, hintsUsed: 2);
      expect(session.calculateStars(), equals(1));
    });

    test('Replay cannot downgrade best stars', () async {
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 5,
        stars: 3,
        timeSeconds: 50,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars('PZ_W1_L5'), equals(3));

      // Replaying with 1 star must not downgrade the saved 3 stars
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 5,
        stars: 1,
        timeSeconds: 65,
        mistakes: 2,
        hintsUsed: 1,
      );
      expect(saveService.getLevelStars('PZ_W1_L5'), equals(3));
    });

    test('Replay can improve stars from 1 or 2 to 3', () async {
      await saveService.recordLevelCompletion(
        worldId: 2,
        levelId: 3,
        stars: 1,
        timeSeconds: 90,
        mistakes: 2,
        hintsUsed: 2,
      );
      expect(saveService.getLevelStars('PZ_W2_L3'), equals(1));

      // Replay earning 2 stars updates saved stars
      await saveService.recordLevelCompletion(
        worldId: 2,
        levelId: 3,
        stars: 2,
        timeSeconds: 70,
        mistakes: 1,
        hintsUsed: 1,
      );
      expect(saveService.getLevelStars('PZ_W2_L3'), equals(2));

      // Replay earning 3 stars updates saved stars to mastered
      await saveService.recordLevelCompletion(
        worldId: 2,
        levelId: 3,
        stars: 3,
        timeSeconds: 40,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars('PZ_W2_L3'), equals(3));
      final record = saveService.getLevelRecord(2, 3);
      expect(record.state, equals(LevelState.mastered));
    });
  });

  group('BEST TIME & STATS TESTS', () {
    test('First completion saves time, faster replay improves, slower replay does not overwrite', () async {
      // First completion: 45 seconds
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 2,
        stars: 2,
        timeSeconds: 45,
        mistakes: 1,
        hintsUsed: 0,
      );
      expect(saveService.getLevelBestTime('PZ_W1_L2'), equals(45));

      // Slower replay: 60 seconds (must keep 45)
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 2,
        stars: 2,
        timeSeconds: 60,
        mistakes: 1,
        hintsUsed: 0,
      );
      expect(saveService.getLevelBestTime('PZ_W1_L2'), equals(45));

      // Faster replay: 32 seconds (must update to 32)
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 2,
        stars: 3,
        timeSeconds: 32,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(saveService.getLevelBestTime('PZ_W1_L2'), equals(32));
    });

    test('Completion count and best mistakes/hints are tracked accurately', () async {
      await saveService.recordLevelCompletion(
        worldId: 3,
        levelId: 1,
        stars: 1,
        timeSeconds: 80,
        mistakes: 2,
        hintsUsed: 3,
      );
      expect(saveService.getLevelCompletionCount('PZ_W3_L1'), equals(1));
      expect(saveService.getLevelBestMistakes('PZ_W3_L1'), equals(2));
      expect(saveService.getLevelBestHints('PZ_W3_L1'), equals(3));

      // Replay with fewer mistakes and fewer hints
      await saveService.recordLevelCompletion(
        worldId: 3,
        levelId: 1,
        stars: 3,
        timeSeconds: 42,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(saveService.getLevelCompletionCount('PZ_W3_L1'), equals(2));
      expect(saveService.getLevelBestMistakes('PZ_W3_L1'), equals(0));
      expect(saveService.getLevelBestHints('PZ_W3_L1'), equals(0));
    });
  });

  group('PERSISTENCE & RESTART SIMULATION TESTS', () {
    test('Data survives simulated app restart across SaveService instances', () async {
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 1,
        stars: 3,
        timeSeconds: 28,
        mistakes: 0,
        hintsUsed: 0,
      );
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 2,
        stars: 2,
        timeSeconds: 52,
        mistakes: 1,
        hintsUsed: 1,
      );
      await saveService.setCurrentWorld(3);

      // Simulate full app restart
      saveService.resetForTesting();
      final freshSaveService = SaveService();
      await freshSaveService.init();

      expect(freshSaveService.currentWorld, equals(3));
      expect(freshSaveService.getUnlockedLevel(1), equals(3));
      expect(freshSaveService.getLevelStars('PZ_W1_L1'), equals(3));
      expect(freshSaveService.getLevelBestTime('PZ_W1_L1'), equals(28));
      expect(freshSaveService.getLevelStars('PZ_W1_L2'), equals(2));
      expect(freshSaveService.getLevelBestTime('PZ_W1_L2'), equals(52));
      expect(freshSaveService.getTotalStars(), equals(5));
      expect(freshSaveService.getTotalSolved(), equals(2));
    });

    test('Missing data recovers to safe defaults without crashing', () async {
      SharedPreferences.setMockInitialValues({});
      saveService.resetForTesting();
      await saveService.init();

      expect(saveService.currentWorld, equals(1));
      expect(saveService.getUnlockedLevel(1), equals(1));
      expect(saveService.getLevelStars('PZ_W1_L1'), equals(0));
      expect(saveService.getLevelBestTime('PZ_W1_L1'), equals(0));
      expect(saveService.getLevelCompletionCount('PZ_W1_L1'), equals(0));
      expect(saveService.getLevelBestMistakes('PZ_W1_L1'), isNull);
      expect(saveService.getLevelBestHints('PZ_W1_L1'), isNull);
      expect(saveService.getTotalStars(), equals(0));
      expect(saveService.getTotalSolved(), equals(0));
      expect(saveService.musicEnabled, isTrue);
      expect(saveService.sfxEnabled, isTrue);
      expect(saveService.schemaVersion, equals(SaveService.currentSchemaVersion));
    });

    test('Corrupted/malformed data is sanitized safely and does not crash app', () async {
      // Simulate corrupted storage with invalid types and out-of-range values
      SharedPreferences.setMockInitialValues({
        'stars_PZ_W1_L1': 'not_a_number',
        'stars_PZ_W1_L2': 99, // out of range: must clamp to 3
        'stars_PZ_W1_L3': -5, // out of range: must clamp to 0
        'time_PZ_W1_L1': -100, // invalid time
        'unlocked_level_1': 'corrupted_string',
        'unlocked_level_2': 500, // out of range: must clamp to 30
        'coins': 'invalid_coins',
        'music_volume': 'corrupted',
        'schema_version': 'bad_version',
      });

      saveService.resetForTesting();
      await saveService.init();

      // Corrupted stars recover to 0 or clamped safely
      expect(saveService.getLevelStars('PZ_W1_L1'), equals(0));
      expect(saveService.getLevelStars('PZ_W1_L2'), equals(3));
      expect(saveService.getLevelStars('PZ_W1_L3'), equals(0));

      // Corrupted time recovers safely
      expect(saveService.getLevelBestTime('PZ_W1_L1'), equals(0));

      // Corrupted unlocked level recovers to safe defaults
      expect(saveService.getUnlockedLevel(1), equals(1));
      expect(saveService.getUnlockedLevel(2), equals(30));

      // Corrupted coins recover to default 1250
      expect(saveService.coins, equals(1250));

      // Corrupted schema recovers safely
      expect(saveService.schemaVersion, equals(SaveService.currentSchemaVersion));
    });
  });

  group('WORLD PROGRESS TESTS (0/30, Partial, 30/30)', () {
    test('World progress for 0/30 levels completed', () {
      final worldRecord = saveService.getWorldRecord(1, 'Bamboo Forest');
      expect(worldRecord.totalLevels, equals(30));
      expect(worldRecord.completedLevels, equals(0));
      expect(worldRecord.totalStars, equals(0));
      expect(worldRecord.maxStars, equals(90));
      expect(worldRecord.progressPercentage, equals(0.0));
      expect(worldRecord.starsPercentage, equals(0.0));
    });

    test('World progress for partial completion (e.g. 5 levels)', () async {
      await saveService.recordLevelCompletion(worldId: 1, levelId: 1, stars: 3, timeSeconds: 30, mistakes: 0, hintsUsed: 0);
      await saveService.recordLevelCompletion(worldId: 1, levelId: 2, stars: 2, timeSeconds: 40, mistakes: 1, hintsUsed: 0);
      await saveService.recordLevelCompletion(worldId: 1, levelId: 3, stars: 3, timeSeconds: 35, mistakes: 0, hintsUsed: 0);
      await saveService.recordLevelCompletion(worldId: 1, levelId: 4, stars: 1, timeSeconds: 60, mistakes: 2, hintsUsed: 0);
      await saveService.recordLevelCompletion(worldId: 1, levelId: 5, stars: 2, timeSeconds: 50, mistakes: 1, hintsUsed: 1);

      final worldRecord = saveService.getWorldRecord(1, 'Bamboo Forest');
      expect(worldRecord.completedLevels, equals(5));
      expect(worldRecord.totalStars, equals(11)); // 3+2+3+1+2 = 11
      expect(worldRecord.progressPercentage, closeTo(5 / 30, 0.0001));
      expect(worldRecord.starsPercentage, closeTo(11 / 90, 0.0001));
    });

    test('World progress for full 30/30 completion', () async {
      for (int lvl = 1; lvl <= 30; lvl++) {
        await saveService.recordLevelCompletion(
          worldId: 2,
          levelId: lvl,
          stars: 3,
          timeSeconds: 30,
          mistakes: 0,
          hintsUsed: 0,
        );
      }

      final worldRecord = saveService.getWorldRecord(2, 'Moonlight Forest');
      expect(worldRecord.completedLevels, equals(30));
      expect(worldRecord.totalStars, equals(90));
      expect(worldRecord.progressPercentage, equals(1.0));
      expect(worldRecord.starsPercentage, equals(1.0));
    });
  });

  group('8x8 AND 10x10 PROGRESSION INTEGRATION TESTS', () {
    test('8x8 Standard level progression in World 1 generates 8x8 and unlocks Level 2 on completion', () async {
      final container = ProviderContainer(
        overrides: [
          saveServiceProvider.overrideWithValue(saveService),
        ],
      );

      final puzzle = container.read(puzzleForLevelProvider(const LevelSpec(1, 1)));
      expect(puzzle.size, equals(8));
      expect(puzzle.seed, equals('PZ_W1_L1'));

      final gameNotifier = GameNotifier(
        puzzle: puzzle,
        saveService: saveService,
      );

      // Solve all 8 pandas
      for (final p in puzzle.solution.pandaPositions) {
        await gameNotifier.tapCell(p.row, p.col);
      }

      expect(gameNotifier.state.status, equals(GameStatus.completed));
      expect(gameNotifier.state.foundPandas.length, equals(8));
      expect(saveService.getLevelStars('PZ_W1_L1'), equals(3));
      expect(saveService.getUnlockedLevel(1), equals(2));

      final level2Record = saveService.getLevelRecord(1, 2);
      expect(level2Record.isAvailable, isTrue);

      container.dispose();
    });

    test('10x10 Advanced level progression in World 4 generates 10x10 and unlocks Level 2 on completion', () async {
      final container = ProviderContainer(
        overrides: [
          saveServiceProvider.overrideWithValue(saveService),
        ],
      );

      final puzzle = container.read(puzzleForLevelProvider(const LevelSpec(4, 1)));
      expect(puzzle.size, equals(10));
      expect(puzzle.seed, equals('PZ_W4_L1'));

      final gameNotifier = GameNotifier(
        puzzle: puzzle,
        saveService: saveService,
      );

      // Solve all 10 pandas
      for (final p in puzzle.solution.pandaPositions) {
        await gameNotifier.tapCell(p.row, p.col);
      }

      expect(gameNotifier.state.status, equals(GameStatus.completed));
      expect(gameNotifier.state.foundPandas.length, equals(10));
      expect(saveService.getLevelStars('PZ_W4_L1'), equals(3));
      expect(saveService.getUnlockedLevel(4), equals(2));

      final level2Record = saveService.getLevelRecord(4, 2);
      expect(level2Record.isAvailable, isTrue);

      container.dispose();
    });
  });

  group('DAILY CHALLENGE & PERSISTENCE INTEGRATION', () {
    test('Daily challenge completion state is saved and restored', () async {
      await saveService.saveDailyChallenge(
        date: '2026-09-29',
        completed: true,
        time: 55,
        mistakes: 1,
        hints: 0,
      );

      expect(saveService.dailyChallengeDate, equals('2026-09-29'));
      expect(saveService.dailyChallengeCompleted, isTrue);
      expect(saveService.dailyChallengeTime, equals(55));
      expect(saveService.dailyChallengeMistakes, equals(1));
      expect(saveService.dailyChallengeHints, equals(0));

      // Simulate app restart
      saveService.resetForTesting();
      final freshSave = SaveService();
      await freshSave.init();

      expect(freshSave.dailyChallengeDate, equals('2026-09-29'));
      expect(freshSave.dailyChallengeCompleted, isTrue);
      expect(freshSave.dailyChallengeTime, equals(55));
    });
  });

  group('PHASE 6.1 CLARIFICATION & REGRESSION TESTS', () {
    test('bestMistakes improves downward and never worsens (5 -> 3 -> 7 -> 3)', () async {
      // First completion: 5 mistakes
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 10,
        stars: 1,
        timeSeconds: 60,
        mistakes: 5,
        hintsUsed: 0,
      );
      expect(saveService.getLevelBestMistakes('PZ_W1_L10'), equals(5));

      // Replay: 3 mistakes -> improves to 3
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 10,
        stars: 1,
        timeSeconds: 50,
        mistakes: 3,
        hintsUsed: 0,
      );
      expect(saveService.getLevelBestMistakes('PZ_W1_L10'), equals(3));

      // Replay: 7 mistakes -> stays 3 (never worsens)
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 10,
        stars: 1,
        timeSeconds: 45,
        mistakes: 7,
        hintsUsed: 0,
      );
      expect(saveService.getLevelBestMistakes('PZ_W1_L10'), equals(3));
    });

    test('bestHints improves downward and never worsens (2 -> 1 -> 3 -> 1)', () async {
      // First completion: 2 hints
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 11,
        stars: 1,
        timeSeconds: 60,
        mistakes: 0,
        hintsUsed: 2,
      );
      expect(saveService.getLevelBestHints('PZ_W1_L11'), equals(2));

      // Replay: 1 hint -> improves to 1
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 11,
        stars: 2,
        timeSeconds: 50,
        mistakes: 0,
        hintsUsed: 1,
      );
      expect(saveService.getLevelBestHints('PZ_W1_L11'), equals(1));

      // Replay: 3 hints -> stays 1 (never worsens)
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 11,
        stars: 1,
        timeSeconds: 45,
        mistakes: 0,
        hintsUsed: 3,
      );
      expect(saveService.getLevelBestHints('PZ_W1_L11'), equals(1));
    });

    test('Star upgrade and downgrade regression: 1 -> 2 -> 1 (stays 2) -> 3 -> 2 (stays 3)', () async {
      const key = 'PZ_W1_L12';

      // 1. Initial completion: 1 star
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 12,
        stars: 1,
        timeSeconds: 60,
        mistakes: 2,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars(key), equals(1));

      // 2. Replay: 2 stars -> upgrades to 2
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 12,
        stars: 2,
        timeSeconds: 50,
        mistakes: 1,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars(key), equals(2));

      // 3. Replay: 1 star -> preserves 2
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 12,
        stars: 1,
        timeSeconds: 55,
        mistakes: 2,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars(key), equals(2));

      // 4. Replay: 3 stars -> upgrades to 3
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 12,
        stars: 3,
        timeSeconds: 40,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars(key), equals(3));

      // 5. Replay: 2 stars -> preserves 3
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 12,
        stars: 2,
        timeSeconds: 45,
        mistakes: 1,
        hintsUsed: 0,
      );
      expect(saveService.getLevelStars(key), equals(3));
    });

    test('Level state regression: 0 stars available/locked, 1-2 stars completed, 3 stars mastered and mastered never downgrades', () async {
      await saveService.setUnlockedLevel(1, 13);
      expect(saveService.getLevelState(1, 13), equals(LevelState.available));

      // Level 13: 1 star -> Completed
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 13,
        stars: 1,
        timeSeconds: 50,
        mistakes: 2,
        hintsUsed: 0,
      );
      expect(saveService.getLevelState(1, 13), equals(LevelState.completed));

      // Level 13: 2 stars -> Completed
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 13,
        stars: 2,
        timeSeconds: 45,
        mistakes: 1,
        hintsUsed: 0,
      );
      expect(saveService.getLevelState(1, 13), equals(LevelState.completed));

      // Level 13: 3 stars -> Mastered
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 13,
        stars: 3,
        timeSeconds: 30,
        mistakes: 0,
        hintsUsed: 0,
      );
      expect(saveService.getLevelState(1, 13), equals(LevelState.mastered));

      // Replaying with 1 star must keep Mastered state
      await saveService.recordLevelCompletion(
        worldId: 1,
        levelId: 13,
        stars: 1,
        timeSeconds: 70,
        mistakes: 2,
        hintsUsed: 0,
      );
      expect(saveService.getLevelState(1, 13), equals(LevelState.mastered));
    });

    test('World unlock helper defaults and behavior', () async {
      // World 1 always unlocked
      expect(saveService.isWorldUnlocked(1), isTrue);

      // Worlds 2..6 currently default to accessible/unlocked
      for (int w = 2; w <= 6; w++) {
        expect(saveService.isWorldUnlocked(w), isTrue);
      }

      // Explicitly locking a world via setWorldUnlocked
      await saveService.setWorldUnlocked(2, false);
      expect(saveService.isWorldUnlocked(2), isFalse);

      // Re-unlocking
      await saveService.setWorldUnlocked(2, true);
      expect(saveService.isWorldUnlocked(2), isTrue);
    });
  });
}
