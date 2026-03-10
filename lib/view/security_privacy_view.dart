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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : AppColors.textLight;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
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
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: PlatformBackButton(color: textColor),
          ),
          title: Text(
            'Sanctuary Settings',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildSectionHeader('SECURITY PROTOCOLS'),
              const SizedBox(height: 20),
              _buildSecurityTile(
                context,
                'Credential Management',
                'Rotate your access keys',
                Icons.vpn_key_rounded,
                () => Navigator.pushNamed(context, AppRoutes.changePassword),
                isDark,
                borderColor,
                textColor,
                mutedTextColor,
                null,
                0,
              ),
              const SizedBox(height: 16),
              _buildSecurityTile(
                context,
                'Multi-Factor Auth',
                'Dual-layer verification status',
                Icons.verified_user_rounded,
                () => Navigator.pushNamed(context, AppRoutes.twoFactorAuth),
                isDark,
                borderColor,
                textColor,
                mutedTextColor,
                AppColors.success,
                1,
              ),
              const SizedBox(height: 16),
              _buildSecurityTile(
                context,
                'Biometric Gateway',
                'Face ID & Fingerprint access',
                Icons.fingerprint_rounded,
                () => Navigator.pushNamed(context, AppRoutes.faceIdBiometric),
                isDark,
                borderColor,
                textColor,
                mutedTextColor,
                AppColors.info,
                2,
              ),

              const SizedBox(height: 48),
              _buildSectionHeader('PRIVACY & INTEL'),
              const SizedBox(height: 20),
              _buildSecurityTile(
                context,
                'Profile Visibility',
                'Manage your public presence',
                Icons.visibility_rounded,
                () => Navigator.pushNamed(context, AppRoutes.profileVisibility),
                isDark,
                borderColor,
                textColor,
                mutedTextColor,
                null,
                3,
              ),
              const SizedBox(height: 16),
              _buildSecurityTile(
                context,
                'Intelligence Export',
                'Package your account data',
                Icons.document_scanner_rounded,
                () => Navigator.pushNamed(context, AppRoutes.dataExport),
                isDark,
                borderColor,
                textColor,
                mutedTextColor,
                null,
                4,
              ),
              const SizedBox(height: 16),
              _buildSecurityTile(
                context,
                'Policy Archives',
                'Review legal commitments',
                Icons.account_balance_rounded,
                () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                isDark,
                borderColor,
                textColor,
                mutedTextColor,
                null,
                5,
                showTrailing: true,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
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
    );
  }

  Widget _buildSecurityTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
    Color borderColor,
    Color textColor,
    Color mutedTextColor,
    Color? iconColor,
    int index, {
    bool showTrailing = false,
  }) {
    final color = iconColor ?? AppColors.primaryBlue;
    return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: mutedTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  showTrailing
                      ? Icons.open_in_new_rounded
                      : Icons.chevron_right_rounded,
                  color: mutedTextColor.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 200 + (index * 80)))
        .fadeIn()
        .slideY(begin: 0.1, end: 0);
  }
}
