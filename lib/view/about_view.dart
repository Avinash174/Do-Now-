import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';
import 'legal_view.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark ? Colors.white70 : AppColors.textLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: PlatformBackButton(color: textColor),
          ),
          title: Text(
            'System Protocol',
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: isSmallScreen ? 18 : 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Premium App Logo Container
              Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryBlue.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: isDark ? 0.3 : 0.2,
                            ),
                            blurRadius: 40,
                            spreadRadius: -5,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0A0A0A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(37),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(33),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primaryBlue,
                                    size: 60,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .rotate(begin: -0.05, end: 0),

              const SizedBox(height: 32),

              Text(
                'Do Now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'BEYOND PRODUCTIVITY • V1.0.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 56),

              _buildGlassCard(
                context,
                'Core Directive',
                'Simplifying human potential through streamlined task orchestration. Focus is the ultimate weapon.',
                isDark,
                size,
                0,
              ),

              const SizedBox(height: 20),

              _buildGlassCard(
                context,
                'Sanctified Data',
                'Advanced encryption measures ensure your directives remain private. Your data is your sovereign territory.',
                isDark,
                size,
                100,
              ),

              const SizedBox(height: 56),

              _buildLegalLink(
                context,
                'Terms of Service',
                LegalTexts.termsOfService,
                textColor,
              ).animate(delay: 600.ms).fadeIn(),

              const SizedBox(height: 12),

              _buildLegalLink(
                context,
                'Privacy Protocol',
                LegalTexts.privacyPolicy,
                textColor,
              ).animate(delay: 700.ms).fadeIn(),

              const SizedBox(height: 48),

              Text(
                '© 2026 DO NOW AUTONOMY INC.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: mutedTextColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ).animate(delay: 800.ms).fadeIn(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    String title,
    String content,
    bool isDark,
    Size size,
    int delay,
  ) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textDark.withValues(alpha: 0.8),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 400 + delay))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildLegalLink(
    BuildContext context,
    String label,
    String content,
    Color textColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LegalView(title: label, content: content),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
