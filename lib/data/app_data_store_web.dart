import 'package:web/web.dart' as web;

const _defaultStorageKey = 'ontimein-data-v1';

Future<String?> readStoredData(String? overridePath) async {
  return web.window.localStorage.getItem(overridePath ?? _defaultStorageKey);
}

Future<void> writeStoredData(String data, String? overridePath) async {
  web.window.localStorage.setItem(overridePath ?? _defaultStorageKey, data);
}
