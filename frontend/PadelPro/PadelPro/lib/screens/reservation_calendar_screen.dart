import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/pista.dart';
import '../service/reserva_service.dart';
import '../service/session.dart';

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

  /// PUNTOS DEL CALENDARIO
  Future<void> cargarReservasMes() async {

    final reservas = await ReservaService.getReservasUsuario(Session.usuarioId!);

    Map<DateTime, List<String>> mapa = {};

    for (var r in reservas.where((r) => r["estado"].toString().toUpperCase() == "ACTIVA")){

      DateTime fecha = DateTime.parse(r["fechaReserva"]);

      DateTime dia = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
      );

      if (!mapa.containsKey(dia)) {
        mapa[dia] = [];
      }

      mapa[dia]!.add("${fecha.hour}:00");
    }

    setState(() {
      reservasPorDia = mapa;
    });
  }

  /// CARGAR RESERVAS DEL DIA
  void cargarReservasDia() async {

    /// primero mira si ya tenemos reservas en memoria
    DateTime dia = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    if (reservasPorDia.containsKey(dia)) {

      setState(() {
        horasReservadas = reservasPorDia[dia]!;
      });

      return;
    }

    /// si no están en memoria las carga del backend
    List<String> reservas =
    await ReservaService.getHorasReservadas(
        widget.pista.id,
        selectedDay);

    setState(() {
      horasReservadas = reservas;
    });

  }

  /// CREAR RESERVA
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

      if(ok){

        setState(() {
          horasReservadas.add(hora);
        });

        cargarReservasMes();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reserva creada correctamente"),
          ),
        );
      }

    } catch(e){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        title: Text(widget.pista.nombre),
      ),

      body: Column(

        children: [

          TableCalendar(

            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDay,

            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },

            /// 🔥 AQUÍ ESTÁ EL ARREGLO
            onDaySelected: (selectedDayParam, focusedDay) {

              setState(() {
                selectedDay = selectedDayParam;
              });

              cargarReservasDia();

            },

            eventLoader: (day) {

              DateTime fecha = DateTime(
                day.year,
                day.month,
                day.day,
              );

              return reservasPorDia[fecha] ?? [];
            },

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            calendarStyle: const CalendarStyle(

              todayDecoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),

              selectedDecoration: BoxDecoration(
                color: Color(0xFF1F5DA0),
                shape: BoxShape.circle,
              ),

              markerDecoration: BoxDecoration(
                color: Color(0xFF1F5DA0),
                shape: BoxShape.circle,
              ),

            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Horas disponibles",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(

              itemCount: horas.length,

              itemBuilder: (context, index) {

                final hora = horas[index];

                bool ocupada = horasReservadas.contains(hora) ||
                    (reservasPorDia[selectedDay]?.contains(hora) ?? false);

                return ListTile(

                  title: Text(hora),

                  trailing: ocupada
                      ? const Text(
                    "Ocupado",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5DA0),
                      foregroundColor: Colors.white,
                    ),

                    onPressed: (){
                      reservar(hora);
                    },

                    child: const Text("Reservar"),
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }
}