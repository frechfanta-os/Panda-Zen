import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/engine/puzzle_generator.dart';
import 'package:panda_zen/game/models/cell.dart';
import 'package:panda_zen/game/widgets/puzzle_board.dart';
import 'package:panda_zen/game/widgets/puzzle_cell.dart';
import 'package:panda_zen/game/widgets/region_renderer.dart';

void main() {
  final generator = PuzzleGenerator();

  group('PuzzleBoard Responsive Layout Tests', () {
    testWidgets('Renders 8x8 board square and scales to available width', (tester) async {
      final puzzle = generator.generate(size: 8, customSeed: 'test_8x8_layout');

      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 500,
                child: PuzzleBoard(
                  puzzle: puzzle,
                  cellStates: const {},
                  onCellTap: (r, c) {},
                ),
              ),
            ),
          ),
        ),
      );

      final boardFinder = find.byType(PuzzleBoard);
      expect(boardFinder, findsOneWidget);

      final boardBoxFinder = find.descendant(
        of: boardFinder,
        matching: find.byType(SizedBox),
      ).first;
      final renderBox = tester.renderObject(boardBoxFinder) as RenderBox;
      // Board should be square constrained by min(320, 500) = 320
      expect(renderBox.size.width, closeTo(320, 0.5));
      expect(renderBox.size.height, closeTo(320, 0.5));

      // 8x8 = 64 cells
      expect(find.byType(PuzzleCell), findsNWidgets(64));
    });

    testWidgets('Renders 10x10 board square and scales to available width', (tester) async {
      final puzzle = generator.generate(size: 10, customSeed: 'test_10x10_layout');

      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 380,
                height: 600,
                child: PuzzleBoard(
                  puzzle: puzzle,
                  cellStates: const {},
                  onCellTap: (r, c) {},
                ),
              ),
            ),
          ),
        ),
      );

      final boardFinder = find.byType(PuzzleBoard);
      expect(boardFinder, findsOneWidget);

      final boardBoxFinder = find.descendant(
        of: boardFinder,
        matching: find.byType(SizedBox),
      ).first;
      final renderBox = tester.renderObject(boardBoxFinder) as RenderBox;
      expect(renderBox.size.width, closeTo(380, 0.5));
      expect(renderBox.size.height, closeTo(380, 0.5));

      // 10x10 = 100 cells
      expect(find.byType(PuzzleCell), findsNWidgets(100));
    });

    const targetScreens = [
      Size(360, 640),
      Size(360, 800),
      Size(390, 844),
      Size(412, 915),
    ];

    for (final screenSize in targetScreens) {
      testWidgets('No overflow or clipping on ${screenSize.width}x${screenSize.height} for 8x8 & 10x10', (tester) async {
        await tester.binding.setSurfaceSize(screenSize);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        for (final size in [8, 10]) {
          final puzzle = generator.generate(size: size, customSeed: 'screen_${screenSize.width}_$size');

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(height: 50, color: Colors.blue), // Mock HUD
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Center(
                            child: PuzzleBoard(
                              puzzle: puzzle,
                              cellStates: const {},
                              onCellTap: (r, c) {},
                            ),
                          ),
                        ),
                      ),
                      Container(height: 60, color: Colors.green), // Mock Bottom Bar
                    ],
                  ),
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);

          final boardFinder = find.byType(PuzzleBoard);
          expect(boardFinder, findsOneWidget);
          final boardBoxFinder = find.descendant(
            of: boardFinder,
            matching: find.byType(SizedBox),
          ).first;
          final renderBox = tester.renderObject(boardBoxFinder) as RenderBox;
          expect(renderBox.size.width, equals(renderBox.size.height));
          expect(renderBox.size.width, lessThanOrEqualTo(screenSize.width));
          expect(renderBox.size.height, lessThanOrEqualTo(screenSize.height));
        }
      });
    }
  });

  group('PuzzleBoard Tap Targets', () {
    testWidgets('All cells (corners, edges, center, adjacent) are tappable', (tester) async {
      final puzzle = generator.generate(size: 8, customSeed: 'tap_test');
      final tappedCoords = <Position>[];

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 360,
                child: PuzzleBoard(
                  puzzle: puzzle,
                  cellStates: const {},
                  onCellTap: (r, c) => tappedCoords.add(Position(r, c)),
                ),
              ),
            ),
          ),
        ),
      );

      // Find cell widgets
      final cells = find.byType(PuzzleCell);
      expect(cells, findsNWidgets(64));

      // Test corners: (0,0), (0,7), (7,0), (7,7)
      final corners = [
        find.byWidgetPredicate((w) => w is PuzzleCell && w.cell.row == 0 && w.cell.column == 0),
        find.byWidgetPredicate((w) => w is PuzzleCell && w.cell.row == 0 && w.cell.column == 7),
        find.byWidgetPredicate((w) => w is PuzzleCell && w.cell.row == 7 && w.cell.column == 0),
        find.byWidgetPredicate((w) => w is PuzzleCell && w.cell.row == 7 && w.cell.column == 7),
      ];

      for (final corner in corners) {
        expect(corner, findsOneWidget);
        await tester.tap(corner);
        await tester.pump();
      }

      expect(tappedCoords.contains(const Position(0, 0)), isTrue);
      expect(tappedCoords.contains(const Position(0, 7)), isTrue);
      expect(tappedCoords.contains(const Position(7, 0)), isTrue);
      expect(tappedCoords.contains(const Position(7, 7)), isTrue);

      // Test center: (3, 3), (3, 4), (4, 3), (4, 4)
      final centerCell = find.byWidgetPredicate((w) => w is PuzzleCell && w.cell.row == 3 && w.cell.column == 3);
      expect(centerCell, findsOneWidget);
      await tester.tap(centerCell);
      await tester.pump();
      expect(tappedCoords.contains(const Position(3, 3)), isTrue);

      // Test adjacent cell: (3, 4)
      final adjacentCell = find.byWidgetPredicate((w) => w is PuzzleCell && w.cell.row == 3 && w.cell.column == 4);
      expect(adjacentCell, findsOneWidget);
      await tester.tap(adjacentCell);
      await tester.pump();
      expect(tappedCoords.contains(const Position(3, 4)), isTrue);
    });
  });

  group('Region Border & Responsive Stroke Tests', () {
    test('Responsive border width scales with cell size and does not exceed 3.0 or fall below 1.5', () {
      expect(RegionStyle.responsiveBorderWidth(0), equals(1.5));
      expect(RegionStyle.responsiveBorderWidth(20), closeTo(1.5, 0.1));
      expect(RegionStyle.responsiveBorderWidth(33.6), closeTo(1.85, 0.1)); // 10x10 on 360 width
      expect(RegionStyle.responsiveBorderWidth(42.0), closeTo(2.31, 0.1)); // 8x8 on 360 width
      expect(RegionStyle.responsiveBorderWidth(48.0), closeTo(2.64, 0.1)); // 8x8 on 412 width
      expect(RegionStyle.responsiveBorderWidth(100.0), equals(3.0));
    });

    testWidgets('Directional edge ownership prevents double borders', (tester) async {
      final puzzle = generator.generate(size: 8, customSeed: 'border_ownership_test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 320,
              child: PuzzleBoard(
                puzzle: puzzle,
                cellStates: const {},
                onCellTap: (r, c) {},
              ),
            ),
          ),
        ),
      );

      final cells = tester.widgetList<PuzzleCell>(find.byType(PuzzleCell)).toList();
      expect(cells.length, equals(64));

      // For any internal edge between (r, c) and (r, c+1):
      // cell (r, c) has borderRight == (reg(r,c) != reg(r,c+1))
      // cell (r, c+1) has borderLeft == false (since c+1 > 0)
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 7; c++) {
          final left = cells.firstWhere((w) => w.cell.row == r && w.cell.column == c);
          final right = cells.firstWhere((w) => w.cell.row == r && w.cell.column == c + 1);

          expect(right.borderLeft, isFalse, reason: 'Internal left edge must not be drawn to avoid double-thick border');
          final diffRegion = puzzle.getRegionId(r, c) != puzzle.getRegionId(r, c + 1);
          expect(left.borderRight, equals(diffRegion));
        }
      }

      // For any internal edge between (r, c) and (r+1, c):
      // cell (r, c) has borderBottom == (reg(r,c) != reg(r+1,c))
      // cell (r+1, c) has borderTop == false (since r+1 > 0)
      for (int r = 0; r < 7; r++) {
        for (int c = 0; c < 8; c++) {
          final top = cells.firstWhere((w) => w.cell.row == r && w.cell.column == c);
          final bottom = cells.firstWhere((w) => w.cell.row == r + 1 && w.cell.column == c);

          expect(bottom.borderTop, isFalse, reason: 'Internal top edge must not be drawn to avoid double-thick border');
          final diffRegion = puzzle.getRegionId(r, c) != puzzle.getRegionId(r + 1, c);
          expect(top.borderBottom, equals(diffRegion));
        }
      }
    });
  });
}
