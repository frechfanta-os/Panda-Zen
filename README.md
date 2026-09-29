# 🐼 Panda Zen

[![Flutter CI](https://github.com/frechfanta-os/Panda-Zen/actions/workflows/flutter_test.yml/badge.svg)](https://github.com/frechfanta-os/Panda-Zen/actions/workflows/flutter_test.yml)
[![Android Build](https://github.com/frechfanta-os/Panda-Zen/actions/workflows/android_build.yml/badge.svg)](https://github.com/frechfanta-os/Panda-Zen/actions/workflows/android_build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)](https://flutter.dev)

> **Panda Zen** is a premium, cute, relaxing logic puzzle game built with Flutter and Riverpod.
> Discover hidden pandas in enchanted bamboo forests through pure deductive reasoning!

---

## 🎋 Gameplay & Logic Rules

In **Panda Zen**, the player's objective is to **discover the hidden pandas** in the grid. The puzzle engine secretly generates a valid, unique solution. The player examines the visible region boundaries and deduces cell contents without guessing.

### The 4 Zen Rules (Star Battle Variant)
1. **One Panda per Region**: Each connected region contains exactly **one** panda.
2. **One Panda per Row**: Each row contains at most **one** panda.
3. **One Panda per Column**: Each column contains at most **one** panda.
4. **No Diagonal Adjacency**: Pandas can never touch diagonally (nor orthogonally).

---

## 🌸 Features

- **Procedural Level Generator & Solver**:
  - Deterministic generation with backtracking solver and uniqueness verification.
  - Generates 4×4 up to 8×8 boards with varied region shapes.
  - Multi-source BFS region growth for organic, aesthetic puzzle topologies.
- **6 Enchanted Worlds (60 handcrafted & procedural levels)**:
  - 🎋 World 1: Bamboo Forest (*Forêt de Bambous*)
  - 🌕 World 2: Moonlight Forest (*Forêt Clair de Lune*)
  - ❄️ World 3: Snow Bamboo (*Bambous Enneigés*)
  - ⛩️ World 4: Panda Temple (*Temple du Panda*)
  - 🌸 World 5: Spring Valley (*Vallée du Printemps*)
  - 🌧️ World 6: Rainy Forest (*Forêt Pluvieuse*)
- **Daily Challenge Mode**:
  - Deterministic daily seed (`PANDA_ZEN_YYYY-MM-DD`).
  - Same daily puzzle for all players globally each day.
- **Bilingual Support (English & French)**:
  - Full native localization (`app_en.arb` & `app_fr.arb`).
  - Dual localized asset sets (`UI-EN` and `UI-FR`) mapped seamlessly via `UiAssets`.
- **Zen Audio Experience**:
  - Soothing background music theme.
  - Dedicated sound effects: tile reveal, panda discovery, gentle mistake feedback, hints.
- **Offline & Battery Friendly**:
  - Complete local state persistence (`SaveService` with `shared_preferences`).
  - No required network connection or mandatory accounts.

---

## 🎨 Asset Architecture

All 215 game assets are registered in `assets/asset_registry.json` and resolved through typed asset helpers:
- **Audio**: `panda_zen_main_theme.mp3`, `correct_tile.mp3`, `hint.mp3`, `invalid_move.mp3`, `panda_place.mp3`.
- **Environments**: 6 distinct illustrated world backgrounds.
- **Panda Poses**: 12 unique panda animations and visual states.
- **Regions**: 93 high-resolution organic region tiles.
- **UI Elements**: 32 English (`UI-EN`) and 32 French (`UI-FR`) sprites.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: `flutter_riverpod` (reactive game session, progression, audio, settings)
- **Audio Engine**: `audioplayers` with lifecycle management
- **Localization**: Flutter `gen-l10n` (`intl`)
- **Package ID**: `com.ghdinteractivestudio.pandazen`

```
lib/
├── config/              # App constants, routes, asset registry & theme
├── l10n/                # ARB translation files (EN, FR)
├── models/              # Immutable data models (Puzzle, Region, Cell, GameSession)
├── providers/           # Riverpod state notifiers (GameNotifier, ProgressionNotifier)
├── screens/             # UI screens (Splash, Home, Worlds, Levels, Gameplay, Daily, Settings)
├── services/            # Engine services (Generator, Solver, Validator, Audio, Storage)
└── widgets/             # Reusable UI components (PuzzleBoard, PuzzleCell, HUD, Dialogs)
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Java 17+ (for Android builds)

### Run Locally
```bash
# Clone the repository
git clone https://github.com/frechfanta-os/Panda-Zen.git
cd Panda-Zen

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run static analysis
flutter analyze

# Run unit tests
flutter test

# Launch the app
flutter run
```

### Build Releases
```bash
# Build Android Release APK
flutter build apk --release

# Build Android App Bundle (.aab)
flutter build appbundle --release
```

---

## 📄 License
This project is proprietary and copyright © 2026 GHD Interactive Studio.
All assets and source code are protected.
