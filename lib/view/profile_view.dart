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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Premium Dynamic Header
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: size.height * 0.48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.secondaryBlue,
                      AppColors.primaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              // Decorative Bubbles
              Positioned(
                top: -60,
                right: -60,
                child: _buildHeaderCircle(
                  240,
                  AppColors.white.withValues(alpha: 0.1),
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
                      const SizedBox(height: 5),
                      Text(
                        'Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                              : (user?.displayName ?? 'User');
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
                                          alpha: 0.25,
                                        ),
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: isSmallScreen ? 50 : 60,
                                      backgroundColor: AppColors.white,
                                      backgroundImage:
                                          profile?['photoUrl'] != null
                                          ? NetworkImage(profile!['photoUrl'])
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
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        AppColors.primaryBlue,
                                                  ),
                                            )
                                          : null,
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
                                              color: AppColors.black.withValues(
                                                alpha: 0.1,
                                              ),
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
                              const SizedBox(height: 8),
                              Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 24 : 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms)
                                  .slideY(begin: 0.2, end: 0),
                              const SizedBox(height: 6),
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        email,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
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
                  _buildGlassStatsCard(stats),

                  const SizedBox(height: 32),

                  // Menu Section - Account
                  _buildMenuSection('Account Settings', [
                    _buildMenuTile(
                      Icons.person_outline_rounded,
                      'Edit Profile',
                      AppColors.primaryBlue,
                      () => Navigator.pushNamed(context, AppRoutes.editProfile),
                    ),
                    _buildMenuTile(
                      Icons.notifications_none_rounded,
                      'Notifications',
                      AppColors.warning,
                      () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                    ),
                    _buildMenuTile(
                      Icons.security_rounded,
                      'Security & Privacy',
                      AppColors.success,
                      () => Navigator.pushNamed(context, AppRoutes.security),
                    ),
                    _buildThemeTile(ref),
                  ]),

                  const SizedBox(height: 24),

                  // Menu Section - Support
                  _buildMenuSection('Support', [
                    _buildMenuTile(
                      Icons.help_outline_rounded,
                      'Help Center',
                      AppColors.primaryAccent,
                      () => Navigator.pushNamed(context, AppRoutes.helpCenter),
                    ),
                    _buildMenuTile(
                      Icons.info_outline_rounded,
                      'About Do Now',
                      AppColors.primaryBlue,
                      () => Navigator.pushNamed(context, AppRoutes.about),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Logout Button - Refined
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger.withValues(
                          alpha: 0.08,
                        ),
                        foregroundColor: AppColors.danger,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildGlassStatsCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            'Total Tasks',
            '${stats['total']}',
            Icons.list_alt_rounded,
            AppColors.primaryBlue,
          ),
          _buildDivider(),
          _buildStatItem(
            'Completed',
            '${stats['done']}',
            Icons.check_circle_rounded,
            AppColors.success,
          ),
          _buildDivider(),
          _buildStatItem(
            'Pending',
            '${stats['pending']}',
            Icons.pending_rounded,
            AppColors.warning,
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
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildThemeTile(WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;
    final isDark = Theme.of(ref.context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : AppColors.cardBorder,
          ),
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
                    'App Theme',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
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
                      label: 'System',
                      icon: Icons.phone_android_rounded,
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
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
                    : (isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textLight,
        size: 24,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Signed Out',
          'You have been successfully signed out.',
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }
}
