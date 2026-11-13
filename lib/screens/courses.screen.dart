
import 'package:flutter/material.dart';

import '../data/course_repository.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';


class CoursesScreen extends StatefulWidget {
  const CoursesScreen({
    super.key,
    required this.repository,
  });

  final CourseRepository repository;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  
  

Future<void> _showAddCourseForm() async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  int selectedSemester = 1;

  final newCourse = await showDialog<Course>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tambah Mata Kuliah'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Mata Kuliah',
                        hintText: 'Contoh: Basis Data',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama mata kuliah wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(8, (index) {
                        final semester = index + 1;

                        return DropdownMenuItem<int>(
                          value: semester,
                          child: Text('Semester $semester'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedSemester = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
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
                  if (!formKey.currentState!.validate()) return;

                  final course = Course(
                    id: DateTime.now()
                        .microsecondsSinceEpoch
                        .toString(),
                    name: nameController.text.trim(),
                    semester: selectedSemester,
                  );

                  Navigator.pop(dialogContext, course);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );


  if (!mounted || newCourse == null) return;

  setState(() {
    widget.repository.addCourse(newCourse);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Mata kuliah berhasil ditambahkan!'),
    ),
  );
}


Future<void> _showEditCourseForm(Course course) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: course.name);
  int selectedSemester = course.semester;

  final updatedCourse = await showDialog<Course>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Mata Kuliah'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Mata Kuliah',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama mata kuliah wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(8, (index) {
                        final semester = index + 1;
                        return DropdownMenuItem<int>(
                          value: semester,
                          child: Text('Semester $semester'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedSemester = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  Navigator.pop(
                    dialogContext,
                    course.copyWith(
                      name: nameController.text.trim(),
                      semester: selectedSemester,
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

  if (!mounted || updatedCourse == null) return;

  setState(() {
    widget.repository.updateCourse(updatedCourse);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Mata kuliah berhasil diperbarui!'),
    ),
  );
}

Future<void> _deleteCourse(Course course) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hapus Mata Kuliah?'),
      content: Text(
        'Mata kuliah "${course.name}" akan dihapus.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (!mounted || confirmed != true) return;

  setState(() {
    widget.repository.deleteCourse(course.id);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Mata kuliah berhasil dihapus!'),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    final courses = widget.repository.getCourses();


    final Map<int, List<Course>> groupedCourses = {};

    for (final course in courses) {
      groupedCourses.putIfAbsent(course.semester, () => []);
      groupedCourses[course.semester]!.add(course);
    }

    final semesters = groupedCourses.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      
appBar: AppBar(
  title: const Text('Mata Kuliah'),
  backgroundColor: AppColors.canvas,
  actions: [
    IconButton(
      onPressed: _showAddCourseForm,
      icon: const Icon(Icons.add_rounded),
      tooltip: 'Tambah Mata Kuliah',
    ),
  ],
),

      body: courses.isEmpty
          ? const Center(
              child: Text('Belum ada mata kuliah.'),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Text(
                  'Daftar Mata Kuliah',
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${courses.length} mata kuliah terdaftar',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xl),

                for (final semester in semesters) ...[
                  Text(
                    'Semester $semester',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  
for (final course in groupedCourses[semester]!) ...[
  _CourseCard(
    course: course,
    onEdit: () => _showEditCourseForm(course),
    onDelete: () => _deleteCourse(course),
  ),
  const SizedBox(height: AppSpacing.md),
],


                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
    );
  }
}


class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(
                AppSpacing.smallRadius,
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              course.name,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          
PopupMenuButton<String>(
  tooltip: 'Aksi mata kuliah',
  onSelected: (value) {
    if (value == 'edit') {
      onEdit();
    } else if (value == 'delete') {
      onDelete();
    }
  },
  itemBuilder: (context) => const [
    PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit_outlined),
          SizedBox(width: 8),
          Text('Edit'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_outline, color: Colors.red),
          SizedBox(width: 8),
          Text('Hapus'),
        ],
      ),
    ),
  ],
  child: Icon(
    Icons.more_vert,
    color: AppColors.ink.withValues(alpha: 0.6),
  ),
),
        ],
      ),
    );
  }
}
