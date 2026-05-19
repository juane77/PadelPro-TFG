import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mq;

  static void init(BuildContext context) {
    _mq = MediaQuery.of(context);
  }

  static double get width => _mq.size.width;
  static double get height => _mq.size.height;

  static bool get isMobile => width < 600;
  static bool get isTablet => width >= 600 && width < 1024;
  static bool get isDesktop => width >= 1024;

  static double w(double percent) => width * percent / 100;

  static double h(double percent) => height * percent / 100;

  static double font(double base) {
    if (isDesktop) return (base * 1.1).clamp(base, base * 1.3);
    if (isTablet) return (base * 1.05).clamp(base, base * 1.2);
    return base;
  }

  static double imageSize(double base) {
    if (isDesktop) return base * 1.2;
    if (isTablet) return base * 1.1;
    return base;
  }

  static double padding(double base) {
    if (isDesktop) return base * 1.3;
    if (isTablet) return base * 1.15;
    return base;
  }

  static double get maxContentWidth {
    if (isDesktop) return 520;
    if (isTablet) return 600;
    return double.infinity;
  }
}
