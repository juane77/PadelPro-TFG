import 'dart:io';
import 'package:http/http.dart' as http;
import 'session.dart';

class FotoService {

  static const String supabaseUrl = "https://vketxcsgjfpbgrgxwopv.supabase.co";
  static const String supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrZXR4Y3NnamZwYmdyZ3h3b3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0MzMwNDMsImV4cCI6MjA5MjAwOTA0M30.mM7WW21wEniHUyh2nvcG5Lz-nd8zYI4rLWhlcQuRLU0";
  static const String bucket = "avatares";

  // Subir foto a Supabase Storage
  static Future<String?> subirFoto(File foto) async {
    try {
      final fileName = "avatar_${Session.usuarioId}.jpg";
      final url = "$supabaseUrl/storage/v1/object/$bucket/$fileName";

      final bytes = await foto.readAsBytes();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $supabaseKey",
          "Content-Type": "image/jpeg",
          "x-upsert": "true",
        },
        body: bytes,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}