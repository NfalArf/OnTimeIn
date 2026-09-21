import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const heading = TextStyle(
    color: AppColors.ink,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static const title = TextStyle(
    color: AppColors.ink,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    color: AppColors.ink,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );
  static const caption = TextStyle(
    color: AppColors.mutedInk,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const overline = TextStyle(
    color: AppColors.mutedInk,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
  );
}
