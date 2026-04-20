import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {

  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  // VALORES POR DEFECTO
  bool _modoOscuro = false;
  bool _notificaciones = true;
  double _tamanoTexto = 1.0; // 0.85 = pequeño, 1.0 = normal, 1.15 = grande

  bool get modoOscuro => _modoOscuro;
  bool get notificaciones => _notificaciones;
  double get tamanoTexto => _tamanoTexto;

  // CARGAR desde shared_preferences al arrancar
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _modoOscuro = prefs.getBool('modo_oscuro') ?? false;
    _notificaciones = prefs.getBool('notificaciones') ?? true;
    _tamanoTexto = prefs.getDouble('tamano_texto') ?? 1.0;
    notifyListeners();
  }

  // MODO OSCURO
  Future<void> setModoOscuro(bool valor) async {
    _modoOscuro = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modo_oscuro', valor);
    notifyListeners();
  }

  // NOTIFICACIONES
  Future<void> setNotificaciones(bool valor) async {
    _notificaciones = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificaciones', valor);
    notifyListeners();
  }

  // TAMAÑO TEXTO
  Future<void> setTamanoTexto(double valor) async {
    _tamanoTexto = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tamano_texto', valor);
    notifyListeners();
  }

  String get tamanoTextoLabel {
    if (_tamanoTexto <= 0.85) return "Pequeño";
    if (_tamanoTexto >= 1.15) return "Grande";
    return "Normal";
  }
}