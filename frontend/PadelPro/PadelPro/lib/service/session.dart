class Session {

  static int? usuarioId;
  static String? nombre;
  static String? email;
  static String? token;
  static int pelotas = 0;

  // Header listo para usar en todas las peticiones
  static Map<String, String> get authHeaders => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}