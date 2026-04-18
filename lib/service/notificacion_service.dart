import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class NotificacionApi {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  static Future<List<dynamic>> getNotificaciones(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId"),
      headers: Session.authHeaders,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  static Future<int> getNoLeidas(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId/noLeidas"),
      headers: Session.authHeaders,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["noLeidas"];
    }
    return 0;
  }

  static Future<void> marcarLeida(int notificacionId) async {
    await http.put(
      Uri.parse("$baseUrl/notificaciones/$notificacionId/leer"),
      headers: Session.authHeaders,
    );
  }

  static Future<void> marcarTodasLeidas(int usuarioId) async {
    await http.put(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId/leerTodas"),
      headers: Session.authHeaders,
    );
  }
}