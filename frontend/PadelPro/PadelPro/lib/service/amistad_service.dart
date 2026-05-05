import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class AmistadService {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  // BUSCAR USUARIOS
  static Future<List<dynamic>> buscarUsuarios(String q) async {
    final response = await http.get(
      Uri.parse("$baseUrl/amistades/buscar?q=$q&usuarioId=${Session.usuarioId}"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  }

  // ENVIAR SOLICITUD
  static Future<bool> enviarSolicitud(int receptorId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/amistades/solicitar"),
      headers: Session.authHeaders,
      body: jsonEncode({"solicitanteId": Session.usuarioId, "receptorId": receptorId}),
    ).timeout(const Duration(seconds: 15));
    return response.statusCode == 201;
  }

  // ACEPTAR SOLICITUD
  static Future<bool> aceptarSolicitud(int idAmistad) async {
    final response = await http.put(
      Uri.parse("$baseUrl/amistades/$idAmistad/aceptar"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));
    return response.statusCode == 200;
  }

  // ELIMINAR/RECHAZAR AMISTAD
  static Future<bool> eliminarAmistad(int idAmistad) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/amistades/$idAmistad"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));
    return response.statusCode == 200;
  }

  // LISTAR AMIGOS
  static Future<List<dynamic>> getAmigos() async {
    final response = await http.get(
      Uri.parse("$baseUrl/amistades/usuario/${Session.usuarioId}"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  }

  // SOLICITUDES PENDIENTES
  static Future<List<dynamic>> getSolicitudesPendientes() async {
    final response = await http.get(
      Uri.parse("$baseUrl/amistades/pendientes/${Session.usuarioId}"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  }
}