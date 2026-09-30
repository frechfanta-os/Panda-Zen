import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/game/widgets/gameplay_hud.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

void main() {
  Widget buildTestableHud({
    required String title,
    required int elapsedSeconds,
    required int mistakes,
    required int maxMistakes,
    required VoidCallback onPause,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
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
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GameplayHud(
                title: title,
                elapsedSeconds: elapsedSeconds,
                mistakes: mistakes,
                maxMistakes: maxMistakes,
                onPause: onPause,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  group('GameplayHud Layout & Collision Prevention Tests', () {
    const targetScreens = [
      Size(360, 640),
      Size(360, 800),
      Size(390, 844),
      Size(412, 915),
    ];

    final testCases = [
      {'title': 'Level 1', 'seconds': 3, 'desc': 'Level 1 + 00:03'},
      {'title': 'Level 10', 'seconds': 85, 'desc': 'Level 10 + 01:25'},
      {'title': 'Level 99', 'seconds': 768, 'desc': 'Level 99 + 12:48'},
      {'title': 'Level 100', 'seconds': 5999, 'desc': 'Level 100 + 99:59'},
    ];

    for (final screen in targetScreens) {
      for (final tc in testCases) {
        testWidgets('Zero overflow on ${screen.width}x${screen.height} (${tc['desc']})', (tester) async {
          await tester.binding.setSurfaceSize(screen);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          bool pauseTapped = false;
          await tester.pumpWidget(
            buildTestableHud(
              title: tc['title'] as String,
              elapsedSeconds: tc['seconds'] as int,
              mistakes: 1,
              maxMistakes: 3,
              onPause: () => pauseTapped = true,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);

          // Verify text elements are visible
          expect(find.text(tc['title'] as String), findsOneWidget);

          // Verify timer format
          final minutes = ((tc['seconds'] as int) ~/ 60).toString().padLeft(2, '0');
          final seconds = ((tc['seconds'] as int) % 60).toString().padLeft(2, '0');
          expect(find.text('$minutes:$seconds'), findsOneWidget);

          // Verify level text and timer text do NOT collide/overlap
          final levelRect = tester.getRect(find.text(tc['title'] as String));
          final timerRect = tester.getRect(find.text('$minutes:$seconds'));
          expect(levelRect.right, lessThan(timerRect.left),
              reason: 'Level text right edge must not collide with timer left edge');

          // Verify pause button is tappable
          final pauseFinder = find.byIcon(Icons.pause);
          expect(pauseFinder, findsOneWidget);
          await tester.tap(pauseFinder);
          expect(pauseTapped, isTrue);
        });
      }
    }
  });

  group('GameplayHud Localization Tests (English & French)', () {
    testWidgets('Renders French localization cleanly with Niveau 100 without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestableHud(
          title: 'Niveau 100',
          elapsedSeconds: 5999,
          mistakes: 0,
          maxMistakes: 3,
          onPause: () {},
          locale: const Locale('fr'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Niveau 100'), findsOneWidget);
      expect(find.text('99:59'), findsOneWidget);

      final levelRect = tester.getRect(find.text('Niveau 100'));
      final timerRect = tester.getRect(find.text('99:59'));
      expect(levelRect.right, lessThan(timerRect.left));
    });

    testWidgets('Renders English localization with Level 100 without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestableHud(
          title: 'Level 100',
          elapsedSeconds: 5999,
          mistakes: 2,
          maxMistakes: 3,
          onPause: () {},
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Level 100'), findsOneWidget);
      expect(find.text('99:59'), findsOneWidget);

      final levelRect = tester.getRect(find.text('Level 100'));
      final timerRect = tester.getRect(find.text('99:59'));
      expect(levelRect.right, lessThan(timerRect.left));
    });
  });

  group('GameplayHud Accessibility & Semantics Tests', () {
    testWidgets('Provides correct semantic labels for screen readers', (tester) async {
      await tester.pumpWidget(
        buildTestableHud(
          title: 'Level 10',
          elapsedSeconds: 85,
          mistakes: 1,
          maxMistakes: 3,
          onPause: () {},
        ),
      );
      await tester.pumpAndSettle();

      // Check pause semantic button
      expect(
        find.bySemanticsLabel('Pause'),
        findsOneWidget,
      );

      // Verify exact level semantics without duplication
      expect(
        find.bySemanticsLabel('Level 10'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Level Level 10'),
        findsNothing,
      );

      // Check timer semantics
      expect(
        find.bySemanticsLabel(RegExp(r'01:25')),
        findsOneWidget,
      );

      // Check mistakes / lives semantics
      expect(
        find.bySemanticsLabel(RegExp(r'2.*Mistakes')),
        findsOneWidget,
      );
    });

    testWidgets('Prevents duplicate "Niveau Niveau" announcement in French', (tester) async {
      await tester.pumpWidget(
        buildTestableHud(
          title: 'Niveau 100',
          elapsedSeconds: 0,
          mistakes: 0,
          maxMistakes: 3,
          onPause: () {},
          locale: const Locale('fr'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Niveau 100'), findsOneWidget);
      expect(find.bySemanticsLabel('Niveau Niveau 100'), findsNothing);
    });
  });
}
