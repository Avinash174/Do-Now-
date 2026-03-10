import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';
import '../utils/shimmer_utils.dart';

class DataExportView extends StatefulWidget {
  const DataExportView({super.key});

  @override
  State<DataExportView> createState() => _DataExportViewState();
}

class _DataExportViewState extends State<DataExportView> {
  bool _includeTasks = true;
  bool _includeNotes = true;
  bool _includeAnalytics = true;
  bool _includeSettings = true;
  String _format = 'json'; // json or csv
  bool _isExporting = false;

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
          color: theme.textTheme.titleLarge?.color ?? AppColors.textDark,
        ),
        title: Text(
          'Data Export',
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
                      AppColors.info.withValues(alpha: 0.1),
                      AppColors.success.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.info, AppColors.success],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.cloud_download_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    Text(
                      'Export Your Data',
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
                      'Download all your data in a convenient format',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color:
                            theme.textTheme.bodySmall?.color ??
                            AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Format Selection
              Text(
                'EXPORT FORMAT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.textTheme.bodySmall?.color ?? AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormatOption(
                      title: 'JSON',
                      subtitle: 'Machine readable',
                      value: 'json',
                      isSelected: _format == 'json',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormatOption(
                      title: 'CSV',
                      subtitle: 'Excel compatible',
                      value: 'csv',
                      isSelected: _format == 'csv',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Data Selection
              Text(
                'SELECT DATA TO EXPORT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.textTheme.bodySmall?.color ?? AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildDataSelectionTile(
                icon: Icons.task_alt_rounded,
                title: 'Tasks',
                subtitle: 'All your tasks and reminders',
                value: _includeTasks,
                onChanged: (value) => setState(() => _includeTasks = value),
                size: '~2.3 MB',
              ),
              const SizedBox(height: 12),
              _buildDataSelectionTile(
                icon: Icons.note_outlined,
                title: 'Notes',
                subtitle: 'Task notes and descriptions',
                value: _includeNotes,
                onChanged: (value) => setState(() => _includeNotes = value),
                size: '~0.8 MB',
              ),
              const SizedBox(height: 12),
              _buildDataSelectionTile(
                icon: Icons.analytics_outlined,
                title: 'Analytics',
                subtitle: 'Your productivity statistics',
                value: _includeAnalytics,
                onChanged: (value) => setState(() => _includeAnalytics = value),
                size: '~0.5 MB',
              ),
              const SizedBox(height: 12),
              _buildDataSelectionTile(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'App preferences and configurations',
                value: _includeSettings,
                onChanged: (value) => setState(() => _includeSettings = value),
                size: '~0.1 MB',
              ),
              const SizedBox(height: 24),
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Total size: ~3.7 MB. The export will be sent to your email.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color:
                              theme.textTheme.titleSmall?.color ??
                              AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Export button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.info],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isExporting ? null : _exportData,
                      borderRadius: BorderRadius.circular(24),
                      child: Center(
                        child: _isExporting
                            ? const ShimmerLoading(
                                width: double.infinity,
                                height: 56,
                                borderRadius: 24,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Export Data',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _exportData() async {
    setState(() => _isExporting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isExporting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Export started! Check your email for the download link.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildFormatOption({
    required String title,
    required String subtitle,
    required String value,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _format = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.info.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withValues(alpha: 0.8),
                    AppColors.success,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                value == 'json'
                    ? Icons.data_object_rounded
                    : Icons.table_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleMedium?.color ?? AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color ?? AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSelectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required String size,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? AppColors.success.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.1),
          width: value ? 2 : 1,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.1),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.8),
                  AppColors.info,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        theme.textTheme.titleMedium?.color ??
                        AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth * 0.7,
                          child: Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color:
                                  theme.textTheme.bodySmall?.color ??
                                  AppColors.textMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          size,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color:
                                theme.textTheme.bodySmall?.color ??
                                AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.success,
              side: BorderSide(
                color: value ? AppColors.success : theme.dividerColor,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
