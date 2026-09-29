import 'package:flutter/material.dart';
import '../../assets/cell_assets.dart';
import '../../assets/panda_assets.dart';
import '../models/cell.dart';
import '../models/region.dart';
import 'panda_reveal.dart';
import 'region_renderer.dart';
import 'selection_effect.dart';

class PuzzleCell extends StatefulWidget {
  final Cell cell;
  final Region region;
  final double size;
  final bool borderTop;
  final bool borderBottom;
  final bool borderLeft;
  final bool borderRight;
  final VoidCallback onTap;

  const PuzzleCell({
    super.key,
    required this.cell,
    required this.region,
    required this.size,
    required this.borderTop,
    required this.borderBottom,
    required this.borderLeft,
    required this.borderRight,
    required this.onTap,
  });

  @override
  State<PuzzleCell> createState() => _PuzzleCellState();
}

class _PuzzleCellState extends State<PuzzleCell> with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _hintController;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regionStyle = RegionStyle.forType(widget.region.visualType);

    Widget content;
    switch (widget.cell.state) {
      case CellState.revealedPanda:
        content = PandaReveal(size: widget.size);
        break;
      case CellState.revealedEmpty:
        content = Center(
          child: Container(
            width: widget.size * 0.28,
            height: widget.size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.brown.withValues(alpha: 0.35),
              border: Border.all(color: Colors.brown.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
        );
        break;
      case CellState.hinted:
        content = AnimatedBuilder(
          animation: _hintController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.amberAccent.withValues(alpha: 0.6 + 0.4 * _hintController.value),
                  width: 2.5,
                ),
                color: Colors.amber.withValues(alpha: 0.2 * _hintController.value),
              ),
              child: Center(
                child: Image.asset(
                  PandaAssets.hintButterfly,
                  width: widget.size * 0.7,
                  height: widget.size * 0.7,
                ),
              ),
            );
          },
        );
        break;
      case CellState.selected:
      case CellState.hidden:
        content = const SizedBox.shrink();
        break;
    }

    final isMistake = widget.cell.state == CellState.revealedEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isTapped = false),
      child: ShakeWidget(
        shake: isMistake,
        child: AnimatedScale(
          scale: _isTapped ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: CustomPaint(
            foregroundPainter: RegionBorderPainter(
              borderTop: widget.borderTop,
              borderBottom: widget.borderBottom,
              borderLeft: widget.borderLeft,
              borderRight: widget.borderRight,
              color: regionStyle.borderColor,
            ),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: regionStyle.backgroundColor,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(
                        CellAssets.defaultCell,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(child: content),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
