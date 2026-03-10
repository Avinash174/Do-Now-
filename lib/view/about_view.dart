import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';
import 'legal_view.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color:
              Theme.of(context).textTheme.bodyLarge?.color ??
              AppColors.textDark,
        ),
        title: Text(
          'About Do Now',
          style: GoogleFonts.plusJakartaSans(
            color:
                Theme.of(context).textTheme.bodyLarge?.color ??
                AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Real App Logo
            Center(
              child: Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'Do Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Version 1.0.0 (Build 1)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),

            _buildAboutCard(
              context,
              'Our Mission',
              'Simplifying productivity one task at a time. We believe that focus is the key to achieving great things.',
              isSmallScreen,
            ),
            const SizedBox(height: 16),
            _buildAboutCard(
              context,
              'Privacy First',
              'Your data belongs to you. We use end-to-end security to ensure your tasks stay private.',
              isSmallScreen,
            ),

            const SizedBox(height: 48),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalView(
                      title: 'Terms of Service',
                      content: LegalTexts.termsOfService,
                    ),
                  ),
                );
              },
              child: Text(
                'Terms of Service',
                style: GoogleFonts.plusJakartaSans(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalView(
                      title: 'Privacy Policy',
                      content: LegalTexts.privacyPolicy,
                    ),
                  ),
                );
              },
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.plusJakartaSans(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 Do Now Inc.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    String title,
    String content,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ??
                  AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
