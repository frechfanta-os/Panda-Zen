import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/puzzle.dart';
import 'puzzle_cell.dart';
import 'region_renderer.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive square board size strictly from available constraints
        final double maxSquare;
        if (constraints.maxWidth.isFinite && constraints.maxHeight.isFinite) {
          maxSquare = min(constraints.maxWidth, constraints.maxHeight);
        } else if (constraints.maxWidth.isFinite) {
          maxSquare = constraints.maxWidth;
        } else if (constraints.maxHeight.isFinite) {
          maxSquare = constraints.maxHeight;
        } else {
          maxSquare = 360.0;
        }

        final boardSize = max(0.0, maxSquare);
        final cellSize = puzzle.size > 0 ? boardSize / puzzle.size : 0.0;
        final strokeWidth = RegionStyle.responsiveBorderWidth(cellSize);
        final borderRadius = (cellSize * 0.25).clamp(8.0, 16.0);

        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: const Color(0xFFF9F6F0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
                  blurRadius: 0,
                  spreadRadius: 2.5,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(puzzle.size, (r) {
                return Expanded(
                  child: Row(
                    children: List.generate(puzzle.size, (c) {
                      final pos = Position(r, c);
                      final state = cellStates[pos] ?? CellState.hidden;
                      final region = puzzle.getRegionForPosition(pos)!;

                      // Directional edge ownership:
                      // Exactly one cell draws the shared boundary between differing regions.
                      // Same-region neighbors draw no separator.
                      final borderTop = r == 0;
                      final borderBottom = r == puzzle.size - 1 ||
                          puzzle.getRegionId(r + 1, c) != region.id;
                      final borderLeft = c == 0;
                      final borderRight = c == puzzle.size - 1 ||
                          puzzle.getRegionId(r, c + 1) != region.id;

                      final cell = Cell(
                        row: r,
                        column: c,
                        regionId: region.id,
                        state: state,
                      );

                      return Expanded(
                        child: PuzzleCell(
                          cell: cell,
                          region: region,
                          size: cellSize,
                          strokeWidth: strokeWidth,
                          borderTop: borderTop,
                          borderBottom: borderBottom,
                          borderLeft: borderLeft,
                          borderRight: borderRight,
                          onTap: () => onCellTap(r, c),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      );
      },
    );
  }
}
