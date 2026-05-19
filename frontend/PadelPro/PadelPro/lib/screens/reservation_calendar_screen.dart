import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/pista.dart';
import '../service/reserva_service.dart';
import '../service/session.dart';
import '../service/notification_push_service.dart';
import '../service/reserva_provider.dart';
import '../utils/responsive.dart';
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

    // Validar que la hora no haya pasado
    if (fechaReserva.isBefore(DateTime.now())) {
      AppSnackbar.error(context, "No puedes reservar una hora que ya ha pasado");
      return;
    }

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
    Responsive.init(context);
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
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                fontSize: Responsive.font(18),
              ),
            ),
            Text(
              widget.pista.clubNombre,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: Responsive.font(12),
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: Responsive.padding(16)),
            padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(6)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text("🎾", style: TextStyle(fontSize: Responsive.font(14))),
                SizedBox(width: Responsive.w(1)),
                Text(
                  "${Session.pelotas}",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.font(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [

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
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.font(17),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                  fontSize: Responsive.font(12),
                ),
                weekendStyle: TextStyle(
                  color: Colors.white54,
                  fontFamily: "Poppins",
                  fontSize: Responsive.font(12),
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins",
                  fontSize: Responsive.font(14),
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.white30,
                  fontFamily: "Poppins",
                ),
                disabledTextStyle: TextStyle(
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

          SizedBox(height: Responsive.h(3)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(14), vertical: Responsive.padding(6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F5DA0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_nombreDia(selectedDay)} ${selectedDay.day} ${_nombreMes(selectedDay)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.font(13),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.w(2.5)),
                Text(
                  "${horasReservadas.length} hora${horasReservadas.length == 1 ? '' : 's'} ocupada${horasReservadas.length == 1 ? '' : 's'}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: "Poppins",
                    fontSize: Responsive.font(13),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.h(1.8)),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(16)),
              itemCount: horas.length,
              itemBuilder: (context, index) {
                final hora = horas[index];
                final ocupada = horasReservadas.contains(hora);

                return Container(
                  margin: EdgeInsets.only(bottom: Responsive.h(1.8)),
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
                    padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20), vertical: Responsive.padding(14)),
                    child: Row(
                      children: [

                        Container(
                          padding: EdgeInsets.all(Responsive.padding(10)),
                          decoration: BoxDecoration(
                            color: ocupada
                                ? Colors.red.withOpacity(0.1)
                                : const Color(0xFF1F5DA0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: ocupada ? Colors.red : const Color(0xFF1F5DA0),
                            size: Responsive.imageSize(22),
                          ),
                        ),

                        SizedBox(width: Responsive.w(4)),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hora,
                                style: TextStyle(
                                  fontSize: Responsive.font(18),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              Text(
                                "1 hora · ${ocupada ? 'No disponible' : 'Disponible'}",
                                style: TextStyle(
                                  fontSize: Responsive.font(12),
                                  fontFamily: "Poppins",
                                  color: ocupada ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (ocupada)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: Responsive.padding(14), vertical: Responsive.padding(8)),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Ocupado",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                fontSize: Responsive.font(13),
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F5DA0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20), vertical: Responsive.padding(10)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => reservar(hora),
                            child: Text(
                              "Reservar",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.font(13),
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

          SizedBox(height: Responsive.h(1.2)),
        ],
      ),
    );
  }
}