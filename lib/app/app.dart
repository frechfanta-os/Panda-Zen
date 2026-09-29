import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/splash/splash_screen.dart';
import '../services/localization_service.dart';
import 'theme/game_theme.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

class PandaZenApp extends ConsumerWidget {
  const PandaZenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Panda Zen',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.zenTheme,
      locale: userLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
