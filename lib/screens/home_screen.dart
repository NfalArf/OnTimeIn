import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data/app_data_repository.dart';
import '../data/task_repository.dart';
import '../models/scratchpad.dart';
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
import '../services/notification_service.dart';
import '../services/task_attachment_service.dart';
import '../utils/task_date_windows.dart';
import 'focus_timer_screen.dart';
import 'scratchpad_screen.dart';
import 'group/group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.dataRepository, this.reminderService});

  final AppDataRepository? dataRepository;
  final TaskReminderService? reminderService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  late final AppDataRepository _dataRepository =
      widget.dataRepository ?? AppDataRepository.instance;
  late final TaskRepository _repository = TaskRepository(
    dataRepository: _dataRepository,
  );
  late final CourseRepository _courseRepository = CourseRepository(
    dataRepository: _dataRepository,
  );
  late final TaskReminderService _reminderService =
      widget.reminderService ?? NotificationService.instance;

  List<Task> _tasks = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<String> get _courseNames => {
    ..._courseRepository.getCourses().map((course) => course.name),
    ..._tasks.map((task) => task.course),
  }.toList()..sort();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadTasks();
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
        _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      });
      await _refreshReminders();
      if (mounted && !_reminderService.notificationsEnabled && !kIsWeb) {
        _showMessage('Izin notifikasi belum diberikan.');
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
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
        builder: (_) => AddTaskScreen(courseNames: _courseNames),
      ),
    );

    if (!mounted || newTask == null) return;

    late Task taskWithId;
    try {
      taskWithId = await _repository.addTask(newTask);
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal menyimpan tugas: $error');
      return;
    }

    if (!mounted) return;
    setState(() {
      _tasks.add(taskWithId);
      _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    });
    await _refreshReminders();

    if (!mounted) return;

    _showMessage('Task berhasil ditambahkan!');
  }

  Future<void> _toggleTask(Task task, bool? value) async {
    if (value == null) return;

    try {
      await _updateTask(task.copyWith(isCompleted: value), previousTask: task);
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal memperbarui status tugas: $error');
    }
  }

  void _openAllTasks() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AllTasksScreen(
          tasks: _tasks,
          courseNames: _courseNames,
          onTaskChanged: (oldTask, updatedTask) async {
            await _updateTask(
              updatedTask.copyWith(id: oldTask.id),
              previousTask: oldTask,
            );
          },
          onTaskTap: _openTaskDetail,
          onTaskDeleted: _deleteTask,
        ),
      ),
    );
  }

  Future<void> _openTaskDetail(Task task) async {
    final updatedTask = await Navigator.pushNamed<Task>(
      context,
      AppRoutes.detail,
      arguments: task,
    );
    if (!mounted || updatedTask == null) return;
    try {
      await _replaceTask(task, updatedTask);
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal menyimpan perubahan tugas: $error');
    }
  }

  Future<void> _replaceTask(Task previousTask, Task updatedTask) async {
    final index = _tasks.indexWhere((item) => item.id == previousTask.id);
    if (index == -1) return;

    await _updateTask(updatedTask, previousTask: previousTask);
  }

  Future<void> _editScratchpad(Task task) async {
    final result = await Navigator.push<ScratchpadEditResult>(
      context,
      MaterialPageRoute<ScratchpadEditResult>(
        builder: (_) => ScratchpadScreen(
          initialScratchpad: task.scratchpad,
          taskTitle: task.title,
        ),
      ),
    );
    if (!mounted || result == null) return;

    try {
      await _replaceTask(
        task,
        task.copyWith(
          scratchpad: result.scratchpad,
          clearScratchpad: result.isDeleted,
        ),
      );
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal menyimpan scratchpad: $error');
      return;
    }
    _showMessage(
      result.isDeleted
          ? 'Scratchpad berhasil dihapus'
          : 'Scratchpad berhasil disimpan',
    );
  }

  Future<void> _deleteScratchpad(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Scratchpad?'),
        content: const Text(
          'Catatan, referensi, dan sketsa pada tugas ini akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Hapus Scratchpad'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      await _replaceTask(task, task.copyWith(clearScratchpad: true));
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal menghapus scratchpad: $error');
      return;
    }
    _showMessage('Scratchpad berhasil dihapus');
  }

  Future<void> _startFocus(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(builder: (_) => FocusTimerScreen(task: task)),
    );
    if (!mounted || updatedTask == null) return;

    try {
      await _replaceTask(task, updatedTask);
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal menyimpan waktu fokus: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editTask(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute<Task>(
        builder: (_) =>
            AddTaskScreen(initialTask: task, courseNames: _courseNames),
      ),
    );

    if (!mounted || updatedTask == null) return;

    try {
      await _updateTask(updatedTask.copyWith(id: task.id), previousTask: task);
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal memperbarui tugas: $error');
      return;
    }

    if (!mounted) return;

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

    try {
      await _repository.deleteTask(task.id);
    } on Exception catch (error) {
      if (mounted) _showMessage('Gagal menghapus tugas: $error');
      return;
    }

    if (!mounted) return;
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });

    try {
      await _reminderService.cancelReminders(task.id);
      await TaskAttachmentService.deletePhoto(task.attachmentPath);
    } on Exception catch (error) {
      if (mounted) {
        _showMessage('Task dihapus, tetapi pembersihan data gagal: $error');
      }
    }
    await _refreshDailyReminders();

    if (mounted) _showMessage('Task berhasil dihapus!');
  }

  Future<void> _updateTask(
    Task updatedTask, {
    required Task previousTask,
  }) async {
    await _repository.updateTask(updatedTask);
    if (!mounted) return;
    final index = _tasks.indexWhere((task) => task.id == previousTask.id);
    if (index == -1) return;
    setState(() {
      _tasks[index] = updatedTask;
      _tasks.sort((first, second) => first.deadline.compareTo(second.deadline));
    });

    if (previousTask.attachmentPath != updatedTask.attachmentPath) {
      try {
        await TaskAttachmentService.deletePhoto(previousTask.attachmentPath);
      } on Exception catch (error) {
        if (mounted) _showMessage('Foto lama tidak dapat dihapus: $error');
      }
    }

    try {
      await _reminderService.syncTaskReminders(updatedTask);
      await _refreshDailyReminders();
    } on Exception catch (error) {
      if (mounted) {
        _showMessage('Tugas tersimpan, tetapi reminder gagal: $error');
      }
    }
  }

  Future<void> _refreshReminders() async {
    try {
      for (final task in _tasks) {
        await _reminderService.syncTaskReminders(task);
      }
      await _refreshDailyReminders();
    } on Exception catch (error) {
      if (mounted) _showMessage('Tugas dimuat, tetapi reminder gagal: $error');
    }
  }

  Future<void> _refreshDailyReminders() async {
    await _reminderService.refreshDailyReminders(_tasks);
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
            _buildFocusContent(),
            CoursesScreen(
              repository: _courseRepository,
              tasks: _tasks,
              onCourseRenamed: _renameCourseOnTasks,
            ),
            GroupScreen(tasks: _tasks),
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
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.deadline.compareTo(b.deadline);
      });

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

        if (_tasks.isNotEmpty) ...[
          SummaryCard(
            pendingCount: pendingCount,
            completedCount: completedCount,
            totalCount: _tasks.length,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _buildDueSummary(),
        const SizedBox(height: AppSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _addTask,
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
        ),

        const SizedBox(height: AppSpacing.xxl),

        if (_isLoading) ...[
          const LoadingView(),
        ] else if (_errorMessage != null) ...[
          ErrorView(message: _errorMessage!, onRetry: _loadTasks),
        ] else if (orderedTasks.isEmpty) ...[
          const EmptyView(message: 'Belum ada task. Tambahkan task pertamamu!'),
        ] else ...[
          _SectionHeading(
            title: 'Closest deadline',
            actionLabel: 'View all',
            onAction: _openAllTasks,
          ),
          const SizedBox(height: AppSpacing.md),

          TaskCard(
            task: orderedTasks.first,
            isFeatured: !orderedTasks.first.isCompleted,
            onChanged: (value) {
              _toggleTask(orderedTasks.first, value);
            },
            onTap: () => _openTaskDetail(orderedTasks.first),
            onEdit: () => _editTask(orderedTasks.first),
            onDelete: () => _deleteTask(orderedTasks.first),
            onScratchpadTap: () => _editScratchpad(orderedTasks.first),
            onScratchpadDelete: () => _deleteScratchpad(orderedTasks.first),
            onFocusTap: () => _startFocus(orderedTasks.first),
          ),

          if (orderedTasks.length > 1) ...[
            const SizedBox(height: AppSpacing.xxl),
            const _SectionHeading(title: 'Upcoming tasks'),
            const SizedBox(height: AppSpacing.md),

            for (var index = 1; index < orderedTasks.length; index++) ...[
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
                onScratchpadTap: () => _editScratchpad(orderedTasks[index]),
                onScratchpadDelete: () =>
                    _deleteScratchpad(orderedTasks[index]),
                onFocusTap: () => _startFocus(orderedTasks[index]),
              ),
              if (index < orderedTasks.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        ],
      ],
    );
  }

  Widget _buildDueSummary() {
    final today = DateTime.now();
    final todayTasks = TaskDateWindows.dueToday(_tasks, now: today);
    final weekTasks = TaskDateWindows.dueThisWeek(_tasks, now: today);
    final laterThisWeek = weekTasks.where(
      (task) =>
          TaskDateWindows.dateOnly(task.deadline) !=
          TaskDateWindows.dateOnly(today),
    );

    Widget section(String title, List<Task> tasks, String emptyMessage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          if (tasks.isEmpty)
            Text(emptyMessage, style: AppTextStyles.caption)
          else
            for (final task in tasks.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '• ${task.title} — ${task.course}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
              ),
          if (tasks.length > 3)
            Text(
              '+ ${tasks.length - 3} tugas lainnya',
              style: AppTextStyles.caption,
            ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section(
            'Hari ini · ${todayTasks.length}',
            todayTasks,
            'Tidak ada tugas aktif hari ini.',
          ),
          const SizedBox(height: AppSpacing.lg),
          section(
            'Minggu ini · ${weekTasks.length}',
            laterThisWeek.toList(),
            weekTasks.isEmpty
                ? 'Tidak ada tugas aktif minggu ini.'
                : 'Tidak ada tugas lain minggu ini.',
          ),
        ],
      ),
    );
  }

  void _renameCourseOnTasks(String oldName, String newName) {
    setState(() {
      for (var index = 0; index < _tasks.length; index++) {
        if (_tasks[index].course == oldName) {
          _tasks[index] = _tasks[index].copyWith(course: newName);
        }
      }
    });
  }

  Widget _buildFocusContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      children: [
        const Text('Focus Timer', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Pilih tugas untuk memulai sesi Pomodoro 25 menit.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_tasks.isEmpty)
          const EmptyView(message: 'Tambahkan tugas sebelum mulai fokus.')
        else
          for (final task in _tasks) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(task.course, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '${_formatFocusDuration(_totalFocusSeconds(task))} '
                          'tercatat',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _startFocus(task),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Mulai'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  int _totalFocusSeconds(Task task) =>
      task.focusLogs.fold<int>(0, (total, log) => total + log.durationSeconds);

  String _formatFocusDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    if (hours > 0) return '$hours jam $minutes menit';
    if (minutes > 0) return '$minutes menit $remainingSeconds detik';
    return '$seconds detik';
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning, Sir', style: AppTextStyles.heading),
              SizedBox(height: AppSpacing.sm),
              Text("Let's get your tasks done.", style: AppTextStyles.body),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _showMessage('Notifications will be connected later.');
          },
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
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
