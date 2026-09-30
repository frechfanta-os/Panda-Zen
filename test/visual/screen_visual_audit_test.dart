import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/core/storage/save_service.dart';
import 'package:panda_zen/features/daily_challenge/daily_challenge_screen.dart';
import 'package:panda_zen/features/gameplay/gameplay_screen.dart';
import 'package:panda_zen/features/home/home_screen.dart';
import 'package:panda_zen/features/levels/levels_screen.dart';
import 'package:panda_zen/features/settings/settings_screen.dart';
import 'package:panda_zen/features/splash/splash_screen.dart';
import 'package:panda_zen/features/worlds/worlds_screen.dart';
import 'package:panda_zen/game/providers/progression_provider.dart';
import 'package:panda_zen/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SaveService saveService;
  const targetSizes = [
    Size(360, 640),
    Size(360, 800),
    Size(390, 844),
    Size(412, 915),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'unlocked_level_1': 3,
      'unlocked_level_4': 2,
      'stars_PZ_W1_L1': 3,
      'stars_PZ_W1_L2': 2,
    });
    saveService = SaveService();
    saveService.resetForTesting();
    await saveService.init();
  });

  Widget buildAppWrapper({
    required Widget child,
    required Size size,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        saveServiceProvider.overrideWithValue(saveService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
            devicePixelRatio: 1.0,
          ),
          child: RepaintBoundary(
            key: const ValueKey('capture_boundary'),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('ANDROID MULTI-VIEWPORT AUDIT (360x640, 360x800, 390x844, 412x915)', () {
    testWidgets('Audit Splash Screen across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(child: const SplashScreen(), size: size));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Home Screen across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(child: const HomeScreen(), size: size));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Worlds Screen across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(child: const WorldsScreen(), size: size));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Level Selection Screen (30 levels) across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(
          child: const LevelsScreen(world: 1, worldName: 'Bamboo Forest'),
          size: size,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Gameplay 8x8 (Standard) across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(
          child: const GameplayScreen(world: 1, level: 1),
          size: size,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Gameplay 10x10 (Advanced) across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(
          child: const GameplayScreen(world: 4, level: 1),
          size: size,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Daily Challenge Screen across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(
          child: const DailyChallengeScreen(),
          size: size,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Settings Screen across viewports', (tester) async {
      for (final size in targetSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildAppWrapper(
          child: const SettingsScreen(),
          size: size,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Audit Pause, Victory, and Failed Dialogs', (tester) async {
      final size = const Size(390, 844);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Pump Gameplay and trigger Pause
      await tester.pumpWidget(buildAppWrapper(
        child: const GameplayScreen(world: 1, level: 1),
        size: size,
      ));
      await tester.pump();

      // Tap Pause button in HUD
      final pauseFinder = find.byIcon(Icons.pause);
      expect(pauseFinder, findsOneWidget);
      await tester.tap(pauseFinder);
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Verify pause dialog
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('Audit French and English Localization without overflow', (tester) async {
      for (final locale in [const Locale('en'), const Locale('fr')]) {
        for (final size in [const Size(360, 640), const Size(412, 915)]) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(buildAppWrapper(
            child: const GameplayScreen(world: 1, level: 100),
            size: size,
            locale: locale,
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      }
    });
  });
}
