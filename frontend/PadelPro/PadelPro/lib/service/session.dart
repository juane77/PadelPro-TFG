class Session {

  static int? usuarioId;
  static String? nombre;
  static String? email;
  static String? token;
  static int pelotas = 0;
  static String? rol;
  static int? idClub;
  static String? clubNombre;

  static Map<String, String> get authHeaders => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  static void clear() {
    usuarioId = null;
    nombre = null;
    email = null;
    token = null;
    pelotas = 0;
    rol = null;
    idClub = null;
    clubNombre = null;
  }
}