import 'package:flutter/material.dart';

/// Unified spacing scale — always use these constants, never magic numbers.
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double section = 32.0;
  static const double largeSection = 40.0;
  static const double hero = 48.0;
  static const double massive = 64.0;

  // EdgeInsets Helpers
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXXl = EdgeInsets.all(xxl);

  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  // Vertical SizedBox Helpers
  static const SizedBox hXs = SizedBox(height: xs);
  static const SizedBox hSm = SizedBox(height: sm);
  static const SizedBox hMd = SizedBox(height: md);
  static const SizedBox hLg = SizedBox(height: lg);
  static const SizedBox hXl = SizedBox(height: xl);
  static const SizedBox hXXl = SizedBox(height: xxl);
  static const SizedBox hSection = SizedBox(height: section);
  static const SizedBox hLargeSection = SizedBox(height: largeSection);

  // Horizontal SizedBox Helpers
  static const SizedBox wXs = SizedBox(width: xs);
  static const SizedBox wSm = SizedBox(width: sm);
  static const SizedBox wMd = SizedBox(width: md);
  static const SizedBox wLg = SizedBox(width: lg);
  static const SizedBox wXl = SizedBox(width: xl);
  static const SizedBox wXXl = SizedBox(width: xxl);
}

/// Unified border-radius scale.
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0;

  static BorderRadius circularSm = BorderRadius.circular(sm);
  static BorderRadius circularMd = BorderRadius.circular(md);
  static BorderRadius circularLg = BorderRadius.circular(lg);
  static BorderRadius circularXl = BorderRadius.circular(xl);
  static BorderRadius circularPill = BorderRadius.circular(pill);
}
