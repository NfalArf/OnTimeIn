import 'package:image_picker/image_picker.dart';

import 'task_attachment_service_io.dart'
    if (dart.library.js_interop) 'task_attachment_service_web.dart' as platform;

class TaskAttachmentService {
  TaskAttachmentService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> capturePhoto() {
    return _picker.pickImage(source: ImageSource.camera);
  }

  static Future<String> savePhoto(XFile photo) => platform.savePhoto(photo);

  static Future<List<int>> readPhoto(String location) =>
      platform.readPhoto(location);

  static Future<void> deletePhoto(String? location) =>
      platform.deletePhoto(location);
}
