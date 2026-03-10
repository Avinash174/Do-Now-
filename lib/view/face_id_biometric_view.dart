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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color:
              theme.textTheme.titleLarge?.color ??
              (isDark ? Colors.white : AppColors.textDark),
        ),
        title: Text(
          'Face ID & Biometrics',
          style: GoogleFonts.plusJakartaSans(
            color:
                theme.textTheme.titleLarge?.color ??
                (isDark ? Colors.white : AppColors.textDark),
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: isDark
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
              // Biometric Animation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryAccent.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                      AppColors.primaryBlue.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(
                      alpha: isDark ? 0.3 : 0.2,
                    ),
                  ),
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
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.primaryAccent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.face_unlock_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            )
                            .animate(
                              onComplete: (controller) {
                                controller.repeat();
                              },
                            )
                            .scaleXY(duration: 1000.ms, begin: 0.95, end: 1.05),
                        // Scan line animation
                        Positioned(
                          child:
                              Container(
                                    width: 80,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white,
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                  .animate(
                                    onComplete: (controller) {
                                      controller.repeat();
                                    },
                                  )
                                  .moveY(
                                    duration: 1500.ms,
                                    begin: -50,
                                    end: 50,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unlock with Your Face or Fingerprint',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            theme.textTheme.titleMedium?.color ??
                            (isDark ? Colors.white : AppColors.textDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fast, secure, and convenient biometric authentication',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color:
                            theme.textTheme.bodySmall?.color ??
                            (isDark ? Colors.white70 : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Biometric Methods
              Text(
                'BIOMETRIC METHODS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.textTheme.bodySmall?.color ??
                      (isDark ? Colors.white60 : AppColors.textMuted),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildBiometricTile(
                icon: Icons.face_unlock_rounded,
                title: 'Face ID',
                subtitle: 'Use your face to unlock the app',
                value: _faceIDEnabled,
                onChanged: (value) => setState(() => _faceIDEnabled = value),
              ),
              const SizedBox(height: 12),
              _buildBiometricTile(
                icon: Icons.fingerprint_rounded,
                title: 'Fingerprint',
                subtitle: 'Use your fingerprint to unlock the app',
                value: _fingerprintEnabled,
                onChanged: (value) =>
                    setState(() => _fingerprintEnabled = value),
              ),
              const SizedBox(height: 32),
              // Use Cases
              if (_faceIDEnabled || _fingerprintEnabled) ...[
                Text(
                  'USE CASES',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        theme.textTheme.bodySmall?.color ??
                        (isDark ? Colors.white60 : AppColors.textMuted),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUseCaseTile(
                  icon: Icons.phonelink_lock_rounded,
                  title: 'Unlock App',
                  subtitle: 'Require biometric to open the app',
                  value: _unlockApp,
                  onChanged: (value) => setState(() => _unlockApp = value),
                ),
                const SizedBox(height: 12),
                _buildUseCaseTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Unlock Payments',
                  subtitle: 'Require biometric for sensitive actions',
                  value: _unlockPayments,
                  onChanged: (value) => setState(() => _unlockPayments = value),
                ),
                const SizedBox(height: 24),
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withValues(
                        alpha: isDark ? 0.4 : 0.2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Biometric data is securely stored on your device',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color:
                                theme.textTheme.titleSmall?.color ??
                                (isDark ? Colors.white : AppColors.textDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
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
    required Function(bool) onChanged,
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
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.1),
          width: value ? 2 : 1,
        ),
        boxShadow: value
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
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.8),
                  AppColors.primaryAccent,
                ],
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
                        (isDark ? Colors.white : AppColors.textDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color:
                        theme.textTheme.bodySmall?.color ??
                        (isDark ? Colors.white70 : AppColors.textMuted),
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
              activeColor: AppColors.primaryBlue,
              inactiveThumbColor: isDark ? Colors.white : AppColors.textMuted,
              inactiveTrackColor: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCaseTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
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
              ? AppColors.success.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.1),
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.success, size: 24),
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
                        (isDark ? Colors.white : AppColors.textDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color:
                        theme.textTheme.bodySmall?.color ??
                        (isDark ? Colors.white70 : AppColors.textMuted),
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
              activeColor: AppColors.success,
              inactiveThumbColor: isDark ? Colors.white : AppColors.textMuted,
              inactiveTrackColor: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
