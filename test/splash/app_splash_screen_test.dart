import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/features/splash/widgets/app_splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSplashScreen (Studio Official Splash for Panda Zen)', () {
    testWidgets('renders Panda Zen title, app logo, and ghdinteractivestudio footer', (tester) async {
      const appLogoKey = Key('app_logo_widget');

      await tester.pumpWidget(
        const MaterialApp(
          home: AppSplashScreen(
            appName: 'Panda Zen',
            appLogo: SizedBox(
              key: appLogoKey,
              width: 100,
              height: 100,
            ),
            companyPrefix: 'from',
            companyName: 'ghdinteractivestudio',
            duration: Duration(milliseconds: 1000),
          ),
        ),
      );

      // Verify app name and studio branding
      expect(find.text('Panda Zen'), findsOneWidget);
      expect(find.text('from'), findsOneWidget);
      expect(find.text('ghdinteractivestudio'), findsOneWidget);
      expect(find.byKey(appLogoKey), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('calls onFinish callback after duration and exit transition', (tester) async {
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            appName: 'Panda Zen',
            duration: const Duration(milliseconds: 1000),
            exitDuration: const Duration(milliseconds: 200),
            entranceDuration: const Duration(milliseconds: 300),
            onFinish: () {
              finished = true;
            },
          ),
        ),
      );

      expect(finished, isFalse);

      await tester.pump(const Duration(milliseconds: 500));
      expect(finished, isFalse);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(finished, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('waits for preloadFuture before finishing', (tester) async {
      bool finished = false;
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            appName: 'Panda Zen',
            duration: const Duration(milliseconds: 500),
            exitDuration: const Duration(milliseconds: 100),
            preloadFuture: completer.future,
            onFinish: () {
              finished = true;
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));
      expect(finished, isFalse);

      completer.complete();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(finished, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('supports skipOnTap if enabled', (tester) async {
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSplashScreen(
            appName: 'Panda Zen',
            duration: const Duration(seconds: 10),
            exitDuration: const Duration(milliseconds: 100),
            skipOnTap: true,
            onFinish: () {
              finished = true;
            },
          ),
        ),
      );

      expect(finished, isFalse);

      await tester.tap(find.byType(AppSplashScreen));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(finished, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('fadeRoute creates a valid PageRouteBuilder', (tester) async {
      final route = AppSplashScreen.fadeRoute<void>(
        page: const Scaffold(body: Text('Home Page')),
      );

      expect(route, isA<PageRouteBuilder>());
      expect(route.transitionDuration, const Duration(milliseconds: 400));
    });
  });
}
