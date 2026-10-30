import 'dart:convert';

import 'package:image_picker/image_picker.dart';

Future<String> savePhoto(XFile photo) async {
  final bytes = await photo.readAsBytes();
  final mimeType = photo.mimeType ?? 'image/jpeg';
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

Future<List<int>> readPhoto(String location) async {
  final separator = location.indexOf(',');
  if (!location.startsWith('data:image/') || separator < 0) {
    throw const FormatException('Format foto lampiran web tidak valid.');
  }
  return base64Decode(location.substring(separator + 1));
}

Future<void> deletePhoto(String? location) async {}
