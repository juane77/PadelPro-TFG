import 'package:flutter/material.dart';
import '../models/pista.dart';
import 'reservation_calendar_screen.dart';

class PistaDetailScreen extends StatelessWidget {

  final Pista pista;

  const PistaDetailScreen({super.key, required this.pista});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        title: Text(pista.nombre),
      ),

      body: Column(
        children: [

          Image.asset(
            "assets/images/Basica1.png",
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  pista.nombre,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    const Icon(Icons.location_on),

                    const SizedBox(width: 5),

                    Text(pista.ciudad),

                  ],
                ),

                const SizedBox(height: 10),

                Text("${pista.precioHora}€/hora"),

                const SizedBox(height: 30),

                const Text(
                  "Descripción",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Pista profesional ideal para jugar partidos y entrenar.",
                ),

              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(20),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F5DA0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReservationCalendarScreen(pista: pista),
                    ),
                  );

                },

                child: const Text(
                  "Reservar pista",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

              ),
            ),
          )

        ],
      ),
    );
  }
}