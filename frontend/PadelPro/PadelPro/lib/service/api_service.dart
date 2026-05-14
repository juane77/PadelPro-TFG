import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pista.dart';
import 'session.dart';

class ApiService {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  static Future<List<Pista>> getPistas() async {

    final response = await http.get(
      Uri.parse("$baseUrl/pistas"),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((p) => Pista.fromJson(p)).toList();
    }
    Session.checkAuth(response);
    throw Exception("Error cargando pistas");
  }

  static Future<List<Pista>> buscarPistas({
    String? ciudad,
    String? tipo,
    double? precioMax,
  }) async {

    String url = "$baseUrl/pistas?";

    if (ciudad != null && ciudad.isNotEmpty) {
      url += "ciudad=$ciudad&";
    }
    if (tipo != null && tipo.isNotEmpty) {
      url += "tipo=$tipo&";
    }
    if (precioMax != null) {
      url += "precioMax=$precioMax";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: Session.authHeaders,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((p) => Pista.fromJson(p)).toList();
    }
    Session.checkAuth(response);
    return [];
  }
}