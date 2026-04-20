import 'package:flutter/material.dart';

class Responsive {
  static late double _width;
  static late double _height;

  static void init(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
  }

  // Porcentaje del ancho de pantalla
  static double w(double percent) => _width * percent / 100;

  // Porcentaje del alto de pantalla
  static double h(double percent) => _height * percent / 100;

  // Escala de fuente según ancho (base: 390px = iPhone 14)
  static double font(double size) => size * (_width / 390).clamp(0.85, 1.2);

  // Escala de espaciado
  static double sp(double size) => size * (_width / 390).clamp(0.85, 1.15);

  // Pantalla pequeña (< 360px, ej: Galaxy A series)
  static bool get isSmall => _width < 360;

  // Pantalla grande (> 420px, ej: iPhone Plus, Galaxy Ultra)
  static bool get isLarge => _width > 420;
}