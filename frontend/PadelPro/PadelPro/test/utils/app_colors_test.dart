import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padelpro/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primary es Colors.blue', () {
      expect(AppColors.primary, Colors.blue);
    });

    test('primary no es null', () {
      expect(AppColors.primary, isNotNull);
    });

    test('primary es de tipo Color', () {
      expect(AppColors.primary, isA<Color>());
    });
  });
}
