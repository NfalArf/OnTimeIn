import 'package:flutter/material.dart';

import '../models/task.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  // [TAMBAHAN LANGKAH 7]
  static const String detail = '/detail';
  // [TAMBAHAN LANGKAH 8]
  static const String catatanForm = '/catatan-form';

  // [TAMBAHAN LANGKAH 6]
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      // [TAMBAHAN LANGKAH 7]
      case detail:
        final args = settings.arguments;
        if (args is Task) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(task: args),
            settings: settings,
          );
        }
        return null;
      // [TAMBAHAN LANGKAH 8]
      case catatanForm:
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  // [TAMBAHAN LANGKAH 6]
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
