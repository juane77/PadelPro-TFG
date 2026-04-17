class Session {

  static int? usuarioId;
  static String? nombre;
  static String? email;
  static String? token; // 🔑 Token JWT

  // Header listo para usar en todas las peticiones
  static Map<String, String> get authHeaders => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}