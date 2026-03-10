import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class HelpTopicDetailsView extends StatefulWidget {
  final String title;
  final String topic;

  const HelpTopicDetailsView({
    super.key,
    required this.title,
    required this.topic,
  });

  @override
  State<HelpTopicDetailsView> createState() => _HelpTopicDetailsViewState();
}

class _HelpTopicDetailsViewState extends State<HelpTopicDetailsView> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const PlatformBackButton(color: AppColors.textDark),
        title: Text(
          widget.title,
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
              // Topic Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_getTopicIcon(), size: 40, color: AppColors.white),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTopicSubtitle(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),

              const SizedBox(height: 32),

              // FAQ Section
              Text(
                'FREQUENTLY ASKED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              ..._buildFAQItems(isSmallScreen),

              const SizedBox(height: 32),

              // Helpful Resources
              Text(
                'HELPFUL RESOURCES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              ..._buildResourceCards(isSmallScreen),

              const SizedBox(height: 32),

              // Still Need Help
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 32,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Still need help?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our support team is ready to assist you anytime',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(context, '/support_chat');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Contact Support',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTopicIcon() {
    switch (widget.topic) {
      case 'syncing':
        return Icons.sync_rounded;
      case 'reminders':
        return Icons.alarm_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'premium':
        return Icons.star_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getTopicSubtitle() {
    switch (widget.topic) {
      case 'syncing':
        return 'Keep your tasks synced across all devices';
      case 'reminders':
        return 'Never miss your important tasks';
      case 'security':
        return 'Protect your account and data';
      case 'premium':
        return 'Unlock exclusive features';
      default:
        return 'Get help and support';
    }
  }

  List<Widget> _buildFAQItems(bool isSmallScreen) {
    final faqs = _getFAQContent();
    return List.generate(
      faqs.length,
      (index) => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: expandedIndex == index
                  ? AppColors.primaryBlue.withValues(alpha: 0.05)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: expandedIndex == index
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : AppColors.cardBorder,
              ),
            ),
            child: ExpansionTile(
              onExpansionChanged: (expanded) {
                setState(() {
                  expandedIndex = expanded ? index : null;
                });
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              title: Text(
                faqs[index]['q'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              trailing: Icon(
                expandedIndex == index
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: AppColors.primaryBlue,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: AppColors.textDark.withValues(alpha: 0.05),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        faqs[index]['a'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: AppColors.textLight,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 100)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _buildResourceCards(bool isSmallScreen) {
    final resources = _getResourceContent();
    return List.generate(
      resources.length,
      (index) => Column(
        children: [
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getResourceColor(index).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      resources[index]['icon'],
                      color: _getResourceColor(index),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resources[index]['title'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resources[index]['desc'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 100)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Map<String, String>> _getFAQContent() {
    switch (widget.topic) {
      case 'syncing':
        return [
          {
            'q': 'How do I sync tasks across devices?',
            'a':
                'Your tasks are automatically synced when you\'re logged in with your account. Just make sure you have an active internet connection and are using the same account on all devices.',
          },
          {
            'q': 'Why aren\'t my tasks syncing?',
            'a':
                'Check your internet connection and ensure you\'re logged in. If issues persist, try logging out and back in. You can also go to Settings > Sync & Backup > Force Sync.',
          },
          {
            'q': 'Can I sync with other applications?',
            'a':
                'Currently, Do Now syncs within the Do Now ecosystem. We\'re working on integrations with popular tools. Subscribe to updates for announcements.',
          },
          {
            'q': 'How often are tasks synced?',
            'a':
                'Tasks sync in real-time when changes are made. In offline mode, they sync automatically when reconnected.',
          },
        ];
      case 'reminders':
        return [
          {
            'q': 'How do I set a reminder for a task?',
            'a':
                'When creating or editing a task, tap the reminder bell icon and select your preferred time. You can set multiple reminders per task.',
          },
          {
            'q': 'Why am I not getting notifications?',
            'a':
                'Check your device notification settings. Go to Settings > Notifications and enable notifications for Do Now. Also verify the Notification Permissions in the app.',
          },
          {
            'q': 'Can I customize reminder sounds?',
            'a':
                'Yes! Go to Settings > Notifications > Sound and choose from our curated selection of notification sounds.',
          },
          {
            'q': 'How many reminders can I set?',
            'a':
                'You can set up to 5 reminders per task on the Free plan, and unlimited on Premium.',
          },
        ];
      case 'security':
        return [
          {
            'q': 'How secure is my data?',
            'a':
                'We use military-grade encryption (256-bit SSL) to protect your data. All communications are encrypted end-to-end.',
          },
          {
            'q': 'How do I enable Two-Factor Authentication?',
            'a':
                'Go to Settings > Security & Privacy > Two-Factor Authentication. Follow the setup wizard to enable 2FA on your account.',
          },
          {
            'q': 'Can I use biometric authentication?',
            'a':
                'Yes! Enable Face ID or Fingerprint in Settings > Security & Privacy > Biometric Authentication for quick and secure access.',
          },
          {
            'q': 'What happens if I forget my password?',
            'a':
                'Use the "Forgot Password" link on the login screen. You\'ll receive an email to reset your password securely.',
          },
        ];
      case 'premium':
        return [
          {
            'q': 'What premium features are available?',
            'a':
                'Premium includes: Unlimited tasks, Collaboration, Advanced Analytics, Priority Support, Ad-free experience, and Custom themes.',
          },
          {
            'q': 'How much does Premium cost?',
            'a':
                'Premium is \$4.99/month or \$39.99/year. You get a 7-day free trial before any charges.',
          },
          {
            'q': 'Can I cancel my subscription?',
            'a':
                'Yes, anytime! Go to Settings > Subscription > Manage Subscription to cancel. Your access continues until the end of your billing period.',
          },
          {
            'q': 'Is there a family plan?',
            'a':
                'Yes! Our Family Plan allows up to 6 family members to share premium features for \$9.99/month. Set it up in Settings > Subscription > Family Plan.',
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getResourceContent() {
    switch (widget.topic) {
      case 'syncing':
        return [
          {
            'title': 'Sync Settings',
            'desc': 'Manage sync preferences',
            'icon': Icons.settings_rounded,
          },
          {
            'title': 'Offline Mode',
            'desc': 'Work without internet',
            'icon': Icons.cloud_off_rounded,
          },
          {
            'title': 'Backup & Restore',
            'desc': 'Backup your tasks',
            'icon': Icons.backup_rounded,
          },
        ];
      case 'reminders':
        return [
          {
            'title': 'Smart Reminders',
            'desc': 'AI-powered suggestions',
            'icon': Icons.lightbulb_rounded,
          },
          {
            'title': 'Notification Center',
            'desc': 'Manage notifications',
            'icon': Icons.notifications_rounded,
          },
          {
            'title': 'Recurring Reminders',
            'desc': 'Set repeating alerts',
            'icon': Icons.repeat_rounded,
          },
        ];
      case 'security':
        return [
          {
            'title': 'Privacy Policy',
            'desc': 'Read our privacy policy',
            'icon': Icons.privacy_tip_rounded,
          },
          {
            'title': 'Device Security',
            'desc': 'Secure your device',
            'icon': Icons.devices_rounded,
          },
          {
            'title': 'Data Export',
            'desc': 'Export your data',
            'icon': Icons.download_rounded,
          },
        ];
      case 'premium':
        return [
          {
            'title': 'Features',
            'desc': 'See all premium features',
            'icon': Icons.star_rounded,
          },
          {
            'title': 'Compare Plans',
            'desc': 'View pricing details',
            'icon': Icons.compare_rounded,
          },
          {
            'title': 'Upgrade Now',
            'desc': 'Start your free trial',
            'icon': Icons.upgrade_rounded,
          },
        ];
      default:
        return [];
    }
  }

  Color _getResourceColor(int index) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.success,
      AppColors.warning,
    ];
    return colors[index % colors.length];
  }
}
