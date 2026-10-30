import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/task_attachment_service.dart';

class TaskAttachmentImage extends StatelessWidget {
  const TaskAttachmentImage({
    super.key,
    this.location,
    this.photo,
    required this.height,
    required this.fit,
    this.width,
    this.errorBuilder,
  }) : assert(location != null || photo != null);

  final String? location;
  final XFile? photo;
  final double height;
  final double? width;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: photo != null
          ? photo!.readAsBytes()
          : TaskAttachmentService.readPhoto(location!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace,
              ) ??
              const Text('Foto lampiran tidak dapat dibuka.');
        }
        if (!snapshot.hasData) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return Image.memory(
          Uint8List.fromList(snapshot.data!),
          height: height,
          width: width,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
}
