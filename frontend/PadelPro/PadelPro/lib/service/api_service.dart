import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pista.dart';

class ApiService {

  static const String baseUrl = "http://10.0.2.2:8080/api";

  static Future<List<Pista>> getPistas() async {

    final response = await http.get(
      Uri.parse("$baseUrl/pistas"),
    );

    if (response.statusCode == 200) {

      List data = json.decode(response.body);

      return data.map((p) => Pista.fromJson(p)).toList();

    } else {

      throw Exception("Error cargando pistas");

    }

  }
  static Future<List<Pista>> buscarPistas({
    String? ciudad,
    String? tipo,
    double? precioMax,
  }) async {

    String url = "$baseUrl/pistas?";

    if(ciudad != null && ciudad.isNotEmpty){
      url += "ciudad=$ciudad&";
    }

    if(tipo != null && tipo.isNotEmpty){
      url += "tipo=$tipo&";
    }

    if(precioMax != null){
      url += "precioMax=$precioMax";
    }

    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){

      List data = json.decode(response.body);

      return data.map((p) => Pista.fromJson(p)).toList();

    }

    return [];
  }

  static Future<List<Pista>> getPistasFiltradas({
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

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      List data = json.decode(response.body);

      return data.map((p) => Pista.fromJson(p)).toList();

    } else {

      throw Exception("Error en búsqueda");

    }

  }

}