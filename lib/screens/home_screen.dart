
import 'package:flutter/material.dart';

import '../data/task_repository.dart';
import '../models/task.dart';
import '../routes/app_routes.dart';
import '../screens/all_tasks_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'courses.screen.dart';
import '../data/course_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final TaskRepository _repository = TaskRepository();
  final CourseRepository _courseRepository = CourseRepository();

  List<Task> _tasks = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _repository.fetchTasks();

      if (!mounted) return;

      setState(() {
        _tasks = List<Task>.of(tasks);
        _tasks.sort(
          (a, b) => a.deadline.compareTo(b.deadline),
        );
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  
Future<void> _addTask() async {
  final newTask = await Navigator.push<Task>(
    context,
    MaterialPageRoute<Task>(
      builder: (_) => const AddTaskScreen(),
    ),
  );

  if (!mounted || newTask == null) return;

  setState(() {
    _tasks.add(newTask);
    _tasks.sort(
      (a, b) => a.deadline.compareTo(b.deadline),
    );
  });

  _showMessage('Task berhasil ditambahkan!');
}


  void _toggleTask(Task task, bool? value) {
    if (value == null) return;

    final index = _tasks.indexWhere(
      (item) => identical(item, task),
    );

    if (index == -1) return;

    setState(() {
      _tasks[index] = task.copyWith(isCompleted: value);
    });
  }

  
void _openAllTasks() {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => AllTasksScreen(
        tasks: _tasks,
        onTaskChanged: (oldTask, updatedTask) {
          final index = _tasks.indexWhere(
            (item) => identical(item, oldTask),
          );

          if (index == -1) return;

          setState(() {
            _tasks[index] = updatedTask;
            _tasks.sort(
              (a, b) => a.deadline.compareTo(b.deadline),
            );
          });
        },
        onTaskTap: _openTaskDetail,
        onTaskDeleted: _deleteTask,
      ),
    ),
  );
}


  void _openTaskDetail(Task task) {
    Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: task,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  
Future<void> _editTask(Task task) async {
  final updatedTask = await Navigator.push<Task>(
    context,
    MaterialPageRoute<Task>(
      builder: (_) => AddTaskScreen(initialTask: task),
    ),
  );

  if (!mounted || updatedTask == null) return;

  final index = _tasks.indexWhere(
    (item) => identical(item, task),
  );

  if (index == -1) return;

  setState(() {
    _tasks[index] = updatedTask;
    _tasks.sort(
      (a, b) => a.deadline.compareTo(b.deadline),
    );
  });

  _showMessage('Task berhasil diperbarui!');
}

  
Future<void> _deleteTask(Task task) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hapus Task?'),
      content: Text(
        'Task "${task.title}" akan dihapus. '
        'Apakah kamu yakin?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, false);
          },
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext, true);
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (!mounted || confirmed != true) return;

  final index = _tasks.indexWhere(
    (item) => identical(item, task),
  );

  if (index == -1) return;

  setState(() {
    _tasks.removeAt(index);
  });

  _showMessage('Task berhasil dihapus!');
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          
children: [
  _buildHomeContent(),
  const _PlaceholderTab(label: 'Tasks'),
  const _PlaceholderTab(label: 'Focus'),
  CoursesScreen(repository: _courseRepository),
  const _PlaceholderTab(label: 'Group'),
  const _PlaceholderTab(label: 'Profile'),
],

        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
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
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Mata Kuliah',
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
    final orderedTasks = List<Task>.of(_tasks)
      ..sort(
        (a, b) => a.deadline.compareTo(b.deadline),
      );

    final completedCount =
        _tasks.where((task) => task.isCompleted).length;

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

        if (_tasks.isNotEmpty) ...[
          SummaryCard(
            pendingCount: pendingCount,
            completedCount: completedCount,
            totalCount: _tasks.length,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Task'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSpacing.smallRadius,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        if (_isLoading) ...[
          const LoadingView(),
        ] else if (_errorMessage != null) ...[
          ErrorView(
            message: _errorMessage!,
            onRetry: _loadTasks,
          ),
        ] else if (orderedTasks.isEmpty) ...[
          const EmptyView(
            message: 'Belum ada task. Tambahkan task pertamamu!',
          ),
        ] else ...[
          _SectionHeading(
            title: 'Closest deadline',
            actionLabel: 'View all',
            onAction: _openAllTasks,
          ),
          const SizedBox(height: AppSpacing.md),

          TaskCard(
            task: orderedTasks.first,
            isFeatured: true,
            onChanged: (value) {
              _toggleTask(orderedTasks.first, value);
            },
            onTap: () => _openTaskDetail(orderedTasks.first),
            onEdit: () => _editTask(orderedTasks.first),
            onDelete: () => _deleteTask(orderedTasks.first),
          ),

          if (orderedTasks.length > 1) ...[
            const SizedBox(height: AppSpacing.xxl),
            const _SectionHeading(
              title: 'Upcoming tasks',
            ),
            const SizedBox(height: AppSpacing.md),

            for (var index = 1;
                index < orderedTasks.length;
                index++) ...[
              TaskCard(
                task: orderedTasks[index],
                onChanged: (value) {
                  _toggleTask(orderedTasks[index], value);
                },
                onTap: () {
                  _openTaskDetail(orderedTasks[index]);
                },
                onEdit: () => _editTask(orderedTasks[index]),
                onDelete: () => _deleteTask(orderedTasks[index]),
              ),
              if (index < orderedTasks.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
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
              Text(
                'Good Morning, Sir',
                style: AppTextStyles.heading,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                "Let's get your tasks done.",
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _showMessage(
              'Notifications will be connected later.',
            );
          },
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSpacing.smallRadius,
              ),
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.label,
  });

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
          Text(
            '$label is coming next',
            style: AppTextStyles.title,
          ),
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
