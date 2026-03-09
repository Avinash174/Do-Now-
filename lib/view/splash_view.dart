import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/app_colors.dart';
import '../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final initialRoute = await AppRoutes.getInitialRoute();
    if (mounted) {
      Navigator.pushReplacementNamed(context, initialRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryBlue,
                    size: 60,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn()
                .shimmer(delay: 800.ms, duration: 1500.ms),
            const SizedBox(height: 24),
            const Text(
              'Do Now',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.textDark,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            const Text(
              'Master your productivity',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
