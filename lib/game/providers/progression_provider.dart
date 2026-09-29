import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/storage/save_service.dart';

class ProgressionState {
  final int currentWorld;
  final int totalStars;
  final int totalSolved;
  final int coins;
  final int gems;

  const ProgressionState({
    required this.currentWorld,
    required this.totalStars,
    required this.totalSolved,
    required this.coins,
    required this.gems,
  });
}

class ProgressionNotifier extends StateNotifier<ProgressionState> {
  final SaveService _saveService;

  ProgressionNotifier(this._saveService)
      : super(ProgressionState(
          currentWorld: _saveService.currentWorld,
          totalStars: _saveService.getTotalStars(),
          totalSolved: _saveService.getTotalSolved(),
          coins: _saveService.coins,
          gems: _saveService.gems,
        ));

  void refresh() {
    state = ProgressionState(
      currentWorld: _saveService.currentWorld,
      totalStars: _saveService.getTotalStars(),
      totalSolved: _saveService.getTotalSolved(),
      coins: _saveService.coins,
      gems: _saveService.gems,
    );
  }

  void selectWorld(int worldId) {
    _saveService.setCurrentWorld(worldId);
    refresh();
  }

  void unlockNextLevel(int worldId, int currentLevel) {
    final nextLevel = currentLevel + 1;
    final currentUnlocked = _saveService.getUnlockedLevel(worldId);
    if (nextLevel > currentUnlocked) {
      _saveService.setUnlockedLevel(worldId, nextLevel);
    }
    refresh();
  }
}

final saveServiceProvider = Provider<SaveService>((ref) => SaveService());

final progressionProvider =
    StateNotifierProvider<ProgressionNotifier, ProgressionState>((ref) {
  final save = ref.watch(saveServiceProvider);
  return ProgressionNotifier(save);
});
