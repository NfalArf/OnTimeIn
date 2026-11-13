import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> readStoredData(String? overridePath) async {
  final file = await _storageFile(overridePath);
  if (!await file.exists()) return null;
  return file.readAsString();
}

Future<void> writeStoredData(String data, String? overridePath) async {
  final file = await _storageFile(overridePath);
  await file.parent.create(recursive: true);
  final temporaryFile = File('${file.path}.tmp');
  await temporaryFile.writeAsString(data, flush: true);
  await temporaryFile.rename(file.path);
}

Future<File> _storageFile(String? overridePath) async {
  if (overridePath != null) return File(overridePath);
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}${Platform.pathSeparator}ontimein-data.json');
}
