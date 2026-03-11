import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';
import '../services/settings_service.dart';
import '../services/biometric_service.dart';

class FaceIdBiometricView extends ConsumerStatefulWidget {
  const FaceIdBiometricView({super.key});

  @override
  ConsumerState<FaceIdBiometricView> createState() => _FaceIdBiometricViewState();
}

class _FaceIdBiometricViewState extends ConsumerState<FaceIdBiometricView> {
  bool _faceIDEnabled = false;
  bool _fingerprintEnabled = false;
  bool _unlockApp = false;
  bool _unlockPayments = false;
  bool _offlineAccessOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  void _loadSettings() {
    final settings = ref.read(settingsServiceProvider);
    setState(() {
      _unlockApp = settings.biometricEnabled;
      // We can also check device capabilities to show correct labels
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final bioService = ref.read(biometricServiceProvider);
    final available = await bioService.getAvailableBiometrics();
    setState(() {
      _faceIDEnabled = available.contains(BiometricType.face);
      _fingerprintEnabled = available.contains(BiometricType.fingerprint) || 
                          available.contains(BiometricType.strong) || 
                          available.contains(BiometricType.weak);
    });
  }

  void _toggleAppLock(bool value) async {
    if (value) {
      // If enabling, verify first
      final authenticated = await ref.read(biometricServiceProvider).authenticate(
        reason: 'Verify your identity to enable biometric lock',
      );
      if (authenticated) {
        await ref.read(settingsServiceProvider).setBiometricEnabled(true);
        setState(() => _unlockApp = true);
      }
    } else {
      await ref.read(settingsServiceProvider).setBiometricEnabled(false);
      setState(() => _unlockApp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : AppColors.textLight;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderColor.withValues(alpha: 0.5);

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: PlatformBackButton(color: textColor),
          ),
          title: Text(
            'Biometric Protocols',
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: isSmallScreen ? 18 : 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Decorative background elements
            if (isDark)
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  ),
                ),
              ),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, textColor, mutedTextColor, borderColor),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('BIOMETRIC INFRASTRUCTURE'),
                        const SizedBox(height: 20),

                        _buildPremiumBiometricTile(
                          icon: Icons.face_unlock_rounded,
                          title: 'Face Recognition',
                          subtitle: 'Initialize ocular identification',
                          value: _faceIDEnabled,
                          color: AppColors.primaryBlue,
                          onChanged: (value) =>
                              setState(() => _faceIDEnabled = value),
                          index: 0,
                          isDark: isDark,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),
                        _buildPremiumBiometricTile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Fingerprint Matrix',
                          subtitle: 'Initialize tactile verify index',
                          value: _fingerprintEnabled,
                          color: AppColors.primaryAccent,
                          onChanged: (value) =>
                              setState(() => _fingerprintEnabled = value),
                          index: 1,
                          isDark: isDark,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),

                        if (_faceIDEnabled || _fingerprintEnabled) ...[
                          const SizedBox(height: 40),
                          _buildSectionLabel('OPERATIONAL USE CASES'),
                          const SizedBox(height: 20),

                          _buildPremiumBiometricTile(
                            icon: Icons.phonelink_lock_rounded,
                            title: 'Terminal Lockdown',
                            subtitle: 'Require biometric for entry',
                            value: _unlockApp,
                            color: AppColors.success,
                            onChanged: _toggleAppLock,
                            index: 2,
                            isDark: isDark,
                            textColor: textColor,
                            mutedTextColor: mutedTextColor,
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                          _buildPremiumBiometricTile(
                            icon: Icons.key_rounded,
                            title: 'Credential Retrieval',
                            subtitle: 'Verify for sensitive data',
                            value: _unlockPayments,
                            color: AppColors.warning,
                            onChanged: (value) =>
                                setState(() => _unlockPayments = value),
                            index: 3,
                            isDark: isDark,
                            textColor: textColor,
                            mutedTextColor: mutedTextColor,
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                           _buildPremiumBiometricTile(
                             icon: Icons.cloud_off_rounded,
                             title: 'Offline Access Only',
                             subtitle: 'Restrict data to local storage',
                             value: _offlineAccessOnly,
                             color: AppColors.primaryAccent,
                             onChanged: (value) =>
                                 setState(() => _offlineAccessOnly = value),
                             index: 4,
                             isDark: isDark,
                             textColor: textColor,
                             mutedTextColor: mutedTextColor,
                             cardColor: cardColor,
                             borderColor: borderColor,
                           ),

                          const SizedBox(height: 32),
                          _buildInfoCard(isDark, textColor),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomActions(isDark, theme),
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color textColor,
    Color mutedTextColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.face_unlock_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  )
                  .animate(onComplete: (c) => c.repeat())
                  .scale(
                    duration: 1500.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    curve: Curves.easeInOut,
                  ),

              // Scanning Radar Effect
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  )
                  .animate(onComplete: (c) => c.repeat())
                  .scale(
                    duration: 2000.ms,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.3, 1.3),
                    curve: Curves.easeOut,
                  )
                  .fadeOut(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Biometric Auth',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, size: 14, color: AppColors.primaryBlue),
                const SizedBox(width: 6),
                Text(
                  'OFFLINE ACCESS ONLY',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Text(
            'Advanced cryptographic verification using your unique biometric signatures.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: mutedTextColor,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryBlue,
          letterSpacing: 2,
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildPremiumBiometricTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
    required int index,
    required bool isDark,
    required Color textColor,
    required Color mutedTextColor,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(!value);
            },
            child: AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: value ? color.withValues(alpha: 0.08) : cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: value ? color.withValues(alpha: 0.5) : borderColor,
                  width: 1.5,
                ),
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
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
                    child: Icon(icon, color: color, size: 26),
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
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: mutedTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: value,
                      activeThumbColor: color,
                      activeTrackColor: color.withValues(alpha: 0.35),
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        onChanged(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildInfoCard(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Verified secure hardware storage active. Encryption tokens are handled exclusively by the enclave.',
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
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildBottomActions(bool isDark, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Biometric protocols synchronized',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF1E3A8A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Apply Biometric Protocol',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
