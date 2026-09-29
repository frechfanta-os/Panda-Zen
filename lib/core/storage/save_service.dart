import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static final SaveService _instance = SaveService._internal();
  factory SaveService() => _instance;
  SaveService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (_) {
      // In tests or if platform storage unavailable, gracefully proceed with in-memory defaults
    }
  }

  // Audio settings
  bool get musicEnabled => _prefs?.getBool('music_enabled') ?? true;
  Future<void> setMusicEnabled(bool val) async => await _prefs?.setBool('music_enabled', val);

  bool get sfxEnabled => _prefs?.getBool('sfx_enabled') ?? true;
  Future<void> setSfxEnabled(bool val) async => await _prefs?.setBool('sfx_enabled', val);

  double get musicVolume => _prefs?.getDouble('music_volume') ?? 0.5;
  Future<void> setMusicVolume(double val) async => await _prefs?.setDouble('music_volume', val);

  double get sfxVolume => _prefs?.getDouble('sfx_volume') ?? 0.8;
  Future<void> setSfxVolume(double val) async => await _prefs?.setDouble('sfx_volume', val);

  // Localization
  String? get languageCode => _prefs?.getString('language_code');
  Future<void> setLanguageCode(String code) async => await _prefs?.setString('language_code', code);

  // Currency
  int get coins => _prefs?.getInt('coins') ?? 1250;
  Future<void> setCoins(int val) async => await _prefs?.setInt('coins', val);

  int get gems => _prefs?.getInt('gems') ?? 35;
  Future<void> setGems(int val) async => await _prefs?.setInt('gems', val);

  // Progression
  int get currentWorld => _prefs?.getInt('current_world') ?? 1;
  Future<void> setCurrentWorld(int w) async => await _prefs?.setInt('current_world', w);

  int getUnlockedLevel(int worldId) => _prefs?.getInt('unlocked_level_$worldId') ?? 1;
  Future<void> setUnlockedLevel(int worldId, int level) async =>
      await _prefs?.setInt('unlocked_level_$worldId', level);

  int getLevelStars(String levelKey) => _prefs?.getInt('stars_$levelKey') ?? 0;
  Future<void> setLevelStars(String levelKey, int stars) async {
    final current = getLevelStars(levelKey);
    if (stars > current) {
      await _prefs?.setInt('stars_$levelKey', stars);
    }
  }

  int getLevelBestTime(String levelKey) => _prefs?.getInt('time_$levelKey') ?? 0;
  Future<void> setLevelBestTime(String levelKey, int seconds) async {
    final current = getLevelBestTime(levelKey);
    if (current == 0 || seconds < current) {
      await _prefs?.setInt('time_$levelKey', seconds);
    }
  }

  int getTotalStars() {
    if (_prefs == null) return 0;
    int count = 0;
    for (final key in _prefs!.getKeys()) {
      if (key.startsWith('stars_')) {
        count += _prefs!.getInt(key) ?? 0;
      }
    }
    return count;
  }

  int getTotalSolved() {
    if (_prefs == null) return 0;
    int count = 0;
    for (final key in _prefs!.getKeys()) {
      if (key.startsWith('stars_') && (_prefs!.getInt(key) ?? 0) > 0) {
        count++;
      }
    }
    return count;
  }

  // Daily Challenge
  String? get dailyChallengeDate => _prefs?.getString('daily_date');
  bool get dailyChallengeCompleted => _prefs?.getBool('daily_completed') ?? false;
  int get dailyChallengeTime => _prefs?.getInt('daily_time') ?? 0;
  int get dailyChallengeMistakes => _prefs?.getInt('daily_mistakes') ?? 0;
  int get dailyChallengeHints => _prefs?.getInt('daily_hints') ?? 0;

  Future<void> saveDailyChallenge({
    required String date,
    required bool completed,
    required int time,
    required int mistakes,
    required int hints,
  }) async {
    await _prefs?.setString('daily_date', date);
    await _prefs?.setBool('daily_completed', completed);
    await _prefs?.setInt('daily_time', time);
    await _prefs?.setInt('daily_mistakes', mistakes);
    await _prefs?.setInt('daily_hints', hints);
  }
}
