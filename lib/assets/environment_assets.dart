/// Environment backgrounds mapped to worlds
class EnvironmentAssets {
  EnvironmentAssets._();

  static const String base = 'assets/images/environments';

  static const String world1BambooForest = '$base/Environnements01.png';
  static const String world2MoonlightForest = '$base/Environnements02.png';
  static const String world3SnowBamboo = '$base/Environnements03.png';
  static const String world4PandaTemple = '$base/Environnements04.png';
  static const String world5SpringValley = '$base/Environnements05.png';
  static const String world6RainyForest = '$base/Environnements06.png';

  static String forWorld(int worldIndex) {
    switch (worldIndex) {
      case 1:
        return world1BambooForest;
      case 2:
        return world2MoonlightForest;
      case 3:
        return world3SnowBamboo;
      case 4:
        return world4PandaTemple;
      case 5:
        return world5SpringValley;
      case 6:
        return world6RainyForest;
      default:
        return world1BambooForest;
    }
  }
}
