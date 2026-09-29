import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/storage/save_service.dart';
import '../game/providers/progression_provider.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  final SaveService _save;

  LocaleNotifier(this._save) : super(null) {
    _initLocale();
  }

  void _initLocale() {
    final code = _save.languageCode;
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale loc) async {
    state = loc;
    await _save.setLanguageCode(loc.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final save = ref.watch(saveServiceProvider);
  return LocaleNotifier(save);
});
