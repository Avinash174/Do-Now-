import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _pushNotifications = true;
  bool _taskReminders = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
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
              _buildSectionHeader('PUSH NOTIFICATIONS', isSmallScreen),
              const SizedBox(height: 16),
              _buildToggleItem(
                'Allow Notifications',
                'Receive alerts for your tasks',
                _pushNotifications,
                (v) => setState(() => _pushNotifications = v),
                Icons.notifications_active_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildToggleItem(
                'Task Reminders',
                'Remind me when tasks are due',
                _taskReminders,
                (v) => setState(() => _taskReminders = v),
                Icons.alarm_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('SOUND & VIBRATION', isSmallScreen),
              const SizedBox(height: 16),
              _buildToggleItem(
                'Notification Sound',
                'Play sound for incoming alerts',
                _soundEnabled,
                (v) => setState(() => _soundEnabled = v),
                Icons.volume_up_rounded,
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildToggleItem(
                'Vibration',
                'Vibrate device for notifications',
                _vibrationEnabled,
                (v) => setState(() => _vibrationEnabled = v),
                Icons.vibration_rounded,
                isSmallScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: isSmallScreen ? 11 : 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
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
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: AppColors.textLight,
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
