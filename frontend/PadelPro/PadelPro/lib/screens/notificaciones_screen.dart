import 'package:flutter/material.dart';
import '../service/notificacion_service.dart';
import '../service/session.dart';

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

  // Color según tipo
  Color colorPorTipo(String tipo) {
    switch (tipo) {
      case "ALERTA":
        return Colors.red;
      case "IMPORTANTE":
        return Colors.orange;
      default:
        return const Color(0xFF1F5DA0);
    }
  }

  // Icono según tipo
  IconData iconoPorTipo(String tipo) {
    switch (tipo) {
      case "ALERTA":
        return Icons.warning_rounded;
      case "IMPORTANTE":
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  // Etiqueta según tipo
  String etiquetaPorTipo(String tipo) {
    switch (tipo) {
      case "ALERTA":
        return "ALERTA";
      case "IMPORTANTE":
        return "IMPORTANTE";
      default:
        return "INFO";
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
          style: TextStyle(fontFamily: "Poppins"),
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
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: notificaciones,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No tienes notificaciones",
                    style: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
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

              return GestureDetector(
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

                        // ICONO
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icono, color: color, size: 24),
                        ),

                        const SizedBox(width: 14),

                        // CONTENIDO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  // ETIQUETA TIPO
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
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

                                  // PUNTO ROJO SI NO LEÍDA
                                  if (!leida)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                n["mensaje"],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  fontWeight: leida
                                      ? FontWeight.normal
                                      : FontWeight.bold,
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
              );
            },
          );
        },
      ),
    );
  }
}