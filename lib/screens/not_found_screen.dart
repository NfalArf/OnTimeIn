import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.message = 'Halaman tidak ditemukan.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                ),
                child: const Text('Ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
