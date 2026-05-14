import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

const _timeout = Duration(seconds: 15);

class NotificacionApi {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  static Future<List<dynamic>> getNotificaciones(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId"),
      headers: Session.authHeaders,
    ).timeout(_timeout);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  static Future<int> getNoLeidas(int usuarioId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId/noLeidas"),
      headers: Session.authHeaders,
    ).timeout(_timeout);
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
    ).timeout(_timeout);
  }

  static Future<void> marcarTodasLeidas(int usuarioId) async {
    await http.put(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId/leerTodas"),
      headers: Session.authHeaders,
    ).timeout(_timeout);
  }

  static Future<bool> borrarNotificacion(int notificacionId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/notificaciones/$notificacionId"),
      headers: Session.authHeaders,
    ).timeout(_timeout);
    return response.statusCode == 200;
  }

  static Future<bool> borrarTodas(int usuarioId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/notificaciones/usuario/$usuarioId"),
      headers: Session.authHeaders,
    ).timeout(_timeout);
    return response.statusCode == 200;
  }
}