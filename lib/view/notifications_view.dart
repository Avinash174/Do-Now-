import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/app_colors.dart';
import '../services/settings_service.dart';
import '../utils/widgets_utils.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color: theme.textTheme.bodyLarge?.color ?? AppColors.textDark,
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.titleLarge?.color ?? AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: theme.brightness == Brightness.dark
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
              _buildSectionHeader(context, 'PUSH NOTIFICATIONS', isSmallScreen),
              const SizedBox(height: 16),
              _buildToggleItem(
                'Allow Notifications',
                'Receive alerts for your tasks',
                settings.pushNotificationsEnabled,
                (v) => settings.setPushNotificationsEnabled(v),
                Icons.notifications_active_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildToggleItem(
                'Task Reminders',
                'Remind me when tasks are due',
                settings.taskRemindersEnabled,
                (v) => settings.setTaskRemindersEnabled(v),
                Icons.alarm_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'SOUND & VIBRATION', isSmallScreen),
              const SizedBox(height: 16),
              _buildToggleItem(
                'Notification Sound',
                'Play sound for incoming alerts',
                settings.soundEnabled,
                (v) => settings.setSoundEnabled(v),
                Icons.volume_up_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildToggleItem(
                'Vibration',
                'Vibrate device for notifications',
                settings.vibrationEnabled,
                (v) => settings.setVibrationEnabled(v),
                Icons.vibration_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isSmallScreen,
  ) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: isSmallScreen ? 11 : 12,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).primaryColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: isSmallScreen ? 18 : 22,
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
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color:
                        theme.textTheme.titleMedium?.color ??
                        AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 11 : 12,
                    color:
                        theme.textTheme.bodySmall?.color ?? AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primaryBlue,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
