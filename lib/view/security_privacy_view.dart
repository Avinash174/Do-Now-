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

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const PlatformBackButton(color: AppColors.textDark),
        title: Text(
          'Security & Privacy',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('SECURITY SETTINGS', isSmallScreen),
              const SizedBox(height: 16),
              _buildSecurityTile(
                'Change Password',
                'Update your account password',
                Icons.lock_outline_rounded,
                () => Navigator.pushNamed(context, AppRoutes.changePassword),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                'Two-Factor Auth',
                'Add extra layer of security',
                Icons.shield_outlined,
                () => Navigator.pushNamed(context, AppRoutes.twoFactorAuth),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                'Face ID / Biometrics',
                'Use biometrics to unlock',
                Icons.face_unlock_rounded,
                () => Navigator.pushNamed(context, AppRoutes.faceIdBiometric),
                isSmallScreen,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('PRIVACY SETTINGS', isSmallScreen),
              const SizedBox(height: 16),
              _buildSecurityTile(
                'Profile Visibility',
                'Manage who can see your profile',
                Icons.visibility_outlined,
                () => Navigator.pushNamed(context, AppRoutes.profileVisibility),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                'Data Export',
                'Download your account data',
                Icons.download_rounded,
                () => Navigator.pushNamed(context, AppRoutes.dataExport),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                'Privacy Policy',
                'Read our privacy commitments',
                Icons.description_outlined,
                () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                isSmallScreen,
                showTrailing: true,
              ),
              const SizedBox(
                height: 100,
              ), // Added bottom spacing for full scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: isSmallScreen ? 11 : 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSecurityTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isSmallScreen, {
    bool showTrailing = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: isSmallScreen ? 18 : 22,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppColors.textLight,
          ),
        ),
        trailing: Icon(
          showTrailing
              ? Icons.open_in_new_rounded
              : Icons.chevron_right_rounded,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
