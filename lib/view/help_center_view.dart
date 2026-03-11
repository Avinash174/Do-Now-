import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class HelpCenterView extends StatefulWidget {
  const HelpCenterView({super.key});

  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView> {
  final _searchController = TextEditingController();
  String _query = '';

  static const List<Map<String, dynamic>> _allTopics = [
    {
      'title': 'Syncing Tasks',
      'icon': Icons.sync_rounded,
      'topic': 'syncing',
      'tags': ['sync', 'device', 'cloud', 'offline'],
    },
    {
      'title': 'Creating Reminders',
      'icon': Icons.alarm_rounded,
      'topic': 'reminders',
      'tags': ['alarm', 'reminder', 'notification', 'time'],
    },
    {
      'title': 'Account Security',
      'icon': Icons.security_rounded,
      'topic': 'security',
      'tags': ['security', 'password', '2fa', 'account', 'protect'],
    },
    {
      'title': 'Premium Features',
      'icon': Icons.star_outline_rounded,
      'topic': 'premium',
      'tags': ['premium', 'upgrade', 'subscription', 'plan', 'features'],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _allTopics;
    final q = _query.toLowerCase();
    return _allTopics.where((t) {
      final title = (t['title'] as String).toLowerCase();
      final tags = (t['tags'] as List<String>);
      return title.contains(q) || tags.any((tag) => tag.contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.textDark;
    final mutedColor = theme.textTheme.bodySmall?.color ?? AppColors.textLight;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(color: textColor),
        title: Text(
          'Help Center',
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _query.isNotEmpty
                        ? AppColors.primaryBlue.withValues(alpha: 0.5)
                        : theme.dividerColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                  cursorColor: AppColors.primaryBlue,
                  decoration: InputDecoration(
                    hintText: 'Search help topics...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: mutedColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: _query.isNotEmpty
                          ? AppColors.primaryBlue
                          : mutedColor.withValues(alpha: 0.5),
                      size: 22,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, color: mutedColor, size: 20),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            ),

            // ── Results ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_filtered.isEmpty) ...[
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: mutedColor.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results for "$_query"',
                              style: GoogleFonts.plusJakartaSans(
                                color: mutedColor.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(),
                      ),
                    ] else ...[
                      _buildSectionHeader(
                        _query.isNotEmpty ? 'SEARCH RESULTS' : 'POPULAR TOPICS',
                        isSmallScreen,
                        mutedColor,
                      ),
                      const SizedBox(height: 16),
                      ..._filtered.asMap().entries.map((e) {
                        final i = e.key;
                        final t = e.value;
                        return _buildHelpTile(
                          context,
                          t['title'] as String,
                          t['icon'] as IconData,
                          t['topic'] as String,
                          isSmallScreen,
                          i,
                          textColor,
                          mutedColor,
                        );
                      }),
                    ],

                    const SizedBox(height: 32),

                    // ── Contact Card ─────────────────────────────────
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
                              HapticFeedback.lightImpact();
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
                    ).animate().fadeIn(delay: 300.ms),
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

  Widget _buildSectionHeader(String title, bool small, Color muted) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: small ? 11 : 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlue,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildHelpTile(
    BuildContext context,
    String title,
    IconData icon,
    String topic,
    bool small,
    int index,
    Color textColor,
    Color mutedColor,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pushNamed(
                context,
                '/help_topic_details',
                arguments: {'title': title, 'topic': topic},
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryBlue,
                      size: small ? 18 : 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: small ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: mutedColor.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(color: theme.dividerColor.withValues(alpha: 0.08)),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: index * 60)).slideY(begin: 0.05, end: 0);
  }
}
