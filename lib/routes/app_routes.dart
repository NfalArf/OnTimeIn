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
          builder: (_) => const HomeScreen(),
        );
      case detail:
        final args = settings.arguments;
        if (args is Task) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => DetailScreen(task: args),
          );
        }
        return _notFoundRoute(settings, 'Data task tidak valid.');
      case catatanForm:
        return MaterialPageRoute<String>(
          settings: settings,
          builder: (_) => const CatatanFormScreen(),
        );
      default:
        return onUnknownRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _notFoundRoute(
      settings,
      'Halaman tidak ditemukan: ${settings.name}',
    );
  }

  static Route<void> _notFoundRoute(RouteSettings settings, String message) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => NotFoundScreen(message: message),
    );
  }
}
