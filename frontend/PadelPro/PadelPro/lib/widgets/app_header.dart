import 'package:flutter/material.dart';
import '../service/session.dart';

class AppHeader extends StatelessWidget {

  final String titulo;
  final Widget? extra;
  final String? fotoUrl;

  const AppHeader({
    super.key,
    required this.titulo,
    this.extra,
    this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final inicial = (Session.nombre != null && Session.nombre!.isNotEmpty)
        ? Session.nombre![0].toUpperCase()
        : "?";

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1F5DA0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.02, w * 0.05, h * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PadelPro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (w * 0.065).clamp(20.0, 30.0),
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),

              // AVATAR
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.25),
                backgroundImage: fotoUrl != null
                    ? NetworkImage(fotoUrl!)
                    : null,
                child: fotoUrl == null
                    ? Text(
                        inicial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ],
          ),

          SizedBox(height: h * 0.005),

          Text(
            titulo,
            style: TextStyle(
              color: Colors.white70,
              fontSize: (w * 0.037).clamp(12.0, 17.0),
              fontFamily: "Poppins",
            ),
          ),

          if (extra != null) ...[
            SizedBox(height: h * 0.018),
            extra!,
          ],
        ],
      ),
    );
  }
}