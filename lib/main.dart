import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'data/app_data_repository.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(const OnTimeInApp());
}

class OnTimeInApp extends StatelessWidget {
  const OnTimeInApp({super.key, this.dataRepository, this.reminderService});

  final AppDataRepository? dataRepository;
  final TaskReminderService? reminderService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnTimeIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: const TextTheme(
          bodyMedium: AppTextStyles.body,
          titleMedium: AppTextStyles.title,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        final app = child ?? const SizedBox.shrink();
        if (!kIsWeb) return app;

        return ColoredBox(
          color: AppColors.canvas,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: app,
            ),
          ),
        );
      },

      // [DIUBAH LANGKAH 6]
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings,
        dataRepository: dataRepository,
        reminderService: reminderService,
      ),
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
