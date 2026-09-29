abstract final class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value);
    if (requiredError != null) return 'Email wajib diisi';

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value);
    if (requiredError != null) return 'Password wajib diisi';
    return minLength(value, min: 8, minMessage: 'Password minimal 8 karakter');
  }

  static String? minLength(
    String? value, {
    int min = 5,
    String? requiredMessage,
    String? minMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage ?? 'Field wajib diisi';
    }
    if (value.trim().length < min) {
      return minMessage ?? 'Minimal $min karakter';
    }
    return null;
  }
}
