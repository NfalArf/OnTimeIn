import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

void main() {
  runApp(const OnTimeInApp());
}

class OnTimeInApp extends StatelessWidget {
  const OnTimeInApp({super.key});

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
      home: const HomeScreen(),
    );
  }
}
