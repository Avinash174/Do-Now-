import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class TwoFactorAuthView extends StatefulWidget {
  const TwoFactorAuthView({super.key});

  @override
  State<TwoFactorAuthView> createState() => _TwoFactorAuthViewState();
}

class _TwoFactorAuthViewState extends State<TwoFactorAuthView> {
  bool _emailEnabled = false;
  bool _smsEnabled = false;
  bool _appEnabled = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Enhanced colors for better contrast in dark mode
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark
        ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
              Colors.white70
        : AppColors.textMuted;
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final borderColor = isDark
        ? theme.dividerColor.withValues(alpha: 0.2)
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
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: PlatformBackButton(color: textColor),
          title: Text(
            'Two-Factor Authentication',
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
                // Header card - Improved visibility
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                      width: isDark ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.4 : 0.05,
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
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
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Highly Secure Account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Protect your account with an extra verification layer when you sign in.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: mutedTextColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'CHOOSE YOUR METHOD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.primaryBlue.withValues(alpha: 0.9)
                          : AppColors.primaryBlue,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                // Email 2FA
                _buildAuthMethodTile(
                  context: context,
                  icon: Icons.alternate_email_rounded,
                  title: 'Email Security',
                  subtitle: 'Receive unique codes via your email',
                  value: _emailEnabled,
                  color: AppColors.info,
                  onChanged: (value) => setState(() => _emailEnabled = value),
                ),
                const SizedBox(height: 12),

                // SMS 2FA
                _buildAuthMethodTile(
                  context: context,
                  icon: Icons.sms_rounded,
                  title: 'SMS Message',
                  subtitle: 'Verify with text message alerts',
                  value: _smsEnabled,
                  color: AppColors.warning,
                  onChanged: (value) => setState(() => _smsEnabled = value),
                ),
                const SizedBox(height: 12),

                // Authenticator App
                _buildAuthMethodTile(
                  context: context,
                  icon: Icons.phonelink_lock_rounded,
                  title: 'Authenticator Tool',
                  subtitle: 'Use trusted 2FA apps like Google',
                  value: _appEnabled,
                  color: AppColors.success,
                  onChanged: (value) => setState(() => _appEnabled = value),
                ),

                const SizedBox(height: 32),

                // Info card for better UX
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(
                        alpha: isDark ? 0.3 : 0.15,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'For maximum protection, we recommend activating at least one method.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthMethodTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark ? Colors.white70 : AppColors.textMuted;
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.6) : borderColor,
          width: value ? 2 : 1,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(!value);
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: mutedTextColor,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.85,
          child: Switch.adaptive(
            value: value,
            activeColor: color,
            activeTrackColor: color.withValues(alpha: 0.4),
            onChanged: (val) {
              HapticFeedback.mediumImpact();
              onChanged(val);
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}
