import 'dart:convert';
import 'package:http/http.dart' as http;

class RecuperarService {

  static const String baseUrl = "https://padelpro-tfg.onrender.com/api";

  static Future<Map<String, dynamic>> solicitarCodigo(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuarios/recuperar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "mensaje": data["mensaje"]
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "mensaje": data["mensaje"] ?? "Error al solicitar código"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error de conexión. Inténtalo de nuevo."
      };
    }
  }

  static Future<Map<String, dynamic>> cambiarPassword(
    String email,
    String codigo,
    String nuevaPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuarios/cambiar-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "codigo": codigo,
          "nuevaPassword": nuevaPassword
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "mensaje": data["mensaje"]
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "mensaje": data["mensaje"] ?? "Error al cambiar contraseña"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error de conexión. Inténtalo de nuevo."
      };
    }
  }

  static Future<Map<String, dynamic>> confirmarEmail(String email, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuarios/confirmar-email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "codigo": codigo}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "mensaje": data["mensaje"]
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "mensaje": data["mensaje"] ?? "Error al confirmar email"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error de conexión. Inténtalo de nuevo."
      };
    }
  }

  static Future<Map<String, dynamic>> reenviarConfirmacion(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuarios/reenviar-confirmacion"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "mensaje": data["mensaje"]
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "mensaje": data["mensaje"] ?? "Error al reenviar código"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "mensaje": "Error de conexión. Inténtalo de nuevo."
      };
    }
  }
}