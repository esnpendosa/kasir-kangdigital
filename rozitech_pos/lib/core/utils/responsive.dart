import 'package:flutter/material.dart';

/// Screen layout breakpoints and helpers for responsive UI.
class ScreenLayout {
  ScreenLayout._();

  static const double _phoneBreakpoint = 600;
  static const double _tabletBreakpoint = 900;

  /// Returns true if width < 600dp (phone).
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _phoneBreakpoint;

  /// Returns true if width is 600–900dp (tablet).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= _phoneBreakpoint && width < _tabletBreakpoint;
  }

  /// Returns true if width >= 900dp (desktop / large tablet).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletBreakpoint;

  /// Returns one of three values depending on screen size.
  static T adaptive<T>(
    BuildContext context, {
    required T phone,
    required T tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet;
    if (isTablet(context)) return tablet;
    return phone;
  }

  /// Returns the number of grid columns for a list/product screen.
  static int gridColumns(BuildContext context) =>
      adaptive(context, phone: 1, tablet: 2, desktop: 3);

  /// Returns horizontal padding appropriate for screen size.
  static double horizontalPadding(BuildContext context) =>
      adaptive(context, phone: 16.0, tablet: 24.0, desktop: 32.0);
}
