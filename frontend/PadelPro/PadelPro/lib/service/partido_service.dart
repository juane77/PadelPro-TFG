import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class PartidoService {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  // Partidos propios del usuario
  static Future<List<dynamic>> getPartidosUsuario(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/partidos/usuario/$usuarioId"),
      headers: Session.authHeaders,
    );
    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  }

  // Partidos donde el usuario fue invitado
  static Future<List<dynamic>> getPartidosComoInvitado(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/partidos/invitado/$usuarioId"),
        headers: Session.authHeaders,
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return [];
  }

  // Todos los partidos (propios + invitado) combinados
  static Future<List<dynamic>> getTodosLosPartidos(int usuarioId) async {
    final results = await Future.wait([
      getPartidosUsuario(usuarioId),
      getPartidosComoInvitado(usuarioId),
    ]);
    final todos = [...results[0], ...results[1]];
    todos.sort((a, b) => b["fechaPartido"].toString().compareTo(a["fechaPartido"].toString()));
    return todos;
  }

  static Future<bool> registrarPartido({
    required int usuarioId,
    required int pistaId,
    int? reservaId,
    required String resultado,
    required double nivelMedio,
    required String resultadoFinal,
    required DateTime fechaPartido,
    String? amigosIds,
  }) async {
    final body = <String, dynamic>{
      "usuarioId": usuarioId,
      "pistaId": pistaId,
      "resultado": resultado,
      "nivelMedio": nivelMedio,
      "resultadoFinal": resultadoFinal,
      "fechaPartido": fechaPartido.toIso8601String(),
    };
    if (reservaId != null) body["reservaId"] = reservaId;
    if (amigosIds != null && amigosIds.isNotEmpty) body["amigosIds"] = amigosIds;

    final response = await http.post(
      Uri.parse("$baseUrl/partidos"),
      headers: Session.authHeaders,
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) return true;
    final data = json.decode(response.body);
    throw Exception(data["mensaje"]);
  }
}