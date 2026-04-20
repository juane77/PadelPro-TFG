import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {

  final String titulo;
  final Widget? extra;

  const AppHeader({
    super.key,
    required this.titulo,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

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
          Text(
            "PadelPro",
            style: TextStyle(
              color: Colors.white,
              fontSize: (w * 0.065).clamp(20.0, 30.0),
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
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