import 'package:flutter/widgets.dart';

enum UiSprite {
  hudLevelBar(1),
  livesBar(2),
  coinsBar(3),
  gemsBar(4),
  btnSettingsIcon(5),
  btnLeaderboardIcon(6),
  btnShopIcon(7),
  btnPlay(8),
  btnWorlds(9),
  btnDaily(10),
  btnLeaderboard(11),
  btnSkins(12),
  btnSettings(13),
  btnHint(14),
  btnUndo(15),
  btnClear(16),
  btnRestart(17),
  btnPause(18),
  btnMusic(19),
  btnSound(20),
  btnFullscreen(21),
  btnHelp(22),
  btnInfo(23),
  modalPreview(24),
  modalComplete(25),
  modalFailed(26),
  modalPause(27),
  worldBanner(28),
  btnBack(29),
  tileLevel(30),
  btnForward(31),
  bannerRewards(32);

  const UiSprite(this.spriteNumber);
  final int spriteNumber;
}

class UiAssets {
  UiAssets._();

  static String getSprite(UiSprite sprite, [Locale? locale]) {
    final lang = (locale?.languageCode.toLowerCase() == 'fr') ? 'fr' : 'en';
    final prefix = lang.toUpperCase();
    final numStr = sprite.spriteNumber.toString().padLeft(2, '0');
    return 'assets/images/ui/$lang/UI-$prefix$numStr.png';
  }

  static String byIndex(int index, [Locale? locale]) {
    final lang = (locale?.languageCode.toLowerCase() == 'fr') ? 'fr' : 'en';
    final prefix = lang.toUpperCase();
    final numStr = index.toString().padLeft(2, '0');
    return 'assets/images/ui/$lang/UI-$prefix$numStr.png';
  }
}
