import 'package:flutter/material.dart';
import '../service/app_settings.dart';
import '../utils/app_snackbar.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {

  final settings = AppSettings();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Ajustes",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.all(w * 0.05),
        children: [

          const SizedBox(height: 8),

          _seccionTitulo("Texto"),

          const SizedBox(height: 10),

          _ajusteCard(
            icono: Icons.text_fields_rounded,
            titulo: "Tamaño de texto",
            subtitulo: "Actual: ${settings.tamanoTextoLabel}",
            trailing: null,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  _tamanoChip("Pequeño", 0.85),
                  const SizedBox(width: 8),
                  _tamanoChip("Normal", 1.0),
                  const SizedBox(width: 8),
                  _tamanoChip("Grande", 1.15),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // SECCIÓN NOTIFICACIONES
          _seccionTitulo("Notificaciones"),

          const SizedBox(height: 10),

          _ajusteCard(
            icono: Icons.notifications_rounded,
            titulo: "Notificaciones push",
            subtitulo: settings.notificaciones
                ? "Activadas"
                : "Desactivadas",
            trailing: Switch(
              value: settings.notificaciones,
              activeColor: const Color(0xFF1F5DA0),
              onChanged: (valor) async {
                await settings.setNotificaciones(valor);
                setState(() {});
                AppSnackbar.exito(
                  context,
                  valor ? "Notificaciones activadas" : "Notificaciones desactivadas",
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // SECCIÓN SOBRE LA APP
          _seccionTitulo("Sobre la app"),

          const SizedBox(height: 10),

          _ajusteCard(
            icono: Icons.info_outline_rounded,
            titulo: "Versión",
            subtitulo: "PadelPro v1.0.0",
            trailing: const SizedBox(),
          ),

          const SizedBox(height: 12),

          _ajusteCard(
            icono: Icons.school_rounded,
            titulo: "Proyecto TFG",
            subtitulo: "Desarrollo de Aplicaciones Multiplataforma",
            trailing: const SizedBox(),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1F5DA0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Color(0xFF1F5DA0),
          ),
        ),
      ],
    );
  }

  Widget _ajusteCard({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Widget? trailing,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F5DA0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: const Color(0xFF1F5DA0), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _tamanoChip(String label, double valor) {
    final seleccionado = settings.tamanoTexto == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await settings.setTamanoTexto(valor);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: seleccionado
                ? const Color(0xFF1F5DA0)
                : const Color(0xFF1F5DA0).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? const Color(0xFF1F5DA0)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: seleccionado ? Colors.white : const Color(0xFF1F5DA0),
                fontFamily: "Poppins",
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}