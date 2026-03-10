import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../model/task_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../view_model/task_view_model.dart';
import '../routes/app_routes.dart';
import 'profile_view.dart';
import 'stats_view.dart';
import '../utils/shimmer_utils.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return AppColors.catWork;
      case 'Personal':
        return AppColors.catPersonal;
      case 'Shopping':
        return AppColors.catShopping;
      case 'Health':
        return AppColors.catHealth;
      case 'Finance':
        return AppColors.catFinance;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work_outline_rounded;
      case 'Personal':
        return Icons.person_outline_rounded;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Health':
        return Icons.favorite_outline_rounded;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildTaskItem(TaskModel task) {
    final vm = ref.read(taskViewModelProvider);
    final categoryColor = _getCategoryColor(task.category);
    final categoryIcon = _getCategoryIcon(task.category);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        vm?.deleteTask(task.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.danger,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.pushNamed(context, AppRoutes.newTask, arguments: task);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: task.isCompleted
                  ? Colors.transparent
                  : Theme.of(context).dividerColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: task.isCompleted ? 0.01 : 0.02,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 48 : 54,
                height: isSmallScreen ? 48 : 54,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: isSmallScreen ? 22 : 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: task.isCompleted
                            ? Theme.of(context).textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.5)
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTaskTime(task.scheduleTime),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (task.category.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            task.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: categoryColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  vm?.toggleTask(task.id, task);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSmallScreen ? 24 : 28,
                  height: isSmallScreen ? 24 : 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? AppColors.primaryBlue
                        : AppColors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.primaryBlue
                          : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: isSmallScreen ? 14 : 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTaskTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final h = date.hour;
    final m = date.minute.toString().padLeft(2, '0');
    final p = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $p';
  }

  Widget _buildFilterChip(String label, TaskFilter filter) {
    final currentFilter = ref.watch(taskFilterProvider);
    final isSelected = currentFilter == filter;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(taskFilterProvider.notifier).update(filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 18 : 24,
          vertical: isSmallScreen ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Theme.of(context).dividerColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: isSmallScreen ? 13 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final userAsync = ref.watch(userProfileProvider);
    final user = ref.watch(authStateProvider).value;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final userName = userAsync.when(
      data: (data) =>
          (data?['name']?.toString() ?? user?.displayName ?? 'User'),
      loading: () => '...',
      error: (err, stack) => user?.displayName ?? 'User',
    );
    final userEmail = userAsync.when(
      data: (data) => data?['email']?.toString() ?? user?.email ?? '',
      loading: () => '',
      error: (err, stack) => user?.email ?? '',
    );
    final photoUrl = userAsync.when(
      data: (data) => data?['photoUrl']?.toString(),
      loading: () => null,
      error: (err, stack) => null,
    );

    final stats = ref.watch(taskStatsProvider);
    final pendingCount = stats['pending'] as int;
    final progressRate = stats['rate'] as double;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => ref.refresh(tasksProvider),
        color: AppColors.primaryBlue,
        backgroundColor: Theme.of(context).cardColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.06,
                  isSmallScreen ? 10 : 20,
                  size.width * 0.06,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(userName, userEmail, photoUrl)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.1, end: 0),
                    SizedBox(height: isSmallScreen ? 20 : 32),
                    _buildProgressCard(pendingCount, progressRate)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildSearchBar().animate().fadeIn(delay: 300.ms),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildSectionHeader(
                      'Filters',
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip('All', TaskFilter.all),
                              _buildFilterChip('Active', TaskFilter.pending),
                              _buildFilterChip(
                                'Completed',
                                TaskFilter.completed,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 450.ms)
                        .slideX(begin: 0.1, end: 0),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    _buildSectionHeader(
                      'Tasks',
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildTaskListSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String name, String email, String? photoUrl) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: isSmallScreen ? 7 : 9,
                        height: isSmallScreen ? 7 : 9,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 16),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 2),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryAccent],
                  ),
                ),
                child: CircleAvatar(
                  radius: isSmallScreen ? 20 : 24,
                  backgroundColor: AppColors.white,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(int pending, double rate) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryAccent],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.rocket_launch_rounded,
              size: isSmallScreen ? 80 : 100,
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Goals',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${(rate * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.white,
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: AppColors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.white,
                    ),
                    minHeight: isSmallScreen ? 7 : 10,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  pending == 0
                      ? 'All tasks done! 👏'
                      : '$pending tasks remaining for today',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: _searchController,
        onChanged: (v) => ref.read(taskSearchProvider.notifier).update(v),
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search your tasks...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryBlue,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color:
            Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textDark,
      ),
    );
  }

  Widget _buildTaskListSliver() {
    final tasks = ref.watch(filteredTasksProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (_) {
        if (tasks.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyTasks(),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTaskItem(tasks[index])
                  .animate()
                  .fadeIn(delay: (index * 50).ms)
                  .slideY(begin: 0.1, end: 0),
              childCount: tasks.length,
            ),
          ),
        );
      },
      loading: () => const SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 16),
        sliver: SliverToBoxAdapter(child: ShimmerList(itemCount: 6)),
      ),
      error: (err, stack) =>
          SliverFillRemaining(child: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildEmptyTasks() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: AppColors.textLight.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = Theme.of(context).cardColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: navBarColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            const StatsView(),
            const ProfileView(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _selectedIndex == 0
            ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, AppRoutes.newTask);
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      focusElevation: 0,
                      highlightElevation: 0,
                      hoverElevation: 0,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      label: Text(
                        'New Task',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .scale(delay: 300.ms, curve: Curves.easeOutBack)
                  .fadeIn()
            : null,
      ),
    );
  }

  Widget _buildBottomNav() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Theme.of(
            context,
          ).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 10 : 12,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 10 : 12,
          ),
          selectedFontSize: isSmallScreen ? 10 : 12,
          unselectedFontSize: isSmallScreen ? 10 : 12,
          iconSize: isSmallScreen ? 20 : 24,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
