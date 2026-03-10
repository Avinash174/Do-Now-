import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Help Center',
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.bodyLarge?.color ?? AppColors.textDark,
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
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search_rounded,
                      color:
                          theme.textTheme.bodySmall?.color ??
                          AppColors.textLight,
                    ),
                    hintText: 'Search help...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color:
                          theme.textTheme.bodySmall?.color ??
                          AppColors.textLight,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionHeader('POPULAR TOPICS', isSmallScreen, context),
              const SizedBox(height: 16),
              _buildHelpTile(
                context,
                'Syncing Tasks',
                Icons.sync_rounded,
                isSmallScreen,
                () {
                  Navigator.pushNamed(
                    context,
                    '/help_topic_details',
                    arguments: {'title': 'Syncing Tasks', 'topic': 'syncing'},
                  );
                },
              ),
              _buildHelpTile(
                context,
                'Creating Reminders',
                Icons.alarm_rounded,
                isSmallScreen,
                () {
                  Navigator.pushNamed(
                    context,
                    '/help_topic_details',
                    arguments: {
                      'title': 'Creating Reminders',
                      'topic': 'reminders',
                    },
                  );
                },
              ),
              _buildHelpTile(
                context,
                'Account Security',
                Icons.security_rounded,
                isSmallScreen,
                () {
                  Navigator.pushNamed(
                    context,
                    '/help_topic_details',
                    arguments: {
                      'title': 'Account Security',
                      'topic': 'security',
                    },
                  );
                },
              ),
              _buildHelpTile(
                context,
                'Premium Features',
                Icons.star_outline_rounded,
                isSmallScreen,
                () {
                  Navigator.pushNamed(
                    context,
                    '/help_topic_details',
                    arguments: {
                      'title': 'Premium Features',
                      'topic': 'premium',
                    },
                  );
                },
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('CONTACT US', isSmallScreen, context),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Need more help?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our support team is available 24/7 to assist you.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/support_chat');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24 : 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Chat with Us',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isSmallScreen,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: isSmallScreen ? 11 : 12,
        fontWeight: FontWeight.w800,
        color: theme.textTheme.bodySmall?.color ?? AppColors.textLight,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildHelpTile(
    BuildContext context,
    String title,
    IconData icon,
    bool isSmallScreen,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color ?? AppColors.textDark,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: theme.textTheme.bodySmall?.color ?? AppColors.textLight,
            size: 20,
          ),
        ),
        Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
