import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

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
          'Privacy Policy',
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.titleLarge?.color ?? AppColors.textDark,
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
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue.withValues(alpha: 0.1),
                      AppColors.primaryAccent.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    Text(
                      'Your Privacy Matters',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            theme.textTheme.titleMedium?.color ??
                            AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: March 10, 2026',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.6,
                            ) ??
                            AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                context: context,
                title: 'Introduction',
                content: 'Welcome to Do Now ("the App," "we," "us," "our").',
                items: const [
                  'We are committed to protecting your privacy and ensuring you have a positive experience on our platform.',
                  'This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our App.',
                  'Please read this policy carefully and contact us if you have any questions.',
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context: context,
                title: 'Information We Collect',
                items: const [
                  'Account Information: Name, email address, phone number, and profile picture.',
                  'Task Data: Your tasks, reminders, notes, categories, and due dates.',
                  'Device Information: Device type, OS version, unique device identifiers.',
                  'Usage Data: How you interact with our App, features used, time spent.',
                  'Location Data: With your permission, we may collect your approximate location.',
                  'Payment Information: Processed securely through third-party payment providers.',
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context: context,
                title: 'How We Use Your Information',
                items: const [
                  'To provide, maintain, and improve our App and services.',
                  'To process transactions and send related communications.',
                  'To send transactional emails and important notifications.',
                  'To personalize your experience and deliver targeted content.',
                  'To analyze usage patterns and improve user experience.',
                  'To comply with legal obligations and protect our rights.',
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context: context,
                title: 'Data Security',
                items: const [
                  'We implement industry-standard security measures including encryption.',
                  'All data transmitted between your device and our servers is encrypted using SSL/TLS.',
                  'Biometric data is stored securely on your device and never transmitted to our servers.',
                  'Access to personal information is restricted to authorized personnel only.',
                  'We regularly update our security protocols and conduct security audits.',
                  'No security system is impenetrable; we cannot guarantee absolute security.',
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context: context,
                title: 'Your Privacy Rights',
                items: const [
                  'Right to Access: You can request a copy of your personal data.',
                  'Right to Rectification: You can correct inaccurate information.',
                  'Right to Deletion: You can request deletion of your data (Right to be Forgotten).',
                  'Right to Data Portability: You can export your data in a portable format.',
                  'Right to Opt-out: You can opt-out of certain data processing activities.',
                  'Right to Lodge a Complaint: Contact your local data protection authority.',
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context: context,
                title: 'Third-Party Services',
                items: const [
                  'We use Firebase for authentication and data storage.',
                  'Google Sign-In is used for convenient account creation and login.',
                  'Analytics services help us understand how users interact with our App.',
                  'These third parties have their own privacy policies that we encourage you to review.',
                  'We do not sell or share your personal data with third parties for marketing.',
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context: context,
                title: 'Contact Us',
                items: const [
                  'Email: privacy@donow.app',
                  'Address: 123 Task Street, San Francisco, CA 94102, USA',
                  'Data Protection Officer: dpo@donow.app',
                  'Response Time: We aim to respond to all inquiries within 30 days.',
                ],
              ),
              const SizedBox(height: 32),
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We comply with GDPR, CCPA, and other privacy regulations',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  theme.textTheme.bodyMedium?.color ??
                                  AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSection({
    required BuildContext context,
    required String title,
    String? content,
    List<String> items = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryBlue,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (content != null) ...[
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.textDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryAccent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                AppColors.textDark,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
