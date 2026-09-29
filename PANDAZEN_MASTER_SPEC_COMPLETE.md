# PANDA ZEN — MASTER SPECIFICATION FOR ANTIGRAVITY

> **Read this entire document before writing or modifying code.**
>
> This is the master specification for the Panda Zen mobile puzzle game.
> The supplied asset archive has been inspected and contains **228 entries**:
> **1 music track, 4 SFX, 35 cell assets, 6 environment assets, 12 panda assets, 93 region assets, 32 English UI assets and 32 French UI assets**, plus their source folders.

---

# 1. PRODUCT DEFINITION

## Game name
**Panda Zen**

## Genre
Cute premium relaxing logic puzzle.

## Core gameplay
The player must **FIND the hidden pandas in the correct cells**.
The player does **not freely place pandas as a construction tool**.
The puzzle engine secretly knows the solution. The board presents regions and logical constraints. The player taps cells to discover whether a panda is hidden there.

### Core loop
```text
Observe board
    ↓
Analyze regions / rows / columns / diagonal constraints
    ↓
Select a cell
    ↓
Reveal / search cell
    ↓
Panda found?
 ┌───────────────┴───────────────┐
 YES                             NO
 ↓                                ↓
Reveal panda                  Reveal empty
Success feedback              Mistake feedback
 ↓                                ↓
Continue deduction          Update mistake state
 └───────────────┬────────────────┘
                 ↓
        All pandas found?
          ┌──────┴──────┐
         NO             YES
         ↓               ↓
      Continue       Level Complete
```

# 2. IMPORTANT GAMEPLAY DISTINCTION
The implementation MUST use a hidden solution board.

# 3. PUZZLE RULES
Rule 1 — One panda per region: Each region contains exactly one panda.
Rule 2 — One panda per row: No row can contain more than one panda.
Rule 3 — One panda per column: No column can contain more than one panda.
Rule 4 — No diagonal adjacency: Two pandas cannot touch diagonally.
Rule 5 — Valid solution: Every generated puzzle must have at least one valid solution.
Rule 6 — Prefer unique solution: Production levels should have exactly one logical solution.
Rule 7 — Player discoveries do not change the solution: The hidden solution is immutable during gameplay.

# 4. PLAYER CELL STATES
```dart
enum CellState {
  hidden,
  selected,
  revealedEmpty,
  revealedPanda,
  hinted,
}
```

# 5. DO NOT PENALIZE LOGICALLY
The game should distinguish between revealing an empty cell and making an impossible move.
Gentle feedback: mistake counter, short invalid SFX, small cell shake. Do not instantly destroy the level after one wrong tap.

# 6. GAME DATA MODEL
Puzzle, Region, Cell, Solution, GameSession.

# 7. PUZZLE ENGINE
Independent services: PuzzleGenerator, PuzzleSolver, PuzzleValidator, DifficultyCalculator, DailyPuzzleGenerator.

# 8. GENERATION PIPELINE
1. Generate valid panda positions
2. Validate row constraints
3. Validate column constraints
4. Validate diagonal constraints
5. Generate connected regions
6. Ensure every region contains exactly one panda
7. Build puzzle
8. Run solver
9. Verify uniqueness
10. Calculate difficulty
11. Accept or regenerate

# 9. SOLVER
API:
- solve(Puzzle)
- hasSolution(Puzzle)
- hasUniqueSolution(Puzzle)
- validateSolution(Puzzle, PuzzleSolution)
Support: 4x4, 5x5, 6x6, 7x7, 8x8.

# 10. DIFFICULTY
Easy, Medium, Hard, Expert.

# 11. DAILY CHALLENGE
Deterministic seed: PANDA_ZEN_YYYY-MM-DD.

# 12. GAME PROGRESSION
Worlds & Levels.
World 1 — Bamboo Forest
World 2 — Moonlight Forest
World 3 — Snow Bamboo
World 4 — Panda Temple
World 5 — Spring Valley
World 6 — Rainy Forest

# 13. STAR SYSTEM
1, 2, or 3 stars based on completion, time, mistakes, hints. Offline.

# 14 & 15. ASSET STRUCTURE & MAPPING
Production:
assets/audio/music/
assets/audio/sfx/
assets/images/cells/
assets/images/environments/
assets/images/panda/
assets/images/regions/
assets/images/ui/en/
assets/images/ui/fr/
assets/asset_registry.json
