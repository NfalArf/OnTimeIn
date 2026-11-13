import 'app_data_store_io.dart'
    if (dart.library.js_interop) 'app_data_store_web.dart' as platform;

Future<String?> readStoredData(String? overridePath) =>
    platform.readStoredData(overridePath);

Future<void> writeStoredData(String data, String? overridePath) =>
    platform.writeStoredData(data, overridePath);
