import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  static const titleBig = TextStyle(
    fontSize: 34,
    height: 1.05,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
  );

  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
  );

  static TextStyle get subtitle =>
      TextStyle(fontSize: 12, color: AppColors.textOnDark.withOpacity(0.70));

  static TextStyle get labelMuted =>
      TextStyle(fontSize: 12, color: AppColors.textOnDark.withOpacity(0.60));

  static const button = TextStyle(fontWeight: FontWeight.w700);
}
