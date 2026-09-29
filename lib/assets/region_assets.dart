enum RegionVisualType {
  bamboo,
  leaves,
  stones,
  flowers,
  wood,
  water,
  snow,
}

class RegionAssets {
  RegionAssets._();

  static const String base = 'assets/images/regions';

  static String region(int index) {
    final clamped = ((index - 1) % 93) + 1;
    final numStr = clamped.toString().padLeft(2, '0');
    return '$base/Regions$numStr.png';
  }

  static String forVisualType(RegionVisualType type, [int variant = 0]) {
    switch (type) {
      case RegionVisualType.bamboo:
        final variants = [1, 2, 3, 4, 5, 6, 7];
        return region(variants[variant % variants.length]);
      case RegionVisualType.leaves:
        final variants = [31, 32, 33, 34, 35, 36];
        return region(variants[variant % variants.length]);
      case RegionVisualType.stones:
        final variants = [16, 17, 18, 19, 20, 21];
        return region(variants[variant % variants.length]);
      case RegionVisualType.flowers:
        final variants = [46, 47, 48, 49, 50];
        return region(variants[variant % variants.length]);
      case RegionVisualType.wood:
        final variants = [51, 52, 53, 54, 55, 56];
        return region(variants[variant % variants.length]);
      case RegionVisualType.water:
        final variants = [61, 62, 63, 64, 65, 66];
        return region(variants[variant % variants.length]);
      case RegionVisualType.snow:
        final variants = [76, 77, 78, 79, 80, 81];
        return region(variants[variant % variants.length]);
    }
  }
}
