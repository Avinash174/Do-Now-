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

    // Standardized theme colors
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark ? Colors.white70 : AppColors.textLight;

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
      child: SingleChildScrollView(
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
                        AppColors.primaryBlue.withValues(alpha: 0.8),
                        AppColors.primaryAccent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                // Decorative Bubbles
                Positioned(
                  top: -60,
                  right: -60,
                  child: _buildHeaderCircle(
                    240,
                    AppColors.white.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: -40,
                  child: _buildHeaderCircle(
                    140,
                    AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Profile Center',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 20 : 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        userAsync.when(
                          loading: () => ShimmerLoading(
                            width: isSmallScreen ? 112 : 132,
                            height: isSmallScreen ? 112 : 132,
                            borderRadius: 100,
                          ),
                          error: (err, _) => const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.white,
                            size: 40,
                          ),
                          data: (profile) {
                            final name =
                                (profile?['name'] != null &&
                                    profile!['name'].toString().isNotEmpty)
                                ? profile['name']
                                : (user?.displayName ?? 'Welcome Back');
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
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 3,
                                        ),
                                      ),
                                      child: Hero(
                                        tag: 'profile_pic',
                                        child: CircleAvatar(
                                          radius: isSmallScreen ? 50 : 60,
                                          backgroundColor: AppColors.white,
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
                                                        fontSize: isSmallScreen
                                                            ? 32
                                                            : 40,
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
                                      duration: 600.ms,
                                      curve: Curves.easeOutBack,
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.editProfile,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.black
                                                    .withValues(alpha: 0.15),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 20,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: 400.ms).scale(),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: isSmallScreen ? 24 : 28,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.white,
                                        letterSpacing: -1,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideY(begin: 0.2, end: 0),
                                const SizedBox(height: 8),
                                if (email.isNotEmpty)
                                  Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          email,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: AppColors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 300.ms)
                                      .slideY(begin: 0.2, end: 0),
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

            // Content Body with Overlapping Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Transform.translate(
                offset: const Offset(0, -60),
                child: Column(
                  children: [
                    // Premium Stats Row
                    _buildGlassStatsCard(
                      context,
                      stats,
                      textColor,
                      mutedTextColor,
                    ),

                    const SizedBox(height: 32),

                    // Menu Section - Account
                    _buildMenuSection(context, 'PERSONAL SETTINGS', [
                      _buildMenuTile(
                        context,
                        Icons.person_rounded,
                        'Profile Management',
                        AppColors.primaryBlue,
                        () =>
                            Navigator.pushNamed(context, AppRoutes.editProfile),
                        textColor,
                        mutedTextColor,
                      ),
                      _buildMenuTile(
                        context,
                        Icons.notifications_active_rounded,
                        'Notification Control',
                        AppColors.warning,
                        () => Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        ),
                        textColor,
                        mutedTextColor,
                      ),
                      _buildMenuTile(
                        context,
                        Icons.verified_user_rounded,
                        'Security & Access',
                        AppColors.success,
                        () => Navigator.pushNamed(context, AppRoutes.security),
                        textColor,
                        mutedTextColor,
                      ),
                      _buildThemeTile(context, ref, textColor, mutedTextColor),
                    ], textColor),

                    const SizedBox(height: 24),

                    // Menu Section - Support
                    _buildMenuSection(context, 'SUPPORT & INFO', [
                      _buildMenuTile(
                        context,
                        Icons.help_center_rounded,
                        'Knowledge Base',
                        AppColors.primaryAccent,
                        () =>
                            Navigator.pushNamed(context, AppRoutes.helpCenter),
                        textColor,
                        mutedTextColor,
                      ),
                      _buildMenuTile(
                        context,
                        Icons.error_rounded,
                        'About Application',
                        AppColors.primaryBlue,
                        () => Navigator.pushNamed(context, AppRoutes.about),
                        textColor,
                        mutedTextColor,
                      ),
                    ], textColor),

                    const SizedBox(height: 32),

                    // Logout Button - Refined
                    SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleLogout(
                              context,
                              ref,
                              textColor,
                              mutedTextColor,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger.withValues(
                                alpha: isDark ? 0.15 : 0.08,
                              ),
                              foregroundColor: AppColors.danger,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: AppColors.danger.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.power_settings_new_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Terminate Session',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate(delay: 800.ms)
                        .fadeIn()
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildGlassStatsCard(
    BuildContext context,
    Map<String, dynamic> stats,
    Color textColor,
    Color mutedTextColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            'Total',
            '${stats['total']}',
            Icons.dashboard_rounded,
            AppColors.primaryBlue,
            textColor,
            mutedTextColor,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            'Done',
            '${stats['done']}',
            Icons.task_alt_rounded,
            AppColors.success,
            textColor,
            mutedTextColor,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            'Pending',
            '${stats['pending']}',
            Icons.hourglass_bottom_rounded,
            AppColors.warning,
            textColor,
            mutedTextColor,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
    Color mutedTextColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: mutedTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 48,
      width: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).dividerColor.withValues(alpha: 0),
            Theme.of(context).dividerColor.withValues(alpha: 0.2),
            Theme.of(context).dividerColor.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color mutedTextColor,
  ) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;
    final isDark = Theme.of(ref.context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Application Aesthetic',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    _buildThemeOption(
                      ref,
                      label: 'Light',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                      current: themeMode,
                      isDark: isDark,
                    ),
                    _buildThemeOption(
                      ref,
                      label: 'Adaptive',
                      icon: Icons.auto_mode_rounded,
                      mode: ThemeMode.system,
                      current: themeMode,
                      isDark: isDark,
                    ),
                    _buildThemeOption(
                      ref,
                      label: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                      current: themeMode,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode current,
    required bool isDark,
  }) {
    final isSelected = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(themeModeProvider.notifier).setMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white54 : AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white54 : AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> tiles,
    Color textColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    Color iconColor,
    VoidCallback onTap,
    Color textColor,
    Color mutedTextColor,
  ) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 22,
        color: mutedTextColor.withValues(alpha: 0.4),
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
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(
          'Terminate Session',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to end your current session? You will need to re-authenticate.',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            color: mutedTextColor,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Keep Active',
                    style: GoogleFonts.plusJakartaSans(
                      color: mutedTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Session Terminated',
          'You have been successfully signed out.',
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }
}
