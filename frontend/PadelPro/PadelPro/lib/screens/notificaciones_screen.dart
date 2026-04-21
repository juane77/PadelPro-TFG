import 'package:flutter/material.dart';
import '../service/notificacion_service.dart';
import '../service/session.dart';
import '../utils/app_snackbar.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {

  late Future<List<dynamic>> notificaciones;

  @override
  void initState() {
    super.initState();
    notificaciones = NotificacionApi.getNotificaciones(Session.usuarioId!);
  }

  void recargar() {
    setState(() {
      notificaciones = NotificacionApi.getNotificaciones(Session.usuarioId!);
    });
  }

  void borrarUna(int id) async {
    final ok = await NotificacionApi.borrarNotificacion(id);
    if (ok) {
      recargar();
      AppSnackbar.exito(context, "Notificación eliminada");
    }
  }

  void borrarTodas() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "¿Borrar todas?",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Se eliminarán todas las notificaciones.",
          style: TextStyle(fontFamily: "Poppins", color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar", style: TextStyle(fontFamily: "Poppins", color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Borrar todas", style: TextStyle(fontFamily: "Poppins")),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    final ok = await NotificacionApi.borrarTodas(Session.usuarioId!);
    if (ok) {
      recargar();
      AppSnackbar.exito(context, "Todas las notificaciones eliminadas");
    }
  }

  Color colorPorTipo(String tipo) {
    switch (tipo) {
      case "ALERTA": return Colors.red;
      case "IMPORTANTE": return Colors.orange;
      default: return const Color(0xFF1F5DA0);
    }
  }

  IconData iconoPorTipo(String tipo) {
    switch (tipo) {
      case "ALERTA": return Icons.warning_rounded;
      case "IMPORTANTE": return Icons.info_rounded;
      default: return Icons.check_circle_rounded;
    }
  }

  String etiquetaPorTipo(String tipo) {
    switch (tipo) {
      case "ALERTA": return "ALERTA";
      case "IMPORTANTE": return "IMPORTANTE";
      default: return "INFO";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificacionApi.marcarTodasLeidas(Session.usuarioId!);
              recargar();
            },
            child: const Text(
              "Leer todas",
              style: TextStyle(color: Colors.white70, fontFamily: "Poppins"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
            tooltip: "Borrar todas",
            onPressed: borrarTodas,
          ),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: notificaciones,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)));
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No tienes notificaciones",
                    style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {

              final n = snapshot.data![index];
              final tipo = n["tipo"] as String;
              final leida = n["leida"] as bool;
              final color = colorPorTipo(tipo);
              final icono = iconoPorTipo(tipo);
              final etiqueta = etiquetaPorTipo(tipo);

              DateTime fecha = DateTime.parse(n["fecha"]);
              String fechaStr =
                  "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

              return Dismissible(
                key: Key("notif_${n["id"]}"),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => borrarUna(n["id"]),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (!leida) {
                      await NotificacionApi.marcarLeida(n["id"]);
                      recargar();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: leida ? Colors.white : color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: leida ? Colors.grey.shade200 : color.withOpacity(0.4),
                        width: leida ? 1 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icono, color: color, size: 24),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        etiqueta,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (!leida)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    // PAPELERA INDIVIDUAL
                                    GestureDetector(
                                      onTap: () => borrarUna(n["id"]),
                                      child: Icon(Icons.delete_outline_rounded,
                                          color: Colors.grey.shade400, size: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  n["mensaje"],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Poppins",
                                    fontWeight: leida ? FontWeight.normal : FontWeight.bold,
                                    color: leida ? Colors.grey[700] : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  fechaStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}