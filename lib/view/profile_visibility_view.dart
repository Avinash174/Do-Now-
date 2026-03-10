import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class ProfileVisibilityView extends StatefulWidget {
  const ProfileVisibilityView({super.key});

  @override
  State<ProfileVisibilityView> createState() => _ProfileVisibilityViewState();
}

class _ProfileVisibilityViewState extends State<ProfileVisibilityView> {
  String _profileVisibility = 'public'; // public, private, friends_only
  bool _showEmail = false;
  bool _showPhone = false;
  bool _allowMessages = true;
  bool _showActivity = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor =
        theme.textTheme.titleLarge?.color ??
        (isDark ? Colors.white : AppColors.textDark);
    final mutedTextColor =
        theme.textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : AppColors.textLight);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: PlatformBackButton(color: textColor),
          title: Text(
            'Profile Visibility',
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
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.1),
                        AppColors.primaryBlue.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.visibility_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ).animate().scale(
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Manage Your Privacy',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Control who can see your profile and data',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Visibility Options
                Text(
                  'PROFILE VISIBILITY',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildVisibilityOption(
                  context: context,
                  title: 'Public',
                  subtitle: 'Anyone can view your profile',
                  icon: Icons.public_rounded,
                  value: 'public',
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),
                const SizedBox(height: 12),
                _buildVisibilityOption(
                  context: context,
                  title: 'Friends Only',
                  subtitle: 'Only your friends can view',
                  icon: Icons.group_rounded,
                  value: 'friends_only',
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),
                const SizedBox(height: 12),
                _buildVisibilityOption(
                  context: context,
                  title: 'Private',
                  subtitle: 'Only you can see your profile',
                  icon: Icons.lock_rounded,
                  value: 'private',
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),

                const SizedBox(height: 32),

                // Personal Info Visibility
                Text(
                  'PERSONAL INFORMATION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.mail_outline_rounded,
                  title: 'Show Email Address',
                  subtitle: 'Allow others to see your email',
                  value: _showEmail,
                  onChanged: (value) => setState(() => _showEmail = value),
                  color: AppColors.info,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),
                const SizedBox(height: 12),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.phone_outlined,
                  title: 'Show Phone Number',
                  subtitle: 'Allow others to see your phone',
                  value: _showPhone,
                  onChanged: (value) => setState(() => _showPhone = value),
                  color: AppColors.warning,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),

                const SizedBox(height: 32),

                // Activity & Interactions
                Text(
                  'ACTIVITY & INTERACTIONS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.message_outlined,
                  title: 'Allow Messages',
                  subtitle: 'Others can send you messages',
                  value: _allowMessages,
                  onChanged: (value) => setState(() => _allowMessages = value),
                  color: AppColors.success,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),
                const SizedBox(height: 12),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.timeline_rounded,
                  title: 'Show Activity Status',
                  subtitle: 'Let others see when you\'re active',
                  value: _showActivity,
                  onChanged: (value) => setState(() => _showActivity = value),
                  color: AppColors.primaryBlue,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color textColor,
    required Color mutedTextColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _profileVisibility == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _profileVisibility = value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.primaryAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryBlue : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.7)
                          : mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : theme.dividerColor.withValues(alpha: 0.2),
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoVisibilityTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
    required Color textColor,
    required Color mutedTextColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? color.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.1),
          width: value ? 2 : 1,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.8), color],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
            activeColor: color,
            activeTrackColor: color.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
