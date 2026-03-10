import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color:
              theme.textTheme.titleMedium?.color ??
              (theme.brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.textDark),
        ),
        title: Text(
          'Two-Factor Authentication',
          style: GoogleFonts.plusJakartaSans(
            color:
                theme.textTheme.titleMedium?.color ??
                (theme.brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.textDark),
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
                      AppColors.success.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
                      ),
                      AppColors.info.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.success.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.4 : 0.2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.success, AppColors.info],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    Text(
                      'Secure Your Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            theme.textTheme.titleMedium?.color ??
                            (theme.brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.textDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add an extra layer of protection to your account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color:
                            theme.textTheme.bodySmall?.color ??
                            (theme.brightness == Brightness.dark
                                ? Colors.white70
                                : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'CHOOSE AUTHENTICATION METHOD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.textTheme.bodySmall?.color ??
                      (theme.brightness == Brightness.dark
                          ? Colors.white60
                          : AppColors.textMuted),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Email 2FA
              _buildAuthMethodTile(
                context: context,
                icon: Icons.mail_outline_rounded,
                title: 'Email Verification',
                subtitle: 'Get a code via email when you sign in',
                value: _emailEnabled,
                color: AppColors.info,
                onChanged: (value) => setState(() => _emailEnabled = value),
              ),
              const SizedBox(height: 12),
              // SMS 2FA
              _buildAuthMethodTile(
                context: context,
                icon: Icons.sms_outlined,
                title: 'SMS Message',
                subtitle: 'Receive authentication code via SMS',
                value: _smsEnabled,
                color: AppColors.warning,
                onChanged: (value) => setState(() => _smsEnabled = value),
              ),
              const SizedBox(height: 12),
              // Authenticator App
              _buildAuthMethodTile(
                context: context,
                icon: Icons.phone_android_rounded,
                title: 'Authenticator App',
                subtitle: 'Use Google Authenticator or similar',
                value: _appEnabled,
                color: AppColors.success,
                onChanged: (value) => setState(() => _appEnabled = value),
              ),
              const SizedBox(height: 32),
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.4 : 0.2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'We recommend enabling at least one 2FA method for better security',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color:
                              theme.textTheme.bodyMedium?.color ??
                              (theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.textDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.3) : theme.dividerColor,
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
                    color:
                        theme.textTheme.titleMedium?.color ??
                        (theme.brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.textDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color:
                        theme.textTheme.bodySmall?.color ??
                        (theme.brightness == Brightness.dark
                            ? Colors.white70
                            : AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              inactiveThumbColor:
                  theme.textTheme.bodySmall?.color ??
                  (theme.brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.textMuted),
              inactiveTrackColor: theme.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}
