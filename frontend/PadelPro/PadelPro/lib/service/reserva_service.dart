import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservaService {

  static const String baseUrl = "http://10.0.2.2:8080/api";

  /// HORAS RESERVADAS DE UNA PISTA EN UN DIA
  static Future<List<String>> getHorasReservadas(
      int pistaId,
      DateTime fecha,
      ) async {

    String fechaStr =
        "${fecha.year}-${fecha.month}-${fecha.day}";

    final response = await http.get(
      Uri.parse("$baseUrl/reservas/pista/$pistaId?fecha=$fechaStr"),
    );

    if (response.statusCode == 200) {

      List data = json.decode(response.body);

      List<String> horas = [];

      for (var reserva in data) {

        DateTime fechaReserva =
        DateTime.parse(reserva["fechaReserva"]);

        String hora =
            "${fechaReserva.hour.toString().padLeft(2,'0')}:00";

        horas.add(hora);
      }

      return horas;
    }

    return [];
  }

  /// CREAR RESERVA
  static Future<bool> crearReserva({
    required int usuarioId,
    required int pistaId,
    required DateTime fecha,
  }) async {

    final response = await http.post(

      Uri.parse("$baseUrl/reservas"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "usuarioId": usuarioId,
        "pistaId": pistaId,
        "fechaReserva": fecha.toIso8601String()

      }),
    );

    if (response.statusCode == 201) {
      return true;
    }

    /// LEER MENSAJE DEL BACKEND
    final data = json.decode(response.body);

    throw Exception(data["mensaje"]);
  }

  /// RESERVAS DEL USUARIO
  static Future<List<dynamic>> getReservasUsuario(int usuarioId) async {

    final response = await http.get(
      Uri.parse("$baseUrl/reservas/usuario/$usuarioId"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return [];
  }

  /// CANCELAR RESERVA
  static Future<bool> cancelarReserva(int reservaId) async {

    final response = await http.put(
      Uri.parse("$baseUrl/reservas/$reservaId/cancelar"),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final data = json.decode(response.body);

    throw Exception(data["mensaje"]);
  }

}