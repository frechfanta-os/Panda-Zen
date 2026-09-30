import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A highly customizable, reusable Flutter splash screen widget inspired by
/// the official Meta / Instagram splash screen and adapted for GHD Interactive Studio.
///
/// Features:
/// - Smooth entrance animation: progressive subtle zoom (scale 0.78 -> 1.0) with ease-out fade.
/// - Modern, centered typography with refined letter spacing.
/// - Bottom footer with "from [company]" layout and subtle synchronized fade-in.
/// - Dedicated studio presets (Zen Jade, Golden Zen, Arcane, Meta, Instagram).
/// - Automatic Dark/Light mode contrast detection or manual [ThemeMode] override.
/// - Threads kinetic motion: gentle floating & breathing wave while active.
/// - Fluid exit transition (zoom-through dissolve + fade) before invoking [onFinish].
/// - Optional [preloadFuture] support to wait for asynchronous background tasks.
/// - Edge-to-edge system UI styling matching theme brightness.
class AppSplashScreen extends StatefulWidget {
  /// Name of the application displayed prominently in the center.
  /// Defaults to "Panda Zen".
  final String appName;

  /// Custom icon or logo displayed above [appName].
  final Widget? appLogo;

  /// Custom text style for [appName]. If provided, merges with the theme-aware default style.
  final TextStyle? appNameStyle;

  /// Custom font family for [appName]. Defaults to 'Caveat'.
  final String? appNameFontFamily;

  /// Custom fallback font families for [appName].
  final List<String>? appNameFontFamilyFallback;

  /// Small prefix displayed above the company name in the footer.
  /// Defaults to "from".
  final String companyPrefix;

  /// Custom text style for [companyPrefix].
  final TextStyle? companyPrefixStyle;

  /// Company or studio name displayed in the footer.
  /// Defaults to "ghdinteractivestudio".
  final String companyName;

  /// Custom text style for [companyName].
  final TextStyle? companyNameStyle;

  /// Optional company logo or icon displayed alongside [companyName].
  final Widget? companyLogo;

  /// Optional gradient applied to [companyName].
  final Gradient? companyNameGradient;

  /// Callback executed when the splash animation and hold time complete.
  final FutureOr<void> Function()? onFinish;

  /// Optional background preloading task.
  /// If provided, the splash screen will wait for both [duration] AND [preloadFuture]
  /// to complete before initiating the exit transition.
  final Future<void>? preloadFuture;

  /// Total duration the splash screen stays visible before starting the exit transition.
  /// Defaults to 2.5 seconds (2500 ms).
  final Duration duration;

  /// Duration of the entrance animation.
  /// Defaults to 800 ms.
  final Duration entranceDuration;

  /// Duration of the exit transition.
  /// Defaults to 400 ms.
  final Duration exitDuration;

  /// Theme mode: [ThemeMode.system] (default), [ThemeMode.dark], or [ThemeMode.light].
  final ThemeMode themeMode;

  /// Custom background color override. If null, resolves according to [themeMode].
  final Color? backgroundColor;

  /// Custom background gradient override.
  final Gradient? backgroundGradient;

  /// Initial scale of the central element (appName + appLogo) before animating to 1.0.
  /// Defaults to 0.78 (signature pop scale).
  final double scaleBegin;

  /// Animation curve for the entrance zoom and fade.
  /// Defaults to [Curves.easeOutBack].
  final Curve curve;

  /// Animation curve for the exit transition.
  /// Defaults to [Curves.easeInOutCubic].
  final Curve exitCurve;

  /// Whether to play a smooth fade/scale exit transition before calling [onFinish].
  /// Defaults to true.
  final bool showExitTransition;

  /// Whether to enable subtle organic floating & breathing kinetic motion
  /// while the title is displayed.
  /// Defaults to true.
  final bool enableThreadsMotion;

  /// Duration of each oscillation cycle of kinetic motion.
  /// Defaults to 1200 ms.
  final Duration motionDuration;

  /// Exit scale factor when transitioning out (zoom-through dissolve).
  /// Defaults to 1.20.
  final double exitScaleEnd;

  /// Vertical spacing between [appLogo] and [appName].
  /// Defaults to 16.0.
  final double centerSpacing;

  /// Vertical spacing between [companyPrefix] and [companyName] in the footer.
  /// Defaults to 4.0.
  final double footerSpacing;

  /// Horizontal spacing between [companyLogo] and [companyName] when both are present.
  /// Defaults to 8.0.
  final double companyLogoSpacing;

  /// Bottom padding for the footer inside the SafeArea.
  /// Defaults to 32.0.
  final double footerBottomPadding;

  /// Custom SystemUiOverlayStyle override for status and navigation bars.
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Whether tapping the screen skips immediately to the exit transition.
  /// Defaults to false.
  final bool skipOnTap;

  const AppSplashScreen({
    super.key,
    this.appName = 'Panda Zen',
    this.appLogo,
    this.appNameStyle,
    this.appNameFontFamily = 'Caveat',
    this.appNameFontFamilyFallback = const [
      'Dancing Script',
      'Brush Script MT',
      'cursive',
      'sans-serif',
    ],
    this.companyPrefix = 'from',
    this.companyPrefixStyle,
    this.companyName = 'ghdinteractivestudio',
    this.companyNameStyle,
    this.companyLogo,
    this.companyNameGradient,
    this.onFinish,
    this.preloadFuture,
    this.duration = const Duration(milliseconds: 2500),
    this.entranceDuration = const Duration(milliseconds: 800),
    this.exitDuration = const Duration(milliseconds: 400),
    this.themeMode = ThemeMode.system,
    this.backgroundColor,
    this.backgroundGradient,
    this.scaleBegin = 0.78,
    this.curve = Curves.easeOutBack,
    this.exitCurve = Curves.easeInOutCubic,
    this.showExitTransition = true,
    this.enableThreadsMotion = true,
    this.motionDuration = const Duration(milliseconds: 1200),
    this.exitScaleEnd = 1.20,
    this.centerSpacing = 16.0,
    this.footerSpacing = 4.0,
    this.companyLogoSpacing = 8.0,
    this.footerBottomPadding = 32.0,
    this.systemUiOverlayStyle,
    this.skipOnTap = false,
  });

  /// Preset Zen Jade gradient (Green/Emerald/Mint for Panda Zen).
  static const Gradient zenJadeGradient = LinearGradient(
    colors: [
      Color(0xFF4CAF50),
      Color(0xFF81C784),
      Color(0xFFA5D6A7),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Preset Golden Zen gradient (Amber/Gold).
  static const Gradient goldenZenGradient = LinearGradient(
    colors: [
      Color(0xFFFFB300),
      Color(0xFFFFD54F),
      Color(0xFFFFF176),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Preset Meta gradient (Blue tone).
  static const Gradient metaGradient = LinearGradient(
    colors: [
      Color(0xFF0064E0),
      Color(0xFF0082FB),
      Color(0xFF00C6FF),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Preset Instagram gradient (Orange/Pink/Purple).
  static const Gradient instagramGradient = LinearGradient(
    colors: [
      Color(0xFFF58529),
      Color(0xFFDD2A7B),
      Color(0xFF8134AF),
      Color(0xFF515BD4),
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  /// Preset Arcane gradient (Purple/Violet/Cyan).
  static const Gradient arcaneGradient = LinearGradient(
    colors: [
      Color(0xFF9D4EDD),
      Color(0xFFC77DFF),
      Color(0xFF38BDF8),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Utility to create an ultra-smooth fade page route for seamless transition
  /// from the splash screen to the target route.
  static PageRouteBuilder<T> fadeRoute<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _motionController;
  late final AnimationController _exitController;

  late final Animation<double> _centerScaleAnimation;
  late final Animation<double> _centerFadeAnimation;
  late final Animation<Offset> _centerSlideAnimation;

  late final Animation<Offset> _motionOffsetAnimation;
  late final Animation<double> _motionScaleAnimation;
  late final Animation<double> _motionRotationAnimation;

  late final Animation<double> _footerFadeAnimation;
  late final Animation<Offset> _footerSlideAnimation;

  late final Animation<double> _exitFadeAnimation;
  late final Animation<double> _exitScaleAnimation;

  Timer? _splashTimer;
  bool _isExiting = false;
  bool _timerDone = false;
  bool _preloadDone = false;

  @override
  void initState() {
    super.initState();

    _preloadDone = widget.preloadFuture == null;

    _entranceController = AnimationController(
      vsync: this,
      duration: widget.entranceDuration,
    );

    _motionController = AnimationController(
      vsync: this,
      duration: widget.motionDuration,
    );

    _exitController = AnimationController(
      vsync: this,
      duration: widget.exitDuration,
    );

    // Entrance: bouncy pop + fade + slight vertical reveal
    _centerScaleAnimation = Tween<double>(
      begin: widget.scaleBegin,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: widget.curve,
      ),
    );

    _centerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    _centerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Threads kinetic idle motion: gentle float, breathing scale, and organic tilt wave
    _motionOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -8.0),
    ).animate(
      CurvedAnimation(
        parent: _motionController,
        curve: Curves.easeInOutSine,
      ),
    );

    _motionScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.035,
    ).animate(
      CurvedAnimation(
        parent: _motionController,
        curve: Curves.easeInOutSine,
      ),
    );

    _motionRotationAnimation = Tween<double>(
      begin: -0.012,
      end: 0.012,
    ).animate(
      CurvedAnimation(
        parent: _motionController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Footer entrance
    _footerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );

    _footerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // Exit transition: zoom forward and fade out
    _exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: widget.exitCurve,
      ),
    );

    _exitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.exitScaleEnd,
    ).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: widget.exitCurve,
      ),
    );

    _entranceController.forward().whenComplete(() {
      if (mounted && !_isExiting && widget.enableThreadsMotion) {
        _motionController.repeat(reverse: true);
      }
    });

    _startSplashSequence();
  }

  void _startSplashSequence() {
    _splashTimer = Timer(widget.duration, () {
      _timerDone = true;
      _checkAndTriggerExit();
    });

    if (widget.preloadFuture != null) {
      widget.preloadFuture!.then((_) {
        _preloadDone = true;
        _checkAndTriggerExit();
      }).catchError((_) {
        _preloadDone = true;
        _checkAndTriggerExit();
      });
    }
  }

  void _checkAndTriggerExit() {
    if (!mounted || _isExiting) return;
    if (_timerDone && _preloadDone) {
      _triggerExit();
    }
  }

  void _triggerExit() {
    if (!mounted || _isExiting) return;
    _isExiting = true;
    _splashTimer?.cancel();
    _motionController.stop();

    if (widget.showExitTransition) {
      _exitController.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.onFinish?.call();
        }
      });
      _exitController.forward();
    } else {
      widget.onFinish?.call();
    }
  }

  void _handleTap() {
    if (widget.skipOnTap && !_isExiting) {
      _triggerExit();
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _motionController.stop();
    _motionController.dispose();
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  bool _isDarkMode(BuildContext context) {
    switch (widget.themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        final brightness = MediaQuery.maybePlatformBrightnessOf(context) ??
            Theme.of(context).brightness;
        return brightness == Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode(context);

    // Color definitions adapted for Panda Zen
    final defaultBgColor = isDark
        ? const Color(0xFF1B3B2B)
        : const Color(0xFFF1F8E9);

    final resolvedBgColor = widget.backgroundColor ?? defaultBgColor;

    final defaultAppNameColor = isDark
        ? const Color(0xFFE8F5E9)
        : const Color(0xFF1B3B2B);

    final defaultPrefixColor = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF4E7D59);

    final defaultCompanyColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1B3B2B);

    final resolvedAppNameStyle = TextStyle(
      fontSize: 42.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      color: defaultAppNameColor,
    ).merge(widget.appNameStyle);

    final resolvedPrefixStyle = TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
      color: defaultPrefixColor,
    ).merge(widget.companyPrefixStyle);

    final resolvedCompanyStyle = TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: defaultCompanyColor,
    ).merge(widget.companyNameStyle);

    // Company footer content
    Widget companyContent = Text(
      widget.companyName,
      style: resolvedCompanyStyle,
      textAlign: TextAlign.center,
    );

    if (widget.companyNameGradient != null) {
      companyContent = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) =>
            widget.companyNameGradient!.createShader(bounds),
        child: companyContent,
      );
    }

    if (widget.companyLogo != null) {
      companyContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.companyLogo!,
          SizedBox(width: widget.companyLogoSpacing),
          companyContent,
        ],
      );
    }

    // Center content (Logo + App Name)
    final List<Widget> centerChildren = [];
    if (widget.appLogo != null) {
      centerChildren.add(widget.appLogo!);
      if (widget.appName.isNotEmpty) {
        centerChildren.add(SizedBox(height: widget.centerSpacing));
      }
    }
    if (widget.appName.isNotEmpty) {
      centerChildren.add(
        Text(
          widget.appName,
          style: resolvedAppNameStyle,
          textAlign: TextAlign.center,
        ),
      );
    }

    // System UI overlay style
    final defaultOverlay = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: resolvedBgColor,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: resolvedBgColor,
          );

    final overlayStyle = widget.systemUiOverlayStyle ?? defaultOverlay;

    Widget body = AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: resolvedBgColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: widget.backgroundGradient != null
              ? BoxDecoration(gradient: widget.backgroundGradient)
              : null,
          child: Stack(
            children: [
              // Center Content with Threads sequence:
              // 1. Entrance Pop + Slide
              // 2. Kinetic Floating & Breathing wave ("bouge")
              // 3. Exit Zoom-through & Fade ("disparaît")
              Center(
                child: FadeTransition(
                  opacity: _exitFadeAnimation,
                  child: ScaleTransition(
                    scale: _exitScaleAnimation,
                    child: AnimatedBuilder(
                      animation: _motionController,
                      builder: (context, child) {
                        if (!widget.enableThreadsMotion) return child!;
                        return Transform.translate(
                          offset: _motionOffsetAnimation.value,
                          child: Transform.rotate(
                            angle: _motionRotationAnimation.value,
                            child: Transform.scale(
                              scale: _motionScaleAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: FadeTransition(
                        opacity: _centerFadeAnimation,
                        child: ScaleTransition(
                          scale: _centerScaleAnimation,
                          child: SlideTransition(
                            position: _centerSlideAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: centerChildren,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Footer Content ("from [company]")
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.footerBottomPadding,
                    ),
                    child: FadeTransition(
                      opacity: _exitFadeAnimation,
                      child: FadeTransition(
                        opacity: _footerFadeAnimation,
                        child: SlideTransition(
                          position: _footerSlideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.companyPrefix.isNotEmpty) ...[
                                Text(
                                  widget.companyPrefix,
                                  style: resolvedPrefixStyle,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: widget.footerSpacing),
                              ],
                              companyContent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.skipOnTap) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: body,
      );
    }

    return body;
  }
}
