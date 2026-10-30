import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nama_project/services/task_attachment_service_web.dart'
    as web_attachment;

void main() {
  test('web attachment stores and restores image bytes', () async {
    final photo = XFile.fromData(
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
      mimeType: 'image/jpeg',
    );

    final location = await web_attachment.savePhoto(photo);
    final restored = await web_attachment.readPhoto(location);

    expect(location, startsWith('data:image/jpeg;base64,'));
    expect(restored, [0xFF, 0xD8, 0xFF, 0xD9]);
  });

  test('web attachment rejects invalid image locations', () async {
    expect(
      () => web_attachment.readPhoto('blob:invalid'),
      throwsFormatException,
    );
  });
}
