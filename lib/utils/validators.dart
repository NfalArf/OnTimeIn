class Validators {
  // Validasi field wajib diisi.
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    return null;
  }

  // Validasi format email.
  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Validasi password minimal 8 karakter.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    return null;
  }

  // Validator umum untuk panjang minimal.
  static String? minLength(
    String? value,
    int minimum, {
    String fieldName = 'Field',
  }) {
    final requiredError = required(value, fieldName: fieldName);
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < minimum) {
      return '$fieldName minimal $minimum karakter';
    }

    return null;
  }

  static String? optionalUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.host.contains(' ') ||
        (uri.host != 'localhost' && !uri.host.contains('.'))) {
      return 'Masukkan URL valid (contoh: https://contoh.com).';
    }

    return null;
  }
}
