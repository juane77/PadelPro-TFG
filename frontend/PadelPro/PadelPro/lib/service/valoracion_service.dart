import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class ValoracionService {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  // Obtener media y mi valoración de una pista
  static Future<Map<String, dynamic>> getValoracion(int pistaId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/valoraciones/pista/$pistaId/usuario/${Session.usuarioId}"),
        headers: Session.authHeaders,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}
    return {"media": 4.0, "total": 0, "miValoracion": 0.0};
  }

  // Valorar una pista
  static Future<Map<String, dynamic>> valorar(int pistaId, double puntuacion) async {
    final response = await http.post(
      Uri.parse("$baseUrl/valoraciones"),
      headers: Session.authHeaders,
      body: jsonEncode({
        "usuarioId": Session.usuarioId,
        "pistaId": pistaId,
        "puntuacion": puntuacion,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception("Error al valorar");
  }
}