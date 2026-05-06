import 'package:flutter/material.dart';
import '../service/reserva_service.dart';
import '../service/session.dart';
import '../service/notification_push_service.dart';
import '../utils/app_snackbar.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {

  late Future<List> reservas;

  @override
  void initState() {
    super.initState();
    reservas = ReservaService.getReservasUsuario(Session.usuarioId!);
  }

  void cancelarReserva(int id) async {
    // Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "¿Cancelar reserva?",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Esta acción no se puede deshacer.",
          style: TextStyle(fontFamily: "Poppins", color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Volver",
              style: TextStyle(fontFamily: "Poppins", color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Cancelar reserva",
              style: TextStyle(fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      bool ok = await ReservaService.cancelarReserva(id);

      if (ok) {
        setState(() {
          reservas = ReservaService.getReservasUsuario(Session.usuarioId!);
          Session.pelotas += 10;
        });

        await PushService.notificarImportante(
          "Reserva cancelada",
          "Tu reserva ha sido cancelada correctamente",
        );

        AppSnackbar.exito(context, "Reserva cancelada correctamente");
      }
    } catch (e) {
      final mensaje = e.toString().replaceAll("Exception: ", "");

      await PushService.notificarAlerta("No se pudo cancelar", mensaje);

      AppSnackbar.error(context, mensaje);
    }
  }

  String _nombreMes(int mes) {
    const meses = [
      "ENE", "FEB", "MAR", "ABR", "MAY", "JUN",
      "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"
    ];
    return meses[mes - 1];
  }

  String _nombreDiaSemana(DateTime fecha) {
    const dias = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return dias[fecha.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mis reservas",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: FutureBuilder(
        future: reservas,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)));
          }

          List lista = snapshot.data!
              .where((r) => r["estado"] == "ACTIVA")
              .toList();

          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No tienes reservas activas",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final reserva = lista[index];
              DateTime fecha = DateTime.parse(reserva["fechaReserva"]);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [

                      // BLOQUE FECHA IZQUIERDA
                      Container(
                        width: 58,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5DA0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${fecha.day}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                            Text(
                              _nombreMes(fecha.month),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // INFO CENTRAL
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reserva["pista"]["nombre"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reserva["pista"]["club"]["nombre"],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _nombreDiaSemana(fecha),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${fecha.hour}:00",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // BOTÓN CANCELAR
                      GestureDetector(
                        onTap: () => cancelarReserva(reserva["id"]),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
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