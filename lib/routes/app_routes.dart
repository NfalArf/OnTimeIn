import 'package:flutter/material.dart';

import '../models/task.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => HomeScreen(
            simulateError: const bool.fromEnvironment('SIMULATE_TASK_ERROR'),
          ),
        );
      case detail:
        final args = settings.arguments;
        if (args is Task) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => DetailScreen(task: args),
          );
        }
        return _notFound('Argumen task tidak valid.');
      case catatanForm:
        return MaterialPageRoute<String>(
          settings: settings,
          builder: (_) => const CatatanFormScreen(),
        );
      default:
        return _notFound('Halaman tidak ditemukan: ${settings.name ?? ''}');
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _notFound('Halaman tidak ditemukan: ${settings.name ?? ''}');
  }

  static Route<void> _notFound(String message) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(message: message),
    );
  }
}
