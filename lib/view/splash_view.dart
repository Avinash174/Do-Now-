import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../routes/app_routes.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    // Hide status bar on splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startNavigation();
  }

  @override
  void dispose() {
    // Restore status bar when leaving splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  Future<void> _startNavigation() async {
    try {
      // Run both the minimum splash duration and the route logic in parallel
      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 3)),
        AppRoutes.getInitialRoute(),
      ]);

      final nextRoute = results[1] as String;

      if (!mounted) return;

      // Navigate to the next screen
      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e) {
      debugPrint('Navigation Error: $e');
      // Fallback in case of error
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo.png', width: 140, height: 140)
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn()
                .shimmer(delay: 800.ms, duration: 1500.ms),
          ],
        ),
      ),
    );
  }
}
