import 'dart:async';

import 'package:flutter/material.dart';

import '../models/focus_log.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key, required this.task});

  final Task task;

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const _focusDuration = Duration(minutes: 25);
  static const _breakDuration = Duration(minutes: 5);

  late Duration _remaining = _focusDuration;
  late List<FocusLog> _focusLogs = List.of(widget.task.focusLogs);
  Timer? _timer;
  bool _isFocusPeriod = true;
  bool _isRunning = false;
  int _elapsedFocusSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_isFocusPeriod) _elapsedFocusSeconds++;

        if (_remaining == Duration.zero) {
          if (_isFocusPeriod) {
            _recordFocusLog(_elapsedFocusSeconds);
            _elapsedFocusSeconds = 0;
            _isFocusPeriod = false;
            _remaining = _breakDuration;
          } else {
            _isFocusPeriod = true;
            _remaining = _focusDuration;
          }
        }
      });
    });
  }

  void _recordFocusLog(int durationSeconds) {
    if (durationSeconds <= 0) return;
    _focusLogs = [
      ..._focusLogs,
      FocusLog(durationSeconds: durationSeconds, date: DateTime.now()),
    ];
  }

  Task _updatedTask() {
    final logs = List<FocusLog>.of(_focusLogs);
    if (_isFocusPeriod && _elapsedFocusSeconds > 0) {
      logs.add(
        FocusLog(durationSeconds: _elapsedFocusSeconds, date: DateTime.now()),
      );
    }
    return widget.task.copyWith(focusLogs: logs);
  }

  void _close() {
    _timer?.cancel();
    Navigator.pop(context, _updatedTask());
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalFocusSeconds = _focusLogs.fold<int>(
      0,
      (sum, log) => sum + log.durationSeconds,
    );

    return PopScope<Task>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Focus Timer'),
          leading: IconButton(
            onPressed: _close,
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(widget.task.title, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.task.course, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Icon(
                    _isFocusPeriod
                        ? Icons.center_focus_strong_rounded
                        : Icons.coffee_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _isFocusPeriod ? 'Waktu fokus' : 'Waktu istirahat',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatDuration(_remaining),
                    style: AppTextStyles.heading.copyWith(fontSize: 56),
                    semanticsLabel:
                        '${_remaining.inMinutes} menit ${_remaining.inSeconds % 60} detik',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isFocusPeriod
                        ? 'Satu sesi fokus berlangsung 25 menit.'
                        : 'Istirahat sejenak selama 5 menit.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(_isRunning ? 'Jeda' : 'Mulai fokus'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: _close,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Selesaikan dan simpan waktu'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Tercatat ${_formatDuration(Duration(seconds: totalFocusSeconds))}'
                      ' dalam ${_focusLogs.length} sesi fokus.',
                      style: AppTextStyles.body,
                    ),
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
