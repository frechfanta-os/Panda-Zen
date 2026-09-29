enum CellState {
  hidden,
  selected,
  revealedEmpty,
  revealedPanda,
  hinted,
}

enum CellFeedback {
  none,
  correct,
  incorrect,
}

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && runtimeType == other.runtimeType && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}

class Cell {
  final int row;
  final int column;
  final int regionId;
  final CellState state;
  final int visualType;

  const Cell({
    required this.row,
    required this.column,
    required this.regionId,
    this.state = CellState.hidden,
    this.visualType = 0,
  });

  Position get position => Position(row, column);

  Cell copyWith({
    int? row,
    int? column,
    int? regionId,
    CellState? state,
    int? visualType,
  }) {
    return Cell(
      row: row ?? this.row,
      column: column ?? this.column,
      regionId: regionId ?? this.regionId,
      state: state ?? this.state,
      visualType: visualType ?? this.visualType,
    );
  }
}
