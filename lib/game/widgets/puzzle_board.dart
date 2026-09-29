import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/puzzle.dart';
import 'puzzle_cell.dart';

class PuzzleBoard extends StatelessWidget {
  final Puzzle puzzle;
  final Map<Position, CellState> cellStates;
  final Function(int row, int col) onCellTap;

  const PuzzleBoard({
    super.key,
    required this.puzzle,
    required this.cellStates,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF9F6F0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
              blurRadius: 0,
              spreadRadius: 4,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / puzzle.size;

            return Column(
              children: List.generate(puzzle.size, (r) {
                return Row(
                  children: List.generate(puzzle.size, (c) {
                    final pos = Position(r, c);
                    final state = cellStates[pos] ?? CellState.hidden;
                    final region = puzzle.getRegionForPosition(pos)!;

                    // Border calculations
                    final borderTop = r == 0 || puzzle.getRegionId(r - 1, c) != region.id;
                    final borderBottom = r == puzzle.size - 1 || puzzle.getRegionId(r + 1, c) != region.id;
                    final borderLeft = c == 0 || puzzle.getRegionId(r, c - 1) != region.id;
                    final borderRight = c == puzzle.size - 1 || puzzle.getRegionId(r, c + 1) != region.id;

                    final cell = Cell(
                      row: r,
                      column: c,
                      regionId: region.id,
                      state: state,
                    );

                    return SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: PuzzleCell(
                        cell: cell,
                        region: region,
                        size: cellSize,
                        borderTop: borderTop,
                        borderBottom: borderBottom,
                        borderLeft: borderLeft,
                        borderRight: borderRight,
                        onTap: () => onCellTap(r, c),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
