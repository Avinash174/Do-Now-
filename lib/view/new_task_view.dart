import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../view_model/task_view_model.dart';
import '../utils/snackbar_utils.dart';
import '../model/task_model.dart';
import '../utils/shimmer_utils.dart';

class NewTaskView extends ConsumerStatefulWidget {
  final TaskModel? task;
  const NewTaskView({super.key, this.task});

  @override
  ConsumerState<NewTaskView> createState() => _NewTaskViewState();
}

class _NewTaskViewState extends ConsumerState<NewTaskView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _scrollController = ScrollController();
  final _titleFocus = FocusNode();
  final _descFocus = FocusNode();
  String _category = 'Work';
  bool _reminder = true;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _titleFocus.addListener(() => setState(() {}));
    _descFocus.addListener(() => setState(() {}));
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _category = widget.task!.category;
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(
        widget.task!.scheduleTime,
      );
      // Default reminder to true when editing; 
      // if schedule is in the past, disable reminder automatically
      _reminder = widget.task!.scheduleTime > DateTime.now().millisecondsSinceEpoch;
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Work',
      'icon': Icons.work_outline_rounded,
      'color': AppColors.catWork,
    },
    {
      'name': 'Personal',
      'icon': Icons.person_outline_rounded,
      'color': AppColors.catPersonal,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_outlined,
      'color': AppColors.catShopping,
    },
    {
      'name': 'Health',
      'icon': Icons.favorite_outline_rounded,
      'color': AppColors.catHealth,
    },
    {
      'name': 'Finance',
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.catFinance,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz_rounded,
      'color': AppColors.primaryBlue,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _scrollController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              textStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(
        () => _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              textStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(
        () => _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HapticFeedback.heavyImpact();
      SnackbarUtils.showWarning(
        context,
        'Hold on!',
        'Please enter a task title before saving.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final vm = ref.read(taskViewModelProvider);
      if (widget.task != null) {
        await vm?.updateTaskDetails(
          taskId: widget.task!.id,
          title: title,
          description: _descController.text.trim(),
          category: _category,
          scheduleDate: _selectedDate,
          reminderEnabled: _reminder,
        );
      } else {
        await vm?.addTask(
          title: title,
          description: _descController.text.trim(),
          category: _category,
          scheduleDate: _selectedDate,
          reminderEnabled: _reminder,
        );
      }
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Snap!', 'Could not save task: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formattedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  String _formattedTime() {
    final h = _selectedDate.hour;
    final m = _selectedDate.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient Header (Sanctuary Style)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.primaryBlue.withValues(alpha: 0.15),
                          AppColors.primaryBlue.withValues(alpha: 0.05),
                          Theme.of(context).scaffoldBackgroundColor,
                        ]
                      : [
                          AppColors.primaryBlue,
                          AppColors.primaryBlue.withValues(alpha: 0.8),
                          AppColors.primaryBlue.withValues(alpha: 0.6),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withValues(
                          alpha: isDark ? 0.05 : 0.1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withValues(
                          alpha: isDark ? 0.03 : 0.05,
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: isDark ? 0.05 : 0.1,
                    child: Center(
                      child:
                          Icon(
                                widget.task != null
                                    ? Icons.edit_note_rounded
                                    : Icons.add_task_rounded,
                                size: 220,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.white,
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                duration: 3.seconds,
                                begin: const Offset(1, 1),
                                end: const Offset(1.1, 1.1),
                              )
                              .fadeIn(duration: 1.seconds),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar (Sanctuary Style)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(
                        icon: Icons.close_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        isSmallScreen: isSmallScreen,
                        isDark: isDark,
                      ),
                      Text(
                        widget.task != null ? 'Edit Task' : 'New Task',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? AppColors.white : AppColors.white,
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      _buildHeaderButton(
                        icon: Icons.more_horiz_rounded,
                        onTap: () => HapticFeedback.lightImpact(),
                        isSmallScreen: isSmallScreen,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.05,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Input Section
                            _buildSectionLabel(
                              'TASK INFORMATION',
                              Icons.edit_note_rounded,
                              isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _titleController,
                              focusNode: _titleFocus,
                              hintText: 'What needs to be done?',
                              label: 'Task Title',
                              maxLines: 1,
                              isDark: isDark,
                              icon: Icons.title_rounded,
                            ),

                            const SizedBox(height: 24),

                            // Description Input Section
                            _buildInputField(
                              controller: _descController,
                              focusNode: _descFocus,
                              hintText:
                                  'Add some more details about this task...',
                              label: 'Description',
                              maxLines: 4,
                              isDark: isDark,
                              icon: Icons.description_outlined,
                            ),

                            const SizedBox(height: 32),

                            // Schedule Section
                            _buildSectionLabel(
                              'PLANNING & SCHEDULE',
                              Icons.calendar_today_rounded,
                              isDark,
                            ),
                            const SizedBox(height: 16),
                            Row(
                                  children: [
                                    Expanded(
                                      child: _buildPickerCard(
                                        title: 'Due Date',
                                        value: _formattedDate(),
                                        icon: Icons.event_rounded,
                                        color: AppColors.primaryBlue,
                                        onTap: _pickDate,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPickerCard(
                                        title: 'Time',
                                        value: _formattedTime(),
                                        icon: Icons.access_time_filled_rounded,
                                        color: AppColors.warning,
                                        onTap: _pickTime,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideX(begin: 0.1, end: 0),

                            const SizedBox(height: 32),

                            // Category Section
                            _buildSectionLabel(
                              'CATEGORY & CONTEXT',
                              Icons.grid_view_rounded,
                              isDark,
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: size.width > 600 ? 4 : 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2.1,
                                  ),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                final isSelected = _category == cat['name'];
                                final Color color = cat['color'];
                                return GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _category = cat['name']);
                                      },
                                      child: AnimatedContainer(
                                        duration: 300.ms,
                                        curve: Curves.easeOutCubic,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? color.withValues(alpha: 1.0)
                                              : isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.04,
                                                )
                                              : AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? color
                                                : isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : Theme.of(
                                                    context,
                                                  ).dividerColor,
                                            width: 1.5,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: color.withValues(
                                                      alpha: 0.3,
                                                    ),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? Icons.check_rounded
                                                    : cat['icon'],
                                                size: 16,
                                                color: isSelected
                                                    ? AppColors.white
                                                    : isDark
                                                    ? color.withValues(
                                                        alpha: 0.8,
                                                      )
                                                    : color,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  cat['name'],
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        color: isSelected
                                                            ? AppColors.white
                                                            : Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w800
                                                            : FontWeight.w600,
                                                        fontSize: 12,
                                                        letterSpacing: -0.2,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: (100 * (index / 3)).ms)
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1, 1),
                                    );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Notifications Section
                            _buildNotificationCard(isDark),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar (Sanctuary Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0),
                    Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0.9),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: _isLoading
                  ? const ShimmerLoading(
                      width: double.infinity,
                      height: 58,
                      borderRadius: 18,
                    )
                  : Hero(
                      tag: 'task_button',
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              _saveTask();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.task != null
                                        ? Icons.save_rounded
                                        : Icons.add_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.task != null
                                        ? 'Update Task'
                                        : 'Create Task',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
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
                    ).animate().slideY(
                      begin: 0.5,
                      end: 0,
                      curve: Curves.easeOutBack,
                      duration: 600.ms,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String label,
    required int maxLines,
    required bool isDark,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: focusNode.hasFocus
            ? (isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : AppColors.background.withValues(alpha: 0.5))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColors.primaryBlue
              : isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Theme.of(context).dividerColor,
          width: focusNode.hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: focusNode.hasFocus
                      ? AppColors.primaryBlue
                      : Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: focusNode.hasFocus
                        ? AppColors.primaryBlue
                        : Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            child: Icon(
              icon,
              color: isDark ? AppColors.white : AppColors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildPickerCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Theme.of(context).dividerColor,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Get reminded about this task',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _reminder,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              setState(() => _reminder = v);
            },
            activeThumbColor: AppColors.success,
            activeTrackColor: AppColors.success.withValues(alpha: 0.3),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
