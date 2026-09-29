/// Cell sprites for puzzle board tiles
class CellAssets {
  CellAssets._();

  static const String base = 'assets/images/cells';

  static String cell(int index) {
    final clamped = (index % 35) + 1;
    final numStr = clamped.toString().padLeft(2, '0');
    return '$base/Cells$numStr.png';
  }

  static const String defaultCell = '$base/Cells01.png';
  static const String emptyRevealed = '$base/Cells05.png';
  static const String highlightCell = '$base/Cells10.png';
}
