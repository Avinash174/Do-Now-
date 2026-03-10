import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';
import '../routes/app_routes.dart';

class SecurityPrivacyView extends StatelessWidget {
  const SecurityPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Standardized theme colors
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark ? Colors.white70 : AppColors.textLight;
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final borderColor = isDark
        ? theme.dividerColor.withValues(alpha: 0.15)
        : AppColors.borderColor;

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
          scrolledUnderElevation: 0,
          leading: PlatformBackButton(color: textColor),
          title: Text(
            'Security & Privacy',
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  'SECURITY & AUTHENTICATION',
                  isSmallScreen,
                ),
                const SizedBox(height: 16),
                _buildSecurityTile(
                  context,
                  'Password Management',
                  'Change your account password regularly',
                  Icons.lock_person_rounded,
                  () => Navigator.pushNamed(context, AppRoutes.changePassword),
                  isSmallScreen,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityTile(
                  context,
                  'Secondary Verification',
                  'Enable Two-Factor Authentication',
                  Icons.verified_user_rounded,
                  () => Navigator.pushNamed(context, AppRoutes.twoFactorAuth),
                  isSmallScreen,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  iconColor: AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildSecurityTile(
                  context,
                  'App Access Biometrics',
                  'Unlock with Face ID or Fingerprint',
                  Icons.face_unlock_rounded,
                  () => Navigator.pushNamed(context, AppRoutes.faceIdBiometric),
                  isSmallScreen,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  iconColor: AppColors.info,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'PRIVACY & DATA', isSmallScreen),
                const SizedBox(height: 16),
                _buildSecurityTile(
                  context,
                  'Profile visibility',
                  'Decide who sees your workspace',
                  Icons.visibility_rounded,
                  () =>
                      Navigator.pushNamed(context, AppRoutes.profileVisibility),
                  isSmallScreen,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityTile(
                  context,
                  'Personal Data Export',
                  'Download all your account activity',
                  Icons.data_exploration_rounded,
                  () => Navigator.pushNamed(context, AppRoutes.dataExport),
                  isSmallScreen,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityTile(
                  context,
                  'Policy Agreements',
                  'Review our privacy commitments',
                  Icons.policy_rounded,
                  () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                  isSmallScreen,
                  showTrailing: true,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: isSmallScreen ? 11 : 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryBlue,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSecurityTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isSmallScreen, {
    bool showTrailing = false,
    required Color textColor,
    required Color mutedTextColor,
    required Color cardColor,
    required Color borderColor,
    Color? iconColor,
  }) {
    final color = iconColor ?? AppColors.primaryBlue;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 14 : 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 11 : 12,
            color: mutedTextColor,
          ),
        ),
        trailing: Icon(
          showTrailing
              ? Icons.arrow_outward_rounded
              : Icons.chevron_right_rounded,
          color: mutedTextColor.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
