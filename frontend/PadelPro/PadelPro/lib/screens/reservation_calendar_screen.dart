import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/pista.dart';
import '../service/reserva_service.dart';
import '../service/session.dart';
import '../service/notification_push_service.dart';
import '../service/reserva_provider.dart';
import '../utils/app_snackbar.dart';

class ReservationCalendarScreen extends StatefulWidget {

  final Pista pista;

  const ReservationCalendarScreen({super.key, required this.pista});

  @override
  State<ReservationCalendarScreen> createState() =>
      _ReservationCalendarScreenState();
}

class _ReservationCalendarScreenState
    extends State<ReservationCalendarScreen> {

  DateTime selectedDay = DateTime.now();
  bool cargando = false;

  List<String> horas = [
    "17:00",
    "18:00",
    "19:00",
    "20:00",
    "21:00"
  ];

  List<String> horasReservadas = [];
  Map<DateTime, List<String>> reservasPorDia = {};

  @override
  void initState() {
    super.initState();
    cargarReservasMes();
    cargarReservasDia();
  }

  Future<void> cargarReservasMes() async {
    final reservas = await ReservaService.getReservasUsuario(Session.usuarioId!);
    Map<DateTime, List<String>> mapa = {};
    for (var r in reservas.where((r) => r["estado"].toString().toUpperCase() == "ACTIVA")) {
      DateTime fecha = DateTime.parse(r["fechaReserva"]);
      DateTime dia = DateTime(fecha.year, fecha.month, fecha.day);
      if (!mapa.containsKey(dia)) mapa[dia] = [];
      mapa[dia]!.add("${fecha.hour}:00");
    }
    setState(() {
      reservasPorDia = mapa;
    });
  }

  void cargarReservasDia() async {
    List<String> reservas = await ReservaService.getHorasReservadas(
        widget.pista.id, selectedDay);
    setState(() {
      horasReservadas = reservas;
    });
  }

  void reservar(String hora) async {
    final partes = hora.split(":");
    DateTime fechaReserva = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );

    try {
      bool ok = await ReservaService.crearReserva(
        usuarioId: Session.usuarioId!,
        pistaId: widget.pista.id,
        fecha: fechaReserva,
      );

      if (ok) {
        setState(() {
          horasReservadas.add(hora);
          Session.pelotas -= 15;
        });
        cargarReservasMes();
        
        context.read<ReservaProvider>().cargarReservas();

        await PushService.notificarInfo(
          "Reserva confirmada",
          "Tu reserva en ${widget.pista.nombre} el ${selectedDay.day}/${selectedDay.month} a las $hora ha sido confirmada",
        );

        AppSnackbar.exito(context, "Reserva creada correctamente");
      }
    } catch (e) {
      final mensaje = e.toString().replaceAll("Exception: ", "");
      if (mensaje.contains("máximo") || mensaje.contains("límite")) {
        await PushService.notificarAlerta("Límite alcanzado", mensaje);
      } else {
        await PushService.notificarImportante("Reserva no disponible", mensaje);
      }
      AppSnackbar.error(context, mensaje);
    }
  }

  String _nombreDia(DateTime fecha) {
    const dias = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    return dias[fecha.weekday - 1];
  }

  String _nombreMes(DateTime fecha) {
    const meses = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return meses[fecha.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.pista.nombre,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.pista.clubNombre,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text("🎾", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  "${Session.pelotas}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          // CABECERA AZUL CON CALENDARIO
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1F5DA0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDay,

              selectedDayPredicate: (day) => isSameDay(selectedDay, day),

              onDaySelected: (selectedDayParam, focusedDay) {
                setState(() {
                  selectedDay = selectedDayParam;
                });
                cargarReservasDia();
              },

              eventLoader: (day) {
                DateTime fecha = DateTime(day.year, day.month, day.day);
                return reservasPorDia[fecha] ?? [];
              },

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
                weekendStyle: TextStyle(
                  color: Colors.white54,
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
              ),

              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
                weekendTextStyle: const TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                ),
                outsideTextStyle: const TextStyle(
                  color: Colors.white30,
                  fontFamily: "Poppins",
                ),
                disabledTextStyle: const TextStyle(
                  color: Colors.white24,
                  fontFamily: "Poppins",
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Color(0xFF1F5DA0),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                markerSize: 5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ETIQUETA DÍA SELECCIONADO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F5DA0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_nombreDia(selectedDay)} ${selectedDay.day} ${_nombreMes(selectedDay)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${horasReservadas.length} hora${horasReservadas.length == 1 ? '' : 's'} ocupada${horasReservadas.length == 1 ? '' : 's'}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: "Poppins",
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // LISTA DE HORAS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: horas.length,
              itemBuilder: (context, index) {
                final hora = horas[index];
                final ocupada = horasReservadas.contains(hora);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [

                        // ICONO RELOJ
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ocupada
                                ? Colors.red.withOpacity(0.1)
                                : const Color(0xFF1F5DA0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: ocupada ? Colors.red : const Color(0xFF1F5DA0),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // HORA Y DURACIÓN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hora,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              Text(
                                "1 hora · ${ocupada ? 'No disponible' : 'Disponible'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  color: ocupada ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // BOTÓN O BADGE OCUPADO
                        if (ocupada)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Ocupado",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F5DA0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => reservar(hora),
                            child: const Text(
                              "Reservar",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}