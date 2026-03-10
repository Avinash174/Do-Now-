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
            'Security Protocol',
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
              // Enhanced Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF252525), const Color(0xFF1A1A1A)]
                        : [Colors.white, const Color(0xFFF8F9FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 45,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Account Fortress',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Double your defense. Deploy a secondary verification layer to secure your assets.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: mutedTextColor,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 20),
                child: Row(
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
                      'AUTHENTICATION VECTORS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              _buildAuthTile(
                icon: Icons.alternate_email_rounded,
                title: 'Email Vector',
                subtitle: 'Secure code via encrypted mail',
                value: _emailEnabled,
                color: const Color(0xFF4C84FF),
                onChanged: (val) => setState(() => _emailEnabled = val),
                index: 0,
              ),
              const SizedBox(height: 16),
              _buildAuthTile(
                icon: Icons.phonelink_ring_rounded,
                title: 'SMS Transmission',
                subtitle: 'Verification via mobile network',
                value: _smsEnabled,
                color: const Color(0xFFFF9F43),
                onChanged: (val) => setState(() => _smsEnabled = val),
                index: 1,
              ),
              const SizedBox(height: 16),
              _buildAuthTile(
                icon: Icons.vibration_rounded,
                title: 'Authenticator Core',
                subtitle: 'Dynamic time-based tokens',
                value: _appEnabled,
                color: const Color(0xFF28C76F),
                onChanged: (val) => setState(() => _appEnabled = val),
                index: 2,
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(
                    alpha: isDark ? 0.1 : 0.05,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Protocol recommendation: Initialize at least one vector for operational continuity.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.textLight;

    return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(!value);
          },
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: value
                    ? color.withValues(alpha: 0.5)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05)),
                width: value ? 2 : 1.5,
              ),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 20),
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
                Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: value,
                    activeColor: color,
                    activeTrackColor: color.withValues(alpha: 0.3),
                    onChanged: (val) {
                      HapticFeedback.mediumImpact();
                      onChanged(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 400 + (index * 100)))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }
}
