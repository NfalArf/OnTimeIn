import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Task> _tasks = [
    const Task(
      title: 'Mobile Programming Assignment',
      course: 'Pemrograman Mobile',
      deadline: 'Tomorrow, 23:59',
      priority: TaskPriority.high,
    ),
    const Task(
      title: 'Database Report',
      course: 'Basis Data',
      deadline: '25 Sep, 23:59',
      priority: TaskPriority.medium,
    ),
    const Task(
      title: 'Read Chapter 4 and make notes',
      course: 'Human Computer Interaction',
      deadline: '27 Sep, 10:00',
      priority: TaskPriority.normal,
    ),
    const Task(
      title: 'Group presentation outline',
      course: 'Software Engineering',
      deadline: '30 Sep, 16:00',
      priority: TaskPriority.normal,
      isCompleted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            for (final label in const ['Tasks', 'Focus', 'Group', 'Profile'])
              _PlaceholderTab(label: label),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Group',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final completedCount = _tasks.where((task) => task.isCompleted).length;
    final pendingCount = _tasks.length - completedCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.xl),
        SummaryCard(
          pendingCount: pendingCount,
          completedCount: completedCount,
          totalCount: _tasks.length,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () =>
              _showMessage('Add Task flow will be connected later.'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Task'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _SectionHeading(title: 'Closest deadline', actionLabel: 'View all'),
        const SizedBox(height: AppSpacing.md),
        TaskCard(
          task: _tasks.first,
          isFeatured: true,
          onChanged: (value) => _toggleTask(0, value),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _SectionHeading(title: 'Upcoming tasks'),
        const SizedBox(height: AppSpacing.md),
        for (var index = 1; index < _tasks.length; index++) ...[
          TaskCard(
            task: _tasks[index],
            onChanged: (value) => _toggleTask(index, value),
          ),
          if (index < _tasks.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning, Naufal', style: AppTextStyles.heading),
              SizedBox(height: AppSpacing.sm),
              Text('Let\'s get your tasks done.', style: AppTextStyles.body),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              _showMessage('Notifications will be connected later.'),
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  void _toggleTask(int index, bool? value) {
    if (value == null) return;
    setState(() => _tasks[index] = _tasks[index].copyWith(isCompleted: value));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            child: Text(
              actionLabel!,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.construction_outlined,
            size: 38,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('$label is coming next', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This prototype is focused on Home.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
