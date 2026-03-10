import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class FaceIdBiometricView extends StatefulWidget {
  const FaceIdBiometricView({super.key});

  @override
  State<FaceIdBiometricView> createState() => _FaceIdBiometricViewState();
}

class _FaceIdBiometricViewState extends State<FaceIdBiometricView> {
  bool _faceIDEnabled = false;
  bool _fingerprintEnabled = false;
  bool _unlockApp = false;
  bool _unlockPayments = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Enhanced theme-based colors for consistency
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
            'Face ID & Biometrics',
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
                // Biometric Animation Card - Enhanced for visibility
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
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
                      // Face Icon Animation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.primaryAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
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
                                  Icons.face_unlock_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              )
                              .animate(onComplete: (c) => c.repeat())
                              .scaleXY(
                                duration: 1500.ms,
                                begin: 0.95,
                                end: 1.05,
                                curve: Curves.easeInOut,
                              ),

                          // Scan line animation
                          Positioned(
                            child:
                                Container(
                                      width: 80,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            Colors.white.withValues(alpha: 0.8),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    )
                                    .animate(onComplete: (c) => c.repeat())
                                    .moveY(
                                      duration: 2000.ms,
                                      begin: -45,
                                      end: 45,
                                      curve: Curves.easeInOut,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Secure Biometrics',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enable biometric authentication for faster and more secure access to your account.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: mutedTextColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'BIOMETRIC METHODS',
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

                _buildBiometricTile(
                  icon: Icons.face_unlock_rounded,
                  title: 'Face Unlock',
                  subtitle: 'Use face recognition to unlock',
                  value: _faceIDEnabled,
                  color: AppColors.primaryBlue,
                  onChanged: (value) => setState(() => _faceIDEnabled = value),
                ),
                const SizedBox(height: 12),
                _buildBiometricTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Fingerprint ID',
                  subtitle: 'Use registered fingerprints',
                  value: _fingerprintEnabled,
                  color: AppColors.primaryAccent,
                  onChanged: (value) =>
                      setState(() => _fingerprintEnabled = value),
                ),

                if (_faceIDEnabled || _fingerprintEnabled) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'SECURE USE CASES',
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
                  _buildBiometricTile(
                    icon: Icons.phonelink_lock_rounded,
                    title: 'Unlock Application',
                    subtitle: 'Require biometric when opening',
                    value: _unlockApp,
                    color: AppColors.success,
                    onChanged: (value) => setState(() => _unlockApp = value),
                  ),
                  const SizedBox(height: 12),
                  _buildBiometricTile(
                    icon: Icons.credit_card_rounded,
                    title: 'Payment Security',
                    subtitle: 'Confirm payments with biometrics',
                    value: _unlockPayments,
                    color: AppColors.warning,
                    onChanged: (value) =>
                        setState(() => _unlockPayments = value),
                  ),

                  const SizedBox(height: 24),
                  // Info card - Highly visible
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withValues(
                          alpha: isDark ? 0.3 : 0.15,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Your biometric data remains on your device and is never uploaded to any server.',
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
                ],
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricTile({
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
