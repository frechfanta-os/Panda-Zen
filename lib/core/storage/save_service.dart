import 'package:shared_preferences/shared_preferences.dart';
import '../../game/models/progression_models.dart';

class SaveService {
  static final SaveService _instance = SaveService._internal();
  factory SaveService() => _instance;
  SaveService._internal();

  static const int currentSchemaVersion = 1;
  static const int levelsPerWorld = 30;

  SharedPreferences? _prefs;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init({SharedPreferences? prefs}) async {
    if (prefs != null) {
      _prefs = prefs;
      _initialized = true;
      _migrateAndSanitize();
      return;
    }
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      _migrateAndSanitize();
    } catch (_) {
      // In tests or if platform storage unavailable, gracefully proceed with in-memory safe defaults
    }
  }

  void _migrateAndSanitize() {
    if (_prefs == null) return;
    try {
      final version = _prefs!.getInt('schema_version');
      if (version == null) {
        _prefs!.setInt('schema_version', currentSchemaVersion);
      }
    } catch (_) {
      // Malformed schema version: sanitize safely
      _prefs!.setInt('schema_version', currentSchemaVersion);
    }
  }

  void resetForTesting() {
    _prefs = null;
    _initialized = false;
  }

  int get schemaVersion {
    try {
      return _prefs?.getInt('schema_version') ?? currentSchemaVersion;
    } catch (_) {
      return currentSchemaVersion;
    }
  }

  // Audio settings
  bool get musicEnabled {
    try {
      return _prefs?.getBool('music_enabled') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setMusicEnabled(bool val) async =>
      await _prefs?.setBool('music_enabled', val);

  bool get sfxEnabled {
    try {
      return _prefs?.getBool('sfx_enabled') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setSfxEnabled(bool val) async =>
      await _prefs?.setBool('sfx_enabled', val);

  double get musicVolume {
    try {
      return _prefs?.getDouble('music_volume') ?? 0.5;
    } catch (_) {
      return 0.5;
    }
  }

  Future<void> setMusicVolume(double val) async =>
      await _prefs?.setDouble('music_volume', val);

  double get sfxVolume {
    try {
      return _prefs?.getDouble('sfx_volume') ?? 0.8;
    } catch (_) {
      return 0.8;
    }
  }

  Future<void> setSfxVolume(double val) async =>
      await _prefs?.setDouble('sfx_volume', val);

  // Localization
  String? get languageCode {
    try {
      return _prefs?.getString('language_code');
    } catch (_) {
      return null;
    }
  }

  Future<void> setLanguageCode(String code) async =>
      await _prefs?.setString('language_code', code);

  // Currency
  int get coins {
    try {
      final val = _prefs?.get('coins');
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 1250;
      return 1250;
    } catch (_) {
      return 1250;
    }
  }

  Future<void> setCoins(int val) async => await _prefs?.setInt('coins', val);

  int get gems {
    try {
      final val = _prefs?.get('gems');
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 35;
      return 35;
    } catch (_) {
      return 35;
    }
  }

  Future<void> setGems(int val) async => await _prefs?.setInt('gems', val);

  // Progression
  int get currentWorld {
    try {
      final val = _prefs?.get('current_world');
      if (val is int && val >= 1 && val <= 6) return val;
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null && parsed >= 1 && parsed <= 6) return parsed;
      }
      return 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> setCurrentWorld(int w) async {
    final sanitized = w.clamp(1, 6);
    await _prefs?.setInt('current_world', sanitized);
  }

  // WORLD_UNLOCK_RULE_PENDING:
  // In the current implementation, all worlds (1..6) are accessible by default.
  // No prerequisite unlock rule (e.g. 30 levels or star threshold) has been officially chosen.
  // The helper methods below support future gating, but currently default to true.
  bool isWorldUnlocked(int worldId) {
    if (worldId <= 1) return true;
    try {
      // Retain existing behavior where worlds are accessible, unless explicitly locked/unlocked
      return _prefs?.getBool('world_unlocked_$worldId') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setWorldUnlocked(int worldId, bool unlocked) async {
    await _prefs?.setBool('world_unlocked_$worldId', unlocked);
  }

  int getUnlockedLevel(int worldId) {
    try {
      final val = _prefs?.get('unlocked_level_$worldId');
      if (val is int) {
        return val.clamp(1, levelsPerWorld);
      }
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) {
          return parsed.clamp(1, levelsPerWorld);
        }
      }
      return 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> setUnlockedLevel(int worldId, int level) async {
    final current = getUnlockedLevel(worldId);
    final sanitized = level.clamp(1, levelsPerWorld);
    if (sanitized > current) {
      await _prefs?.setInt('unlocked_level_$worldId', sanitized);
    }
  }

  int getLevelStars(String levelKey) {
    try {
      final val = _prefs?.get('stars_$levelKey');
      if (val is int) {
        return val.clamp(0, 3);
      }
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) {
          return parsed.clamp(0, 3);
        }
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> setLevelStars(String levelKey, int stars) async {
    final current = getLevelStars(levelKey);
    final clamped = stars.clamp(0, 3);
    if (clamped > current) {
      await _prefs?.setInt('stars_$levelKey', clamped);
    }
  }

  int getLevelBestTime(String levelKey) {
    try {
      final val = _prefs?.get('time_$levelKey');
      if (val is int && val >= 0) return val;
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null && parsed >= 0) return parsed;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> setLevelBestTime(String levelKey, int seconds) async {
    if (seconds <= 0) return;
    final current = getLevelBestTime(levelKey);
    if (current == 0 || seconds < current) {
      await _prefs?.setInt('time_$levelKey', seconds);
    }
  }

  int? getLevelBestMistakes(String levelKey) {
    try {
      final val = _prefs?.get('best_mistakes_$levelKey');
      if (val is int && val >= 0) return val;
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null && parsed >= 0) return parsed;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  int? getLevelBestHints(String levelKey) {
    try {
      final val = _prefs?.get('best_hints_$levelKey');
      if (val is int && val >= 0) return val;
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null && parsed >= 0) return parsed;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  int getLevelCompletionCount(String levelKey) {
    try {
      final val = _prefs?.get('completions_$levelKey');
      if (val is int && val >= 0) return val;
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null && parsed >= 0) return parsed;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> recordLevelCompletion({
    required int worldId,
    required int levelId,
    required int stars,
    required int timeSeconds,
    required int mistakes,
    required int hintsUsed,
  }) async {
    final key = 'PZ_W${worldId}_L$levelId';

    // 1. Stars: upgrade only, never downgrade
    final currentStars = getLevelStars(key);
    final clampedStars = stars.clamp(0, 3);
    if (clampedStars > currentStars) {
      await _prefs?.setInt('stars_$key', clampedStars);
    }

    // 2. Best time: first completion or faster replaces
    final currentTime = getLevelBestTime(key);
    if (currentTime == 0 || (timeSeconds > 0 && timeSeconds < currentTime)) {
      await _prefs?.setInt('time_$key', timeSeconds);
    }

    // 3. Best mistakes: lowest mistakes achieved
    final currentBestMistakes = getLevelBestMistakes(key);
    if (currentBestMistakes == null || mistakes < currentBestMistakes) {
      await _prefs?.setInt('best_mistakes_$key', mistakes);
    }

    // 4. Best hints: lowest hints used achieved
    final currentBestHints = getLevelBestHints(key);
    if (currentBestHints == null || hintsUsed < currentBestHints) {
      await _prefs?.setInt('best_hints_$key', hintsUsed);
    }

    // 5. Completion count
    final completions = getLevelCompletionCount(key);
    await _prefs?.setInt('completions_$key', completions + 1);

    // 6. Unlock next level in this world
    final currentUnlocked = getUnlockedLevel(worldId);
    if (levelId >= currentUnlocked && levelId < levelsPerWorld) {
      await setUnlockedLevel(worldId, levelId + 1);
    }
  }

  LevelState getLevelState(int worldId, int levelId) {
    final unlocked = getUnlockedLevel(worldId);
    if (levelId > unlocked) {
      return LevelState.locked;
    }
    final stars = getLevelStars('PZ_W${worldId}_L$levelId');
    if (stars == 3) {
      return LevelState.mastered;
    } else if (stars > 0) {
      return LevelState.completed;
    } else {
      return LevelState.available;
    }
  }

  LevelRecord getLevelRecord(int worldId, int levelId) {
    final key = 'PZ_W${worldId}_L$levelId';
    return LevelRecord(
      worldId: worldId,
      levelId: levelId,
      state: getLevelState(worldId, levelId),
      stars: getLevelStars(key),
      bestTime: getLevelBestTime(key),
      completionCount: getLevelCompletionCount(key),
      bestMistakes: getLevelBestMistakes(key) ?? 0,
      bestHintUsage: getLevelBestHints(key) ?? 0,
    );
  }

  int getWorldCompletedLevels(int worldId) {
    int count = 0;
    for (int lvl = 1; lvl <= levelsPerWorld; lvl++) {
      if (getLevelStars('PZ_W${worldId}_L$lvl') > 0) {
        count++;
      }
    }
    return count;
  }

  int getWorldStars(int worldId) {
    int total = 0;
    for (int lvl = 1; lvl <= levelsPerWorld; lvl++) {
      total += getLevelStars('PZ_W${worldId}_L$lvl');
    }
    return total;
  }

  WorldRecord getWorldRecord(int worldId, [String? name]) {
    return WorldRecord(
      worldId: worldId,
      name: name ?? 'World $worldId',
      totalLevels: levelsPerWorld,
      completedLevels: getWorldCompletedLevels(worldId),
      totalStars: getWorldStars(worldId),
      maxStars: levelsPerWorld * 3,
      isUnlocked: isWorldUnlocked(worldId),
    );
  }

  int getTotalStars() {
    if (_prefs == null) return 0;
    try {
      int count = 0;
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('stars_')) {
          final val = _prefs!.get(key);
          if (val is int) {
            count += val.clamp(0, 3);
          } else if (val is String) {
            final parsed = int.tryParse(val);
            if (parsed != null) count += parsed.clamp(0, 3);
          }
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  int getTotalSolved() {
    if (_prefs == null) return 0;
    try {
      int count = 0;
      for (final key in _prefs!.getKeys()) {
        if (key.startsWith('stars_')) {
          final val = _prefs!.get(key);
          int stars = 0;
          if (val is int) {
            stars = val;
          } else if (val is String) {
            stars = int.tryParse(val) ?? 0;
          }
          if (stars > 0) count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  // Daily Challenge
  String? get dailyChallengeDate {
    try {
      return _prefs?.getString('daily_date');
    } catch (_) {
      return null;
    }
  }

  bool get dailyChallengeCompleted {
    try {
      return _prefs?.getBool('daily_completed') ?? false;
    } catch (_) {
      return false;
    }
  }

  int get dailyChallengeTime {
    try {
      return _prefs?.getInt('daily_time') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  int get dailyChallengeMistakes {
    try {
      return _prefs?.getInt('daily_mistakes') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  int get dailyChallengeHints {
    try {
      return _prefs?.getInt('daily_hints') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveDailyChallenge({
    required String date,
    required bool completed,
    required int time,
    required int mistakes,
    required int hints,
  }) async {
    try {
      await _prefs?.setString('daily_date', date);
      await _prefs?.setBool('daily_completed', completed);
      await _prefs?.setInt('daily_time', time);
      await _prefs?.setInt('daily_mistakes', mistakes);
      await _prefs?.setInt('daily_hints', hints);
    } catch (_) {}
  }
}
