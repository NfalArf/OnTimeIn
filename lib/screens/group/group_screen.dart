
import 'package:flutter/material.dart';

import '../../models/group_session.dart';
import '../../models/task.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({
    super.key,
    required this.tasks,
  });

  final List<Task> tasks;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final List<GroupSession> _sessions = [];
  int _nextId = 1;

  Future<void> _addSession() async {
    if (widget.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan tugas terlebih dahulu.'),
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    Task selectedTask = widget.tasks.first;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<GroupSession>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Sesi Kumpul'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama sesi',
                        hintText: 'Contoh: Diskusi tugas kelompok',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Task>(
                      initialValue: selectedTask,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tugas terkait',
                      ),
                      items: widget.tasks.map((task) {
                        return DropdownMenuItem<Task>(
                          value: task,
                          child: Text(
                            task.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (task) {
                        if (task != null) {
                          setDialogState(() {
                            selectedTask = task;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        '${selectedDate.day}/'
                        '${selectedDate.month}/'
                        '${selectedDate.year}',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (time != null) {
                          setDialogState(() {
                            selectedTime = time;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(selectedTime.format(context)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi atau media',
                        hintText: 'Contoh: Perpustakaan / Google Meet',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Agenda sesi',
                        hintText: 'Apa yang akan dibahas?',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final location = locationController.text.trim();

                    if (title.isEmpty || location.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nama sesi dan lokasi wajib diisi.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      GroupSession(
                        id: _nextId,
                        title: title,
                        taskId: selectedTask.id,
                        taskTitle: selectedTask.title,
                        date: DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                        ),
                        startHour: selectedTime.hour,
                        startMinute: selectedTime.minute,
                        location: location,
                        description:
                            descriptionController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    //titleController.dispose();
    //locationController.dispose();
    //descriptionController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      _sessions.add(result);
      _nextId++;
      _sessions.sort((a, b) {
        final aDate = DateTime(
          a.date.year,
          a.date.month,
          a.date.day,
          a.startHour,
          a.startMinute,
        );
        final bDate = DateTime(
          b.date.year,
          b.date.month,
          b.date.day,
          b.startHour,
          b.startMinute,
        );
        return aDate.compareTo(bDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Sessions'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSession,
        icon: const Icon(Icons.add),
        label: const Text('Buat Sesi'),
      ),
      body: _sessions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_outlined, size: 56),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada sesi kumpul',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Buat sesi untuk mulai merencanakan '
                      'diskusi tugas kelompok.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.groups_outlined),
                    ),
                    title: Text(session.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tugas: ${session.taskTitle}'),
                          Text(
                            'Tanggal: ${session.date.day}/'
                            '${session.date.month}/'
                            '${session.date.year}',
                          ),
                          Text('Waktu: ${session.formattedTime}'),
                          Text('Lokasi: ${session.location}'),
                          if (session.description.isNotEmpty)
                            Text('Agenda: ${session.description}'),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
