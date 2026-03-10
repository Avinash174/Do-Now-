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
                )
              : const ColorScheme.light(
                  primary: AppColors.primaryBlue,
                  onPrimary: AppColors.white,
                  onSurface: AppColors.textDark,
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
                )
              : const ColorScheme.light(
                  primary: AppColors.primaryBlue,
                  onPrimary: AppColors.white,
                  onSurface: AppColors.textDark,
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
        );
      } else {
        await vm?.addTask(
          title: title,
          description: _descController.text.trim(),
          category: _category,
          scheduleDate: _selectedDate,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlue.withValues(alpha: 0.8),
                    AppColors.primaryBlue.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Opacity(
                opacity: 0.1,
                child: Center(
                  child: Icon(
                    widget.task != null
                        ? Icons.edit_note_rounded
                        : Icons.add_task_rounded,
                    size: 200,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
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
                        onTap: () => Navigator.pop(context),
                        isSmallScreen: isSmallScreen,
                      ),
                      Text(
                        widget.task != null ? 'Edit Task' : 'New Task',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _buildHeaderButton(
                        icon: Icons.more_horiz_rounded,
                        onTap: () {},
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(28, 36, 28, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Input
                            _buildSectionLabel(
                              'Task Title',
                              Icons.edit_note_rounded,
                            ),
                            const SizedBox(height: 12),
                            AnimatedContainer(
                                  duration: 300.ms,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _titleFocus.hasFocus
                                        ? Theme.of(context).cardColor
                                        : Theme.of(context).brightness ==
                                              Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _titleFocus.hasFocus
                                          ? AppColors.primaryBlue
                                          : Theme.of(context).dividerColor,
                                      width: _titleFocus.hasFocus ? 1.5 : 1.0,
                                    ),
                                    boxShadow: _titleFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryBlue
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: TextFormField(
                                    controller: _titleController,
                                    focusNode: _titleFocus,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'What needs to be done?',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.4),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 20,
                                          ),
                                    ),
                                    maxLines: null,
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 32),

                            // Description Input
                            _buildSectionLabel(
                              'Description',
                              Icons.description_outlined,
                            ),
                            const SizedBox(height: 12),
                            AnimatedContainer(
                                  duration: 300.ms,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _descFocus.hasFocus
                                        ? Theme.of(context).cardColor
                                        : Theme.of(context).brightness ==
                                              Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _descFocus.hasFocus
                                          ? AppColors.primaryBlue
                                          : Theme.of(context).dividerColor,
                                      width: _descFocus.hasFocus ? 1.5 : 1.0,
                                    ),
                                    boxShadow: _descFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryBlue
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: TextFormField(
                                    controller: _descController,
                                    focusNode: _descFocus,
                                    maxLines: 5,
                                    minLines: 3,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      height: 1.5,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add some more details...',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.5),
                                        fontSize: 14,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 32),

                            // Schedule Section
                            _buildSectionLabel(
                              'Schedule',
                              Icons.calendar_today_rounded,
                            ),
                            const SizedBox(height: 16),
                            Row(
                                  children: [
                                    Expanded(
                                      child: _buildPickerCard(
                                        title: 'Date',
                                        value: _formattedDate(),
                                        icon: Icons.event_note_rounded,
                                        color: AppColors.primaryBlue,
                                        onTap: _pickDate,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildPickerCard(
                                        title: 'Time',
                                        value: _formattedTime(),
                                        icon: Icons.access_time_filled_rounded,
                                        color: AppColors.warning,
                                        onTap: _pickTime,
                                      ),
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 32),

                            // Category Section
                            _buildSectionLabel(
                              'Category',
                              Icons.grid_view_rounded,
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: size.width > 600
                                            ? 4
                                            : 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 2.2,
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
                                        duration: 400.ms,
                                        curve: Curves.easeOutQuint,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? color
                                              : color.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? color
                                                : color.withValues(alpha: 0.1),
                                            width: 1.5,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: color.withValues(
                                                      alpha: 0.2,
                                                    ),
                                                    blurRadius: 8,
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
                                                    ? Icons.check_circle_rounded
                                                    : cat['icon'],
                                                size: 16,
                                                color: isSelected
                                                    ? AppColors.white
                                                    : color,
                                              ),
                                              const SizedBox(width: 8),
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
                                                            : FontWeight.w700,
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
                                    );
                                  },
                                )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 32),

                            // Reminder Switch
                            Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.notifications_active_rounded,
                                          color: AppColors.success,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Notifications',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                                  ),
                                            ),
                                            Text(
                                              'Remind me when time hits',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: _reminder,
                                        onChanged: (v) =>
                                            setState(() => _reminder = v),
                                        activeTrackColor: AppColors.success,
                                        activeColor: AppColors.white,
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                28,
                24,
                28,
                MediaQuery.of(context).padding.bottom + 20,
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
                    ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: _isLoading
                  ? const ShimmerLoading(
                      width: double.infinity,
                      height: 60,
                      borderRadius: 20,
                    )
                  : Hero(
                          tag: 'task_button',
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
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
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  _saveTask();
                                },
                                borderRadius: BorderRadius.circular(22),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.task != null
                                          ? Icons.published_with_changes_rounded
                                          : Icons.add_task_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.task != null
                                          ? 'Update Task'
                                          : 'Create Task',
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
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.5, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isSmallScreen = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: isSmallScreen ? 18 : 20,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }
}
