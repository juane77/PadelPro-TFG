import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class PartidoService {

  static const String baseUrl = "http://10.0.2.2:8080/api";

  static Future<List<dynamic>> getPartidosUsuario(int usuarioId) async {

    final response = await http.get(
      Uri.parse("$baseUrl/partidos/usuario/$usuarioId"),
      headers: Session.authHeaders,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return [];
  }

  static Future<bool> registrarPartido({
    required int usuarioId,
    required int pistaId,
    required String resultado,
    required double nivelMedio,
    required String resultadoFinal,
    required DateTime fechaPartido,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/partidos"),
      headers: Session.authHeaders,
      body: jsonEncode({
        "usuarioId": usuarioId,
        "pistaId": pistaId,
        "resultado": resultado,
        "nivelMedio": nivelMedio,
        "resultadoFinal": resultadoFinal,
        "fechaPartido": fechaPartido.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return true;
    }

    final data = json.decode(response.body);
    throw Exception(data["mensaje"]);
  }
}