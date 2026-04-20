import 'package:flutter/material.dart';

class AppSnackbar {

  static void exito(BuildContext context, String mensaje) {
    _mostrar(context, mensaje, const Color(0xFF2E7D32), Icons.check_circle_outline);
  }

  static void error(BuildContext context, String mensaje) {
    _mostrar(context, mensaje, const Color(0xFFC62828), Icons.error_outline);
  }

  static void aviso(BuildContext context, String mensaje) {
    _mostrar(context, mensaje, const Color(0xFFE65100), Icons.warning_amber_outlined);
  }

  static void _mostrar(BuildContext context, String mensaje, Color color, IconData icono) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icono, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins",
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}