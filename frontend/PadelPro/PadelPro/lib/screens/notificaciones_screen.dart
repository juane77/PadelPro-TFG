import 'package:flutter/material.dart';
import '../service/notificacion_service.dart';
import '../service/session.dart';
import '../utils/responsive.dart';
import '../utils/app_snackbar.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {

  List<dynamic> noticias = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() => cargando = true);
    final lista = await NotificacionApi.getNotificaciones(Session.usuarioId!);
    setState(() {
      noticias = lista;
      cargando = false;
    });
  }

  void recargar() => cargar();

  void borrarUna(int id) async {
    setState(() {
      noticias.removeWhere((n) => n["id"] == id);
    });
    await NotificacionApi.borrarNotificacion(id);
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
    Responsive.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        title: Text(
          "Notificaciones",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18)),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificacionApi.marcarTodasLeidas(Session.usuarioId!);
              recargar();
            },
            child: Text(
              "Leer todas",
              style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: Responsive.font(13)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
            tooltip: "Borrar todas",
            onPressed: borrarTodas,
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)))
          : noticias.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: Responsive.imageSize(64), color: Colors.grey.shade300),
                      SizedBox(height: Responsive.h(2.5)),
                      Text(
                        "No tienes notificaciones",
                        style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(15)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(Responsive.padding(16)),
                  itemCount: noticias.length,
                  itemBuilder: (context, index) {
                    final n = noticias[index];
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
                  margin: EdgeInsets.only(bottom: Responsive.h(1.8)),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: Responsive.padding(20)),
                  child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (!leida) {
                      await NotificacionApi.marcarLeida(n["id"]);
                      cargar();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: Responsive.h(1.8)),
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
                      padding: EdgeInsets.all(Responsive.padding(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            padding: EdgeInsets.all(Responsive.padding(10)),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icono, color: color, size: Responsive.imageSize(24)),
                          ),

                          SizedBox(width: Responsive.w(3.5)),

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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Responsive.font(10),
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
                                    SizedBox(width: Responsive.w(2)),
                                    GestureDetector(
                                      onTap: () => borrarUna(n["id"]),
                                      child: Icon(Icons.delete_outline_rounded,
                                          color: Colors.grey.shade400, size: Responsive.imageSize(20)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.h(1.2)),
                                Text(
                                  n["mensaje"],
                                  style: TextStyle(
                                    fontSize: Responsive.font(14),
                                    fontFamily: "Poppins",
                                    fontWeight: leida ? FontWeight.normal : FontWeight.bold,
                                    color: leida ? Colors.grey[700] : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: Responsive.h(0.9)),
                                Text(
                                  fechaStr,
                                  style: TextStyle(
                                    fontSize: Responsive.font(12),
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
          ),
    );
  }
}