import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../view_model/task_view_model.dart';
import '../view_model/theme_view_model.dart';
import '../utils/snackbar_utils.dart';
import '../utils/shimmer_utils.dart';
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final stats = ref.watch(taskStatsProvider);
    final user = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : AppColors.textLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Premium Dynamic Header
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: size.height * 0.48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue,
                          const Color(0xFF1E3A8A),
                          const Color(0xFF3B82F6),
                        ],
                        stops: const [0.1, 0.6, 1.0],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -80,
                    right: -40,
                    child: _buildHeaderCircle(
                      300,
                      Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -60,
                    child: _buildHeaderCircle(
                      200,
                      Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                                'User Profile',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.2, end: 0),
                          const SizedBox(height: 32),
                          userAsync.when(
                            loading: () => ShimmerLoading(
                              width: isSmallScreen ? 112 : 132,
                              height: isSmallScreen ? 112 : 132,
                              borderRadius: 100,
                            ),
                            error: (err, _) => const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            data: (profile) {
                              final name =
                                  (profile?['name'] != null &&
                                      profile!['name'].toString().isNotEmpty)
                                  ? profile['name']
                                  : (user?.displayName ?? 'Operator');
                              final email =
                                  (profile?['email'] != null &&
                                      profile!['email'].toString().isNotEmpty)
                                  ? profile['email']
                                  : (user?.email ?? '');
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Hero(
                                          tag: 'profile_pic',
                                          child: CircleAvatar(
                                            radius: isSmallScreen ? 55 : 65,
                                            backgroundColor: Colors.white,
                                            backgroundImage:
                                                profile?['photoUrl'] != null
                                                ? NetworkImage(
                                                    profile!['photoUrl'],
                                                  )
                                                : null,
                                            child: profile?['photoUrl'] == null
                                                ? Text(
                                                    name.isNotEmpty
                                                        ? name[0].toUpperCase()
                                                        : 'U',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize:
                                                              isSmallScreen
                                                              ? 36
                                                              : 44,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: AppColors
                                                              .primaryBlue,
                                                        ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ).animate().scale(
                                        duration: 800.ms,
                                        curve: Curves.easeOutBack,
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.editProfile,
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.edit_rounded,
                                              size: 22,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ).animate().fadeIn(delay: 600.ms).scale(),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isSmallScreen ? 24 : 30,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 200.ms)
                                      .slideY(begin: 0.1, end: 0),
                                  const SizedBox(height: 8),
                                  if (email.isNotEmpty)
                                    Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            email,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: 400.ms)
                                        .slideY(begin: 0.1, end: 0),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Transform.translate(
                  offset: const Offset(0, -60),
                  child: Column(
                    children: [
                      // Stats Card
                      _buildStatsCard(
                        context,
                        stats,
                        textColor,
                        mutedTextColor,
                      ),
                      const SizedBox(height: 40),

                      // Account Settings
                      _buildSettingsSection(context, 'CORE INTERFACE', [
                        _buildSettingsTile(
                          context,
                          'Profile Intelligence',
                          'Configure identity parameters',
                          Icons.fingerprint_rounded,
                          AppColors.primaryBlue,
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                          ),
                          textColor,
                          mutedTextColor,
                          0,
                        ),
                        _buildSettingsTile(
                          context,
                          'Alert Infrastructure',
                          'Optimize signal priority',
                          Icons.sensors_rounded,
                          AppColors.warning,
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.notifications,
                          ),
                          textColor,
                          mutedTextColor,
                          1,
                        ),
                        _buildSettingsTile(
                          context,
                          'Security Protocols',
                          'Manage encryption & access',
                          Icons.shield_rounded,
                          AppColors.success,
                          () =>
                              Navigator.pushNamed(context, AppRoutes.security),
                          textColor,
                          mutedTextColor,
                          2,
                        ),
                        _buildThemeSelector(
                          context,
                          ref,
                          textColor,
                          mutedTextColor,
                        ),
                      ]),



                      const SizedBox(height: 32),

                      _buildSettingsSection(context, 'SYSTEM SUPPORT', [
                        _buildSettingsTile(
                          context,
                          'Central Assistance',
                          'Access operation manuals',
                          Icons.terminal_rounded,
                          AppColors.primaryAccent,
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.helpCenter,
                          ),
                          textColor,
                          mutedTextColor,
                          2,
                        ),
                        _buildSettingsTile(
                          context,
                          'Application Manifest',
                          'System version & legal',
                          Icons.info_outline_rounded,
                          AppColors.primaryBlue,
                          () => Navigator.pushNamed(context, AppRoutes.about),
                          textColor,
                          mutedTextColor,
                          3,
                        ),
                      ]),

                      const SizedBox(height: 48),

                      // Logout
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _handleLogout(
                            context,
                            ref,
                            textColor,
                            mutedTextColor,
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: AppColors.danger.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Text(
                            'SECURE LOGOUT',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ).animate(delay: 800.ms).fadeIn(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    Map<String, dynamic> stats,
    Color textColor,
    Color mutedTextColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'TOTAL',
            '${stats['total']}',
            Icons.grid_view_rounded,
            AppColors.primaryBlue,
            textColor,
            mutedTextColor,
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            'DONE',
            '${stats['done']}',
            Icons.check_circle_rounded,
            AppColors.success,
            textColor,
            mutedTextColor,
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            'WAIT',
            '${stats['pending']}',
            Icons.access_time_filled_rounded,
            AppColors.warning,
            textColor,
            mutedTextColor,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
    Color mutedTextColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: mutedTextColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1.5,
      height: 40,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.borderColor,
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    Color textColor,
    Color mutedTextColor,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.borderColor,
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
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                  Icon(
                    Icons.chevron_right_rounded,
                    color: mutedTextColor.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color mutedTextColor,
  ) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Optics Protocol',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black26
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildThemeButton(
                    ref,
                    'LIGHT',
                    Icons.sunny,
                    ThemeMode.light,
                    themeMode,
                  ),
                  _buildThemeButton(
                    ref,
                    'AUTO',
                    Icons.stream_rounded,
                    ThemeMode.system,
                    themeMode,
                  ),
                  _buildThemeButton(
                    ref,
                    'DARK',
                    Icons.nights_stay_rounded,
                    ThemeMode.dark,
                    themeMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    WidgetRef ref,
    String label,
    IconData icon,
    ThemeMode mode,
    ThemeMode current,
  ) {
    final isSelected = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(themeModeProvider.notifier).setMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color mutedTextColor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(
          'Security Lockdown',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        content: Text(
          'Initiate secure session termination? All encrypted tokens will be cleared.',
          style: GoogleFonts.plusJakartaSans(
            color: mutedTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ABORT',
              style: GoogleFonts.plusJakartaSans(
                color: mutedTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'TERMINATE',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
        SnackbarUtils.showSuccess(
          context,
          'Session Terminated',
          'Session Securely Terminated',
        );
      }
    }
  }
}
