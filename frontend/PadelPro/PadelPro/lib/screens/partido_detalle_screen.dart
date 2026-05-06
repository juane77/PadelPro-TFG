import 'package:flutter/material.dart';
import '../service/valoracion_service.dart';
import '../service/session.dart';
import '../utils/app_snackbar.dart';

class PartidoDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> partido;

  const PartidoDetalleScreen({super.key, required this.partido});

  @override
  State<PartidoDetalleScreen> createState() => _PartidoDetalleScreenState();
}

class _PartidoDetalleScreenState extends State<PartidoDetalleScreen> {

  double mediaValoracion = 4.0;
  double miValoracion = 0.0;
  int totalValoraciones = 0;
  bool cargandoValoracion = true;

  @override
  void initState() {
    super.initState();
    _cargarValoracion();
  }

  Future<void> _cargarValoracion() async {
    final pistaId = widget.partido["pistaId"];
    if (pistaId == null) { setState(() => cargandoValoracion = false); return; }
    final data = await ValoracionService.getValoracion(pistaId as int);
    setState(() {
      mediaValoracion = (data["media"] as num).toDouble();
      miValoracion = (data["miValoracion"] as num).toDouble();
      totalValoraciones = (data["total"] as num).toInt();
      cargandoValoracion = false;
    });
  }

  Future<void> _valorar(double puntuacion) async {
    final pistaId = widget.partido["pistaId"];
    if (pistaId == null) return;
    try {
      final data = await ValoracionService.valorar(pistaId as int, puntuacion);
      setState(() {
        miValoracion = puntuacion;
        mediaValoracion = (data["media"] as num).toDouble();
        totalValoraciones = (data["total"] as num).toInt();
      });
      AppSnackbar.exito(context, "Valoración guardada ⭐");
    } catch (e) {
      AppSnackbar.error(context, "Error al guardar la valoración");
    }
  }

  @override
  Widget build(BuildContext context) {
    final partido = widget.partido;
    final bool ganado = partido["resultadoFinal"] == "GANADO";
    final bool esInvitado = partido["esInvitado"] == true;
    final bool verificado = partido["reservaVinculada"] == true;
    final Color color = ganado ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final Color bgColor = ganado ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    DateTime fecha = DateTime.parse(partido["fechaPartido"]);
    const meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];

    // Amigos que jugaron
    List<String> amigosIds = [];
    if (partido["amigosIds"] != null && partido["amigosIds"].toString().isNotEmpty) {
      amigosIds = partido["amigosIds"].toString().split(",").where((s) => s.trim().isNotEmpty).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        title: const Text("Detalle del partido", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HERO RESULTADO
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ganado
                      ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                      : [const Color(0xFF7F0000), const Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // BADGES
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(ganado ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(ganado ? "GANADO" : "PERDIDO", style: const TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (verificado) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text("Verificado", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                      if (esInvitado) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.people_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              const Text("Invitado", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // MARCADOR GRANDE
                  Text(
                    partido["resultado"],
                    style: const TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 44, fontWeight: FontWeight.bold, height: 1),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year} · ${fecha.hour}:00h",
                    style: const TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // INFO PISTA Y CLUB
                  _seccion("Pista y club"),
                  _infoCard([
                    _infoRow(Icons.sports_tennis, "Pista", partido["pista"]),
                    _divider(),
                    _infoRow(Icons.location_city_rounded, "Club", partido["club"]),
                    _divider(),
                    _infoRow(Icons.bar_chart_rounded, "Nivel medio", "${partido["nivelMedio"]}"),
                  ]),

                  const SizedBox(height: 20),

                  // AMIGOS QUE JUGARON
                  if (amigosIds.isNotEmpty) ...[
                    _seccion("Jugadores"),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tú siempre estás
                          _jugadorChip(Session.nombre ?? "Tú", true),
                          const SizedBox(height: 8),
                          Text("+ ${amigosIds.length} amigo${amigosIds.length > 1 ? 's' : ''} invitado${amigosIds.length > 1 ? 's' : ''}",
                            style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // VALORACIÓN DE LA PISTA
                  _seccion("Valora la pista"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: cargandoValoracion
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // MEDIA GLOBAL
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    mediaValoracion.toStringAsFixed(1),
                                    style: const TextStyle(fontFamily: "Poppins", fontSize: 26, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "($totalValoraciones valoracion${totalValoraciones != 1 ? 'es' : ''})",
                                    style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 13),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),

                              Text(
                                miValoracion > 0 ? "Tu valoración:" : "¿Qué te pareció esta pista?",
                                style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 12),

                              // ESTRELLAS INTERACTIVAS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  final estrella = i + 1;
                                  return GestureDetector(
                                    onTap: () => _valorar(estrella.toDouble()),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          estrella <= miValoracion ? Icons.star_rounded : Icons.star_border_rounded,
                                          key: ValueKey('$estrella-$miValoracion'),
                                          color: estrella <= miValoracion ? const Color(0xFFFFB300) : Colors.grey.shade300,
                                          size: 42,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              if (miValoracion > 0) ...[
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    _textoValoracion(miValoracion),
                                    style: const TextStyle(color: Color(0xFFFFB300), fontFamily: "Poppins", fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _textoValoracion(double v) {
    if (v >= 5) return "¡Excelente! ⭐⭐⭐⭐⭐";
    if (v >= 4) return "Muy buena 👍";
    if (v >= 3) return "Normal 😐";
    if (v >= 2) return "Mejorable 😕";
    return "Mala experiencia 👎";
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(titulo, style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1F5DA0), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 13)),
          const Spacer(),
          Text(valor, style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF0F0F0));

  Widget _jugadorChip(String nombre, bool esTu) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : "?";
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF1F5DA0).withOpacity(0.1),
          child: Text(inicial, style: const TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Text(esTu ? "$nombre (tú)" : nombre, style: const TextStyle(fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}