import 'package:flutter/widgets.dart';

/// Corner radius tokens from ref/extracted/.../vibrant_velocity/DESIGN.md
/// Shape language is "Hyper-Rounded" — see DESIGN.md > Shapes.
class AppRadius {
  AppRadius._();

  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(xl);
  static BorderRadius get input => BorderRadius.circular(lg);
  static BorderRadius get pill => BorderRadius.circular(full);
}
