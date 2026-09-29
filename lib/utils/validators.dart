abstract final class Validators {
  static String? requiredField(
    String? value, {
    String message = 'Field ini wajib diisi',
  }) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, message: 'Email wajib diisi');
    if (requiredError != null) return requiredError;

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, message: 'Password wajib diisi');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? minLength(String? value, {int min = 5, String? message}) {
    final requiredError = requiredField(value);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < min) return message ?? 'Minimal $min karakter';
    return null;
  }
}
