import 'package:flutter/material.dart';
import '../service/reserva_service.dart';
import '../service/session.dart';

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

    try {

      bool ok = await ReservaService.cancelarReserva(id);

      if (ok) {

        setState(() {
          reservas = ReservaService.getReservasUsuario(Session.usuarioId!);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reserva cancelada correctamente"),
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
        title: const Text("Mis reservas"),
      ),

      body: FutureBuilder(

        future: reservas,

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List lista = snapshot.data!
              .where((r) => r["estado"] == "ACTIVA")
              .toList();

          if(lista.isEmpty){
            return const Center(
              child: Text("No tienes reservas"),
            );
          }

          return ListView.builder(

            padding: const EdgeInsets.all(15),

            itemCount: lista.length,

            itemBuilder: (context, index) {

              final reserva = lista[index];

              DateTime fecha =
              DateTime.parse(reserva["fechaReserva"]);

              return Container(

                margin: const EdgeInsets.only(bottom: 20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],

                ),

                child: Padding(

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        reserva["pista"]["nombre"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        reserva["pista"]["club"]["nombre"],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(

                        children: [

                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            "${fecha.day}/${fecha.month}/${fecha.year}",
                          ),

                          const SizedBox(width: 20),

                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 6),

                          Text("${fecha.hour}:00"),

                        ],

                      ),

                      const SizedBox(height: 15),

                      SizedBox(

                        width: double.infinity,

                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),

                          onPressed: () {
                            cancelarReserva(reserva["id"]);
                          },

                          child: const Text("Cancelar reserva"),

                        ),

                      )

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