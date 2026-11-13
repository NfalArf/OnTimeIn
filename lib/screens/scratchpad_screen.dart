import 'package:flutter/material.dart';

import '../models/scratchpad.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/scratchpad_sketch.dart';

class ScratchpadScreen extends StatefulWidget {
  const ScratchpadScreen({
    super.key,
    required this.initialScratchpad,
    required this.taskTitle,
  });

  final Scratchpad? initialScratchpad;
  final String taskTitle;

  @override
  State<ScratchpadScreen> createState() => _ScratchpadScreenState();
}

class _ScratchpadScreenState extends State<ScratchpadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ideaController = TextEditingController();
  final _referenceController = TextEditingController();
  final _referenceUrlController = TextEditingController();
  final _canvasKey = GlobalKey();
  late List<List<Offset>> _strokes;
  int? _activePointer;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    final scratchpad = widget.initialScratchpad;
    _ideaController.text = scratchpad?.idea ?? '';
    _referenceController.text = scratchpad?.reference ?? '';
    _referenceUrlController.text = scratchpad?.referenceUrl ?? '';
    _strokes =
        scratchpad?.strokes.map((stroke) => List<Offset>.of(stroke)).toList() ??
        [];
  }

  @override
  void dispose() {
    _ideaController.dispose();
    _referenceController.dispose();
    _referenceUrlController.dispose();
    super.dispose();
  }

  Offset? _normalizedPosition(Offset localPosition) {
    final renderObject = _canvasKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;

    final size = renderObject.size;
    if (size.isEmpty) return null;

    return Offset(
      (localPosition.dx / size.width).clamp(0.0, 1.0),
      (localPosition.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _startStroke(PointerDownEvent event) {
    final point = _normalizedPosition(event.localPosition);
    if (point == null) return;
    _activePointer = event.pointer;
    setState(() {
      _isDrawing = true;
      _strokes = [
        ..._strokes,
        [point],
      ];
    });
  }

  void _updateStroke(PointerMoveEvent event) {
    if (event.pointer != _activePointer || _strokes.isEmpty) return;
    final point = _normalizedPosition(event.localPosition);
    if (point == null) return;

    setState(() {
      _strokes = [
        ..._strokes.take(_strokes.length - 1),
        [..._strokes.last, point],
      ];
    });
  }

  void _endStroke(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    setState(() => _isDrawing = false);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(
      context,
      ScratchpadEditResult.saved(
        Scratchpad(
          idea: _ideaController.text.trim(),
          reference: _referenceController.text.trim(),
          referenceUrl: _referenceUrlController.text.trim(),
          strokes: _strokes,
        ),
      ),
    );
  }

  Future<void> _deleteScratchpad() async {
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
    Navigator.pop(context, const ScratchpadEditResult.deleted());
  }

  void _clearSketch() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes = []);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Sketsa berhasil dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Scratchpad')),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: _isDrawing ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(widget.taskTitle, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _ideaController,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ide awal',
                hintText: 'Catat ide atau poin penting tugas...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _referenceController,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Teks referensi',
                hintText: 'Tambahkan kutipan atau catatan referensi...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _referenceUrlController,
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'Tautan referensi',
                hintText: 'https://contoh.com',
                prefixIcon: Icon(Icons.link_rounded),
                helperText:
                    'Gunakan tautan lengkap yang diawali http:// atau https://',
                border: OutlineInputBorder(),
              ),
              validator: Validators.optionalUrl,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text('Sketsa bebas', style: AppTextStyles.title),
                ),
                TextButton.icon(
                  onPressed: _strokes.isEmpty ? null : _clearSketch,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Listener(
              key: const ValueKey('scratchpad-canvas'),
              behavior: HitTestBehavior.opaque,
              onPointerDown: _startStroke,
              onPointerMove: _updateStroke,
              onPointerUp: _endStroke,
              onPointerCancel: _endStroke,
              child: SizedBox(
                key: _canvasKey,
                height: 240,
                width: double.infinity,
                child: ScratchpadSketch(
                  strokes: _strokes,
                  width: double.infinity,
                  height: 240,
                  showHint: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan Scratchpad'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            if (widget.initialScratchpad?.hasContent == true) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _deleteScratchpad,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus Scratchpad'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coral,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
