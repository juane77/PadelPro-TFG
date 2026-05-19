import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ReservaDetailScreen extends StatelessWidget {

  final dynamic reserva;

  const ReservaDetailScreen({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    DateTime fecha = DateTime.parse(reserva["fechaReserva"]);

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        title: Text(
          "Detalle reserva",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18)),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(Responsive.padding(20)),

        child: Container(
          padding: EdgeInsets.all(Responsive.padding(20)),

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
                style: TextStyle(
                  fontSize: Responsive.font(24),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: Responsive.h(3)),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 6),
                  Text(reserva["pista"]["club"]["nombre"], style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(14))),
                ],
              ),
              SizedBox(height: Responsive.h(1.5)),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 6),
                  Text("${fecha.day}/${fecha.month}/${fecha.year}", style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(14))),
                ],
              ),
              SizedBox(height: Responsive.h(1.5)),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: 6),
                  Text("${fecha.hour}:00", style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(14))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}