import 'package:flutter/material.dart';

class ReservaDetailScreen extends StatelessWidget {

  final dynamic reserva;

  const ReservaDetailScreen({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {

    DateTime fecha = DateTime.parse(reserva["fechaReserva"]);

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        title: const Text("Detalle reserva"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Container(

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              )
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                reserva["pista"]["nombre"],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  const Icon(Icons.location_on),

                  const SizedBox(width: 6),

                  Text(reserva["pista"]["club"]["nombre"]),

                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  const Icon(Icons.calendar_today),

                  const SizedBox(width: 6),

                  Text("${fecha.day}/${fecha.month}/${fecha.year}"),

                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  const Icon(Icons.schedule),

                  const SizedBox(width: 6),

                  Text("${fecha.hour}:00"),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}