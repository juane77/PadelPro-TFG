import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class ReservaService {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  static Future<List<String>> getHorasReservadas(
      int pistaId,
      DateTime fecha,
      ) async {

    String fechaStr =
        "${fecha.year}-${fecha.month.toString().padLeft(2,'0')}-${fecha.day.toString().padLeft(2,'0')}";

    final response = await http.get(
      Uri.parse("$baseUrl/reservas/pista/$pistaId?fecha=$fechaStr"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {

      List data = json.decode(response.body);
      List<String> horas = [];

      for (var reserva in data) {
        DateTime fechaReserva = DateTime.parse(reserva["fechaReserva"]);
        String hora = "${fechaReserva.hour.toString().padLeft(2,'0')}:00";
        horas.add(hora);
      }

      return horas;
    }

    return [];
  }

  static Future<bool> crearReserva({
    required int usuarioId,
    required int pistaId,
    required DateTime fecha,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/reservas"),
      headers: Session.authHeaders,
      body: jsonEncode({
        "usuarioId": usuarioId,
        "pistaId": pistaId,
        "fechaReserva": fecha.toIso8601String()
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      return true;
    }
    Session.checkAuth(response);
    final data = json.decode(response.body);
    throw Exception(data["mensaje"]);
  }

  static Future<List<dynamic>> getReservasUsuario(int usuarioId) async {

    final response = await http.get(
      Uri.parse("$baseUrl/reservas/usuario/$usuarioId"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    Session.checkAuth(response);
    return [];
  }

  static Future<bool> cancelarReserva(int reservaId) async {

    final response = await http.put(
      Uri.parse("$baseUrl/reservas/$reservaId/cancelar"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return true;
    }
    Session.checkAuth(response);
    final data = json.decode(response.body);
    throw Exception(data["mensaje"]);
  }
}