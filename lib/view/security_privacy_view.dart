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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color: theme.textTheme.bodyLarge?.color ?? AppColors.textDark,
        ),
        title: Text(
          'Security & Privacy',
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.titleLarge?.color ?? AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
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
              _buildSectionHeader(context, 'SECURITY SETTINGS', isSmallScreen),
              const SizedBox(height: 16),
              _buildSecurityTile(
                context,
                'Change Password',
                'Update your account password',
                Icons.lock_outline_rounded,
                () => Navigator.pushNamed(context, AppRoutes.changePassword),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                context,
                'Two-Factor Auth',
                'Add extra layer of security',
                Icons.shield_outlined,
                () => Navigator.pushNamed(context, AppRoutes.twoFactorAuth),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                context,
                'Face ID / Biometrics',
                'Use biometrics to unlock',
                Icons.face_unlock_rounded,
                () => Navigator.pushNamed(context, AppRoutes.faceIdBiometric),
                isSmallScreen,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'PRIVACY SETTINGS', isSmallScreen),
              const SizedBox(height: 16),
              _buildSecurityTile(
                context,
                'Profile Visibility',
                'Manage who can see your profile',
                Icons.visibility_outlined,
                () => Navigator.pushNamed(context, AppRoutes.profileVisibility),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                context,
                'Data Export',
                'Download your account data',
                Icons.download_rounded,
                () => Navigator.pushNamed(context, AppRoutes.dataExport),
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSecurityTile(
                context,
                'Privacy Policy',
                'Read our privacy commitments',
                Icons.description_outlined,
                () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                isSmallScreen,
                showTrailing: true,
              ),
              const SizedBox(height: 100),
            ],
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
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: isSmallScreen ? 11 : 12,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).primaryColor,
        letterSpacing: 1.0,
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
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
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
            color: theme.textTheme.titleMedium?.color ?? AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 11 : 12,
            color: theme.textTheme.bodySmall?.color ?? AppColors.textLight,
          ),
        ),
        trailing: Icon(
          showTrailing
              ? Icons.open_in_new_rounded
              : Icons.chevron_right_rounded,
          color: theme.textTheme.bodySmall?.color ?? AppColors.textLight,
          size: 20,
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
