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
            'Privacy Protocols',
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
                        _buildSectionLabel('TERMINAL DISCOVERY'),
                        const SizedBox(height: 20),

                        _buildVisibilityOption(
                          title: 'GLOBAL BROADCAST',
                          subtitle:
                              'Terminal identifier visible to all operators',
                          icon: Icons.public_rounded,
                          value: 'public',
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 0,
                        ),
                        _buildVisibilityOption(
                          title: 'TRUSTED CONNECT',
                          subtitle: 'Only verified connections can identify',
                          icon: Icons.diversity_3_rounded,
                          value: 'friends_only',
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 1,
                        ),
                        _buildVisibilityOption(
                          title: 'STEALTH MODE',
                          subtitle: 'Maximum encryption. Invisible to scouts',
                          icon: Icons.lock_rounded,
                          value: 'private',
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 2,
                        ),

                        const SizedBox(height: 40),
                        _buildSectionLabel('SENSITIVE DATA BROADCAST'),
                        const SizedBox(height: 20),

                        _buildToggleTile(
                          icon: Icons.alternate_email_rounded,
                          title: 'Identity Email',
                          subtitle: 'Reveal secure contact address',
                          value: _showEmail,
                          onChanged: (v) => setState(() => _showEmail = v),
                          color: AppColors.info,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 3,
                        ),
                        _buildToggleTile(
                          icon: Icons.phone_iphone_rounded,
                          title: 'Biometric Contact',
                          subtitle: 'Reveal satellite uplink number',
                          value: _showPhone,
                          onChanged: (v) => setState(() => _showPhone = v),
                          color: AppColors.warning,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 4,
                        ),

                        const SizedBox(height: 40),
                        _buildSectionLabel('OPERATIONAL STATUS'),
                        const SizedBox(height: 20),

                        _buildToggleTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Signal Reception',
                          subtitle: 'Allow direct encrypted messaging',
                          value: _allowMessages,
                          onChanged: (v) => setState(() => _allowMessages = v),
                          color: AppColors.success,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 5,
                        ),
                        _buildToggleTile(
                          icon: Icons.wifi_tethering_rounded,
                          title: 'Active Uplink',
                          subtitle: 'Broadcast current online status',
                          value: _showActivity,
                          onChanged: (v) => setState(() => _showActivity = v),
                          color: AppColors.primaryBlue,
                          textColor: textColor,
                          mutedTextColor: mutedTextColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          index: 6,
                        ),
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
                  Icons.visibility_off_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .shimmer(delay: 800.ms, duration: 1500.ms),
          const SizedBox(height: 24),
          Text(
            'Visibility Shield',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'Manage your terminal presence and data broadcast settings across the network.',
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

  Widget _buildVisibilityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color textColor,
    required Color mutedTextColor,
    required Color cardColor,
    required Color borderColor,
    required int index,
  }) {
    final isSelected = _profileVisibility == value;

    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _profileVisibility = value);
            },
            child: AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : borderColor,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
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
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.primaryBlue,
                      size: 26,
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
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : textColor,
                            letterSpacing: 0.5,
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
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ).animate().scale(curve: Curves.easeOutBack),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildToggleTile({
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
    required int index,
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
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: value ? color.withValues(alpha: 0.5) : borderColor,
                  width: 1.5,
                ),
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
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: value,
                      onChanged: (v) {
                        HapticFeedback.mediumImpact();
                        onChanged(v);
                      },
                      activeThumbColor: color,
                      activeTrackColor: color.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * (index + 3)))
        .slideX(begin: 0.1, end: 0);
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
          // Logic for applying profile
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
              'Apply Privacy Protocol',
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
