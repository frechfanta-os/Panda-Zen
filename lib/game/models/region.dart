import '../../assets/region_assets.dart';
import 'cell.dart';

class Region {
  final int id;
  final RegionVisualType visualType;
  final List<Position> cells;

  const Region({
    required this.id,
    required this.visualType,
    required this.cells,
  });

  bool contains(Position pos) {
    return cells.any((c) => c == pos);
  }
}
