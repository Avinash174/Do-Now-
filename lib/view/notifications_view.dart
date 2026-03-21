import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';
import '../const/app_colors.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../utils/widgets_utils.dart';
import '../utils/snackbar_utils.dart';

final dailyReminderProvider = AsyncNotifierProvider<DailyReminderNotifier, TimeOfDay?>(() {
  return DailyReminderNotifier();
});

class DailyReminderNotifier extends AsyncNotifier<TimeOfDay?> {
  @override
  FutureOr<TimeOfDay?> build() {
    final settings = ref.watch(settingsServiceProvider);
    final timeStr = settings.dailyReminderTime;
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> saveTime(TimeOfDay? time) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Premium feel
      final settings = ref.read(settingsServiceProvider);
      final notificationService = ref.read(notificationServiceProvider);
      
      if (time == null) {
        await settings.setDailyReminderTime(null);
        await notificationService.cancelDailyReminder();
      } else {
        await settings.setDailyReminderTime('${time.hour}:${time.minute}');
        await notificationService.scheduleDailyReminder(time.hour, time.minute);
      }
      state = AsyncValue.data(time);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

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
              _buildSectionHeader(context, 'DAILY REMINDER', isSmallScreen),
              const SizedBox(height: 16),
              _buildDailyReminderSection(context, isSmallScreen),
              const SizedBox(height: 32),
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

  Widget _buildDailyReminderSection(BuildContext context, bool isSmallScreen) {
    final dailyReminder = ref.watch(dailyReminderProvider);
    final isLoading = dailyReminder.isLoading;
    final time = dailyReminder.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: AppColors.primaryBlue.withValues(alpha: 0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.bedtime_rounded, color: AppColors.primaryBlue, size: isSmallScreen ? 18 : 22),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Daily Digest',
                       style: GoogleFonts.plusJakartaSans(
                         fontSize: isSmallScreen ? 14 : 16,
                         fontWeight: FontWeight.w800,
                       ),
                     ),
                     Text(
                       time == null ? 'Not scheduled' : 'Scheduled at ${time.format(context)}',
                       style: GoogleFonts.plusJakartaSans(
                         fontSize: isSmallScreen ? 11 : 12,
                         color: AppColors.textLight,
                       ),
                     ),
                   ],
                 ),
               ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: isLoading ? null : () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time ?? const TimeOfDay(hour: 9, minute: 0),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: Theme.of(ctx).brightness == Brightness.dark
                          ? const ColorScheme.dark(
                              primary: AppColors.primaryBlue,
                              onPrimary: AppColors.white,
                              surface: Color(0xFF1E293B),
                              onSurface: AppColors.white,
                              secondary: AppColors.primaryBlue,
                            )
                          : const ColorScheme.light(
                              primary: AppColors.primaryBlue,
                              onPrimary: AppColors.white,
                              onSurface: AppColors.textDark,
                              secondary: AppColors.primaryBlue,
                            ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  try {
                    await ref.read(dailyReminderProvider.notifier).saveTime(picked);
                    if (!context.mounted) return;
                    SnackbarUtils.showSuccess(context, "Success!", "Daily digest scheduled.");
                  } catch (e) {
                    if (!context.mounted) return;
                    SnackbarUtils.showError(context, "Snap!", "Failed to update: $e");
                  }
                }
              },
              child: isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text("Set Daily Schedule", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          if (time != null) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : () async {
                  try {
                    await ref.read(dailyReminderProvider.notifier).saveTime(null);
                    if (!context.mounted) return;
                    SnackbarUtils.showSuccess(context, "Removed", "Schedule removed.");
                  } catch (e) {
                    if (!context.mounted) return;
                    SnackbarUtils.showError(context, "Snap!", "Failed to update: $e");
                  }
                },
                child: Text("Remove Schedule", style: GoogleFonts.plusJakartaSans(color: AppColors.danger, fontWeight: FontWeight.w600)),
              ),
            ),
          ]
        ],
      )
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
