import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> savePhoto(XFile photo) async {
  final directory = await getApplicationSupportDirectory();
  final extension = photo.path.contains('.')
      ? photo.path.substring(photo.path.lastIndexOf('.'))
      : '.jpg';
  final destination = File(
    '${directory.path}${Platform.pathSeparator}'
    'task-photo-${DateTime.now().microsecondsSinceEpoch}$extension',
  );
  await File(photo.path).copy(destination.path);
  return destination.path;
}

Future<List<int>> readPhoto(String location) => File(location).readAsBytes();

Future<void> deletePhoto(String? location) async {
  if (location == null || location.isEmpty) return;
  final file = File(location);
  if (await file.exists()) await file.delete();
}
