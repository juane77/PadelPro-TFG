import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'session.dart';

class FotoService {

  static const String supabaseUrl = "https://vketxcsgjfpbgrgxwopv.supabase.co";
  static const String supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrZXR4Y3NnamZwYmdyZ3h3b3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MjYzODcsImV4cCI6MjA1OTEwMjM4N30.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
  static const String bucket = "avatares";

  // Subir foto a Supabase Storage
  static Future<String?> subirFoto(File foto) async {
    try {
      final extension = foto.path.split('.').last.toLowerCase();
      final fileName = "avatar_${Session.usuarioId}.$extension";
      final url = "$supabaseUrl/storage/v1/object/$bucket/$fileName";

      final bytes = await foto.readAsBytes();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $supabaseKey",
          "Content-Type": "image/$extension",
          "x-upsert": "true", // sobreescribe si ya existe
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Devolver URL pública
        return "$supabaseUrl/storage/v1/object/public/$bucket/$fileName";
      } else {
        print("Error subiendo foto: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error en subirFoto: $e");
      return null;
    }
  }

  // Obtener URL pública de la foto de un usuario
  static String? getUrlFoto(int usuarioId) {
    // Intenta jpg primero, si no existe devuelve null
    // En la app usamos NetworkImage que maneja el error
    return "$supabaseUrl/storage/v1/object/public/$bucket/avatar_$usuarioId.jpg";
  }

  // Comprobar si un usuario tiene foto subida
  static Future<bool> tieneFoto(int usuarioId) async {
    try {
      final url = "$supabaseUrl/storage/v1/object/public/$bucket/avatar_$usuarioId.jpg";
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}