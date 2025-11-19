import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  /*
    ============================================================
      MATERIAL YOU TYPOGRAPHY — ANDROID MODERN STYLE
    ============================================================
    - Display → sangat besar (rare dipakai)
    - Headline → judul besar
    - Title → sub-judul
    - Body → teks utama
    - Label → teks kecil
  */

  //---------------------------------------------------------------------------
  // =============== LIGHT THEME =============================================
  //---------------------------------------------------------------------------

  static const TextStyle lightDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundLight,
  );

  static const TextStyle lightHeadline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundLight,
  );

  static const TextStyle lightTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundLight,
  );

  static const TextStyle lightBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackgroundLight,
  );

  static const TextStyle lightBodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundLight,
  );

  static const TextStyle lightLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackgroundLight,
  );

  static const TextStyle lightLabelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackgroundLight,
  );

  //---------------------------------------------------------------------------
  // =============== DARK THEME ==============================================
  //---------------------------------------------------------------------------

  static const TextStyle darkDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundDark,
  );

  static const TextStyle darkHeadline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundDark,
  );

  static const TextStyle darkTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundDark,
  );

  static const TextStyle darkBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackgroundDark,
  );

  static const TextStyle darkBodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundDark,
  );

  static const TextStyle darkLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackgroundDark,
  );

  static const TextStyle darkLabelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackgroundDark,
  );

  //---------------------------------------------------------------------------
  // =============== PRIMARY COLORED TEXT (Both Themes) ======================
  //---------------------------------------------------------------------------

  static const TextStyle primaryText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle primaryLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  //---------------------------------------------------------------------------
  // =============== STATUS TEXT (success/error/info) ========================
  //---------------------------------------------------------------------------

  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  static const TextStyle dangerText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.expense,
  );

  static const TextStyle infoText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.info,
  );
}
