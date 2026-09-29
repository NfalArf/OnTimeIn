import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/validators.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Task')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('catatan-field'),
                controller: _catatanController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return Validators.requiredField(
                        value,
                        message: 'Catatan wajib diisi',
                      ) ??
                      Validators.minLength(
                        value,
                        min: 5,
                        message: 'Catatan minimal 5 karakter',
                      );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: _saveNote, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
