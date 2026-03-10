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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 20,
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
                        AppColors.primaryAccent.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        AppColors.primaryBlue.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(
                        alpha: isDark ? 0.3 : 0.15,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
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
                      const SizedBox(height: 20),
                      Text(
                        'Privacy Control Center',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customize how you appear to others In the workspace',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Visibility Options
                _buildSectionHeader('PROFILE SCOPE'),
                const SizedBox(height: 16),
                _buildVisibilityOption(
                  context: context,
                  title: 'Public Access',
                  subtitle: 'Visible to everyone on the platform',
                  icon: Icons.public_rounded,
                  value: 'public',
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildVisibilityOption(
                  context: context,
                  title: 'Connections Only',
                  subtitle: 'Only your direct friends can view',
                  icon: Icons.group_rounded,
                  value: 'friends_only',
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildVisibilityOption(
                  context: context,
                  title: 'Encrypted Private',
                  subtitle: 'HIDDEN from everyone but yourself',
                  icon: Icons.lock_rounded,
                  value: 'private',
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),

                const SizedBox(height: 32),

                // Personal Info Visibility
                _buildSectionHeader('SENSITIVE INFORMATION'),
                const SizedBox(height: 16),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.mail_outline_rounded,
                  title: 'Display Email',
                  subtitle: 'Show your registered email address',
                  value: _showEmail,
                  onChanged: (value) => setState(() => _showEmail = value),
                  color: AppColors.info,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.phone_outlined,
                  title: 'Display Contact',
                  subtitle: 'Show your connected phone number',
                  value: _showPhone,
                  onChanged: (value) => setState(() => _showPhone = value),
                  color: AppColors.warning,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),

                const SizedBox(height: 32),

                // Activity & Interactions
                _buildSectionHeader('DYNAMIC INTERACTIONS'),
                const SizedBox(height: 16),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.message_outlined,
                  title: 'Direct Messaging',
                  subtitle: 'Allow users to reach out to you',
                  value: _allowMessages,
                  onChanged: (value) => setState(() => _allowMessages = value),
                  color: AppColors.success,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),
                _buildInfoVisibilityTile(
                  context: context,
                  icon: Icons.timeline_rounded,
                  title: 'Activity Status',
                  subtitle: 'Broadcast when you are currently online',
                  value: _showActivity,
                  onChanged: (value) => setState(() => _showActivity = value),
                  color: AppColors.primaryBlue,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryBlue,
          letterSpacing: 1.5,
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
    required Color cardColor,
    required Color borderColor,
  }) {
    final isSelected = _profileVisibility == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _profileVisibility = value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : borderColor,
            width: isSelected ? 2 : 1,
          ),
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(
                      alpha: isSelected ? 1.0 : 0.1,
                    ),
                    AppColors.primaryAccent.withValues(
                      alpha: isSelected ? 1.0 : 0.1,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryBlue : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.7)
                          : mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: 200.ms,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : mutedTextColor.withValues(alpha: 0.3),
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
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
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
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.3) : borderColor,
          width: value ? 2 : 1,
        ),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
