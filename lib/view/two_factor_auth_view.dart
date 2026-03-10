import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';
import '../utils/snackbar_utils.dart';

class TwoFactorAuthView extends StatefulWidget {
  const TwoFactorAuthView({super.key});

  @override
  State<TwoFactorAuthView> createState() => _TwoFactorAuthViewState();
}

class _TwoFactorAuthViewState extends State<TwoFactorAuthView> {
  bool _emailEnabled = false;
  bool _smsEnabled = false;
  bool _appEnabled = false;
  bool _isSaving = false;

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
        appBar: _buildAppBar(context, textColor, isSmallScreen),
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
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('AUTHENTICATION VECTORS'),
                        const SizedBox(height: 20),

                        _buildAuthTile(
                          icon: Icons.alternate_email_rounded,
                          title: 'Email Vector',
                          subtitle: 'Secure code via encrypted mail',
                          value: _emailEnabled,
                          accentColor: const Color(0xFF4C84FF),
                          onChanged: (val) =>
                              setState(() => _emailEnabled = val),
                          index: 0,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 16),

                        _buildAuthTile(
                          icon: Icons.phonelink_ring_rounded,
                          title: 'SMS Transmission',
                          subtitle: 'Verification via mobile network',
                          value: _smsEnabled,
                          accentColor: const Color(0xFFFF9F43),
                          onChanged: (val) => setState(() => _smsEnabled = val),
                          index: 1,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 16),

                        _buildAuthTile(
                          icon: Icons.vibration_rounded,
                          title: 'Authenticator Core',
                          subtitle: 'Dynamic time-based tokens',
                          value: _appEnabled,
                          accentColor: const Color(0xFF28C76F),
                          onChanged: (val) => setState(() => _appEnabled = val),
                          index: 2,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),

                        const SizedBox(height: 32),
                        _buildInfoCard(isDark, textColor),
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Color textColor,
    bool isSmallScreen,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
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
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              )
              .animate()
              .scale(duration: 800.ms, curve: Curves.easeOutBack)
              .shimmer(delay: 1.seconds, duration: 2.seconds),
          const SizedBox(height: 28),
          Text(
            'Account Fortress',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            'Deploy multiple verification vectors to maximize your account security parameters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: mutedTextColor,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
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
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAuthTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required Function(bool) onChanged,
    required int index,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
  }) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.textLight;

    return AnimatedContainer(
          duration: 300.ms,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: value ? accentColor.withValues(alpha: 0.5) : borderColor,
              width: value ? 2 : 1.5,
            ),
            boxShadow: value
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.02,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(!value);
              },
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: accentColor, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
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
                    Switch.adaptive(
                      value: value,
                      activeThumbColor: accentColor,
                      activeTrackColor: accentColor.withValues(alpha: 0.3),
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        onChanged(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (600 + (index * 100)).ms)
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildInfoCard(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.25 : 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Security Protocol: Initialize at least one vector for operational continuity. Multi-factor encryption is recommended for high-value targets.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 900.ms).fadeIn();
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
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSaving ? null : _handleSave,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Apply Security Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ).animate(delay: 1000.ms).slideY(begin: 1, end: 0);
  }

  void _handleSave() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(2.seconds);

    if (mounted) {
      setState(() => _isSaving = false);
      SnackbarUtils.showSuccess(
        context,
        'Protocol Deployed',
        'Security configuration protocols deployed successfully',
      );
      Navigator.pop(context);
    }
  }
}
