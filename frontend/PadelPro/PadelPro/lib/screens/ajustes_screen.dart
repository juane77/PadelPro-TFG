import 'package:flutter/material.dart';
import '../service/app_settings.dart';
import '../utils/responsive.dart';
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
    Responsive.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Ajustes",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: Responsive.font(20),
          ),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(20)),
        children: [

          SizedBox(height: Responsive.h(1.2)),

          _seccionTitulo("Texto"),

          SizedBox(height: Responsive.h(1.5)),

          _ajusteCard(
            icono: Icons.text_fields_rounded,
            titulo: "Tamaño de texto",
            subtitulo: "Actual: ${settings.tamanoTextoLabel}",
            trailing: null,
            child: Padding(
              padding: EdgeInsets.only(top: Responsive.h(1.8)),
              child: Row(
                children: [
                  _tamanoChip("Pequeño", 0.85),
                  SizedBox(width: Responsive.w(2)),
                  _tamanoChip("Normal", 1.0),
                  SizedBox(width: Responsive.w(2)),
                  _tamanoChip("Grande", 1.15),
                ],
              ),
            ),
          ),

          SizedBox(height: Responsive.h(3.5)),

          _seccionTitulo("Notificaciones"),

          SizedBox(height: Responsive.h(1.5)),

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

          SizedBox(height: Responsive.h(3.5)),

          _seccionTitulo("Sobre la app"),

          SizedBox(height: Responsive.h(1.5)),

          _ajusteCard(
            icono: Icons.info_outline_rounded,
            titulo: "Versión",
            subtitulo: "PadelPro v1.0.0",
            trailing: const SizedBox(),
          ),

          SizedBox(height: Responsive.h(1.8)),

          _ajusteCard(
            icono: Icons.school_rounded,
            titulo: "Proyecto TFG",
            subtitulo: "Desarrollo de Aplicaciones Multiplataforma",
            trailing: const SizedBox(),
          ),

          SizedBox(height: Responsive.h(4.5)),
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
          style: TextStyle(
            fontSize: Responsive.font(16),
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: const Color(0xFF1F5DA0),
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
      padding: EdgeInsets.all(Responsive.padding(16)),
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
                padding: EdgeInsets.all(Responsive.padding(10)),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F5DA0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: const Color(0xFF1F5DA0), size: Responsive.imageSize(22)),
              ),
              SizedBox(width: Responsive.w(3.5)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.font(15),
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey,
                        fontSize: Responsive.font(12),
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
          padding: EdgeInsets.symmetric(vertical: Responsive.padding(10)),
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
                fontSize: Responsive.font(13),
              ),
            ),
          ),
        ),
      ),
    );
  }
}