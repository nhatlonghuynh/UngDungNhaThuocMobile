import 'dart:ui';

extension ColorOpacityExt on Color {
  Color withOpacitySafe(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withValues(alpha: opacity * 255);
  }
}
