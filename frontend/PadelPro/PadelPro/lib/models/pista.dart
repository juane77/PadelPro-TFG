class Pista {

  final int id;
  final String nombre;
  final String tipo;
  final double precioHora;
  final String clubNombre;
  final String ciudad;

  Pista({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.precioHora,
    required this.clubNombre,
    required this.ciudad,
  });

  factory Pista.fromJson(Map<String, dynamic> json) {

    return Pista(
      id: json["id"],
      nombre: json["nombre"],
      tipo: json["tipo"],
      precioHora: json["precioHora"].toDouble(),
      clubNombre: json["club"]["nombre"],
      ciudad: json["club"]["ciudad"],
    );

  }
}