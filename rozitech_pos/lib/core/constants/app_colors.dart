import 'package:flutter/material.dart';

/// Kasir Kita brand color palette (by Kang Digital).
/// Built on Material 3 color system with custom brand identity.
class AppColors {
  AppColors._();

  // ─── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8);  // Indigo-400
  static const Color primaryDark = Color(0xFF3730A3);   // Indigo-800

  static const Color secondary = Color(0xFF06B6D4);     // Cyan-500
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color secondaryDark = Color(0xFF0E7490);

  static const Color accent = Color(0xFFF59E0B);        // Amber-500
  static const Color accentLight = Color(0xFFFCD34D);
  static const Color accentDark = Color(0xFFB45309);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // Emerald-500
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E3A8A);

  // ─── Light Theme Neutrals ─────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // ─── Dark Theme Neutrals ──────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1E2638);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // ─── Dashboard Card Gradients ─────────────────────────────────────────────
  static const List<Color> salesGradient = [Color(0xFF4F46E5), Color(0xFF7C3AED)];
  static const List<Color> revenueGradient = [Color(0xFF059669), Color(0xFF0284C7)];
  static const List<Color> ordersGradient = [Color(0xFFF59E0B), Color(0xFFEF4444)];
  static const List<Color> productsGradient = [Color(0xFF06B6D4), Color(0xFF3B82F6)];
}
