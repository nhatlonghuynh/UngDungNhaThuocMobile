import 'package:flutter/material.dart';

class AppColors {
  // --- Brand Colors ---
  static const Color primary = Color(0xFF00BFA5); // Teal Accent 700 - Medical/Clean
  static const Color primaryLight = Color(0xFF5DF2D6); // Lighter teal
  static const Color primaryDark = Color(0xFF008E76); // Darker teal
  static const Color secondary = Color(0xFFFF6D00); // Deep Orange A700 - Action/Attention
  static const Color secondaryLight = Color(0xFFFF9E40); // Lighter orange
  static const Color accent = Color(0xFF00E5CC); // Bright teal accent

  // --- Backgrounds ---
  static const Color background = Color(0xFFF5F7FA); // Light Blue Grey - Soft background
  static const Color surface = Color(0xFFFFFFFF); // White - Cards/Sheets
  static const Color surfaceLight = Color(0xFFFAFBFC); // Very light grey

  // --- Text ---
  static const Color textPrimary = Color(0xFF263238); // Blue Grey 900 - High contrast text
  static const Color textSecondary = Color(0xFF78909C); // Blue Grey 400 - Subtitles/Hints
  static const Color textInverse = Color(0xFFFFFFFF); // White text on colored bg
  static const Color textDisabled = Color(0xFFB0BEC5); // Grey 300

  // --- Status ---
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336); // Red
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color info = Color(0xFF2196F3); // Blue

  // --- Order Status Colors ---
  static const Color statusPending = Color(0xFFFFA726); // Orange
  static const Color statusProcessing = Color(0xFF42A5F5); // Blue
  static const Color statusShipped = Color(0xFF7E57C2); // Purple
  static const Color statusDelivered = Color(0xFF66BB6A); // Green
  static const Color statusCancelled = Color(0xFFEF5350); // Red

  // --- Neutrals ---
  static const Color border = Color(0xFFE0E0E0); // Grey 300 - Dividers
  static const Color borderLight = Color(0xFFF0F0F0); // Lighter border
  static const Color neutralBeige = Color(0xFFF5F5DC); // Beige
  static const Color shadow = Color(0x1A000000); // Black with low opacity
  static const Color shadowLight = Color(0x0D000000); // Lighter shadow

  // --- Badge & Tag Colors ---
  static const Color badgePromo = Color(0xFFFF1744); // Red for promotions
  static const Color badgeNew = Color(0xFF00E676); // Green for new items
  static const Color badgeHot = Color(0xFFFF6D00); // Orange for hot items
  static const Color badgeOutOfStock = Color(0xFF9E9E9E); // Grey for out of stock

  // --- Rating ---
  static const Color starYellow = Color(0xFFFFC107); // Amber for stars
  static const Color starGrey = Color(0xFFE0E0E0); // Grey for empty stars

  // --- Gradients (as list for LinearGradient) ---
  static const List<Color> gradientPrimary = [
    Color(0xFF00BFA5),
    Color(0xFF00E5CC),
  ];
  
  static const List<Color> gradientSecondary = [
    Color(0xFFFF6D00),
    Color(0xFFFF9E40),
  ];

  static const List<Color> gradientBackground = [
    Color(0xFFF5F7FA),
    Color(0xFFFFFFFF),
  ];

  // --- Helper: Create gradient ---
  static LinearGradient primaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: gradientPrimary,
      begin: begin,
      end: end,
    );
  }

  static LinearGradient secondaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: gradientSecondary,
      begin: begin,
      end: end,
    );
  }
}
