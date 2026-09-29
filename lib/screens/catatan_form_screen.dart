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

  void _simpanCatatan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              TextFormField(
                controller: _catatanController,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Validators.minLength(
                  value,
                  min: 5,
                  requiredMessage: 'Catatan wajib diisi',
                  minMessage: 'Catatan minimal 5 karakter',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _simpanCatatan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
