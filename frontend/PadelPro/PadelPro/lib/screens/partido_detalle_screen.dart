import 'package:flutter/material.dart';
import '../service/valoracion_service.dart';
import '../service/session.dart';
import '../utils/responsive.dart';
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
    Responsive.init(context);
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
        title: Text("Detalle del partido", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18))),
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
              padding: EdgeInsets.fromLTRB(Responsive.padding(24), Responsive.padding(28), Responsive.padding(24), Responsive.padding(32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(5)),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(ganado ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded, color: Colors.white, size: Responsive.font(14)),
                            SizedBox(width: Responsive.w(1)),
                            Text(ganado ? "GANADO" : "PERDIDO", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(12))),
                          ],
                        ),
                      ),
                      if (verificado) ...[
                        SizedBox(width: Responsive.w(2)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(5)),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                              SizedBox(width: Responsive.w(1)),
                              Text("Verificado", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(12))),
                            ],
                          ),
                        ),
                      ],
                      if (esInvitado) ...[
                        SizedBox(width: Responsive.w(2)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(5)),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.people_rounded, color: Colors.white, size: 14),
                              SizedBox(width: Responsive.w(1)),
                              Text("Invitado", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(12))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: Responsive.h(3)),

                  Text(
                    partido["resultado"],
                    style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: Responsive.font(44), fontWeight: FontWeight.bold, height: 1),
                  ),

                  SizedBox(height: Responsive.h(1.2)),

                  Text(
                    "${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year} · ${fecha.hour}:00h",
                    style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: Responsive.font(14)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(Responsive.padding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _seccion("Pista y club"),
                  _infoCard([
                    _infoRow(Icons.sports_tennis, "Pista", partido["pista"]),
                    _divider(),
                    _infoRow(Icons.location_city_rounded, "Club", partido["club"]),
                    _divider(),
                    _infoRow(Icons.bar_chart_rounded, "Nivel medio", "${partido["nivelMedio"]}"),
                  ]),

                  SizedBox(height: Responsive.h(3)),

                  if (amigosIds.isNotEmpty) ...[
                    _seccion("Jugadores"),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Responsive.padding(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _jugadorChip(Session.nombre ?? "Tú", true),
                          SizedBox(height: Responsive.h(1.2)),
                          Text("+ ${amigosIds.length} amigo${amigosIds.length > 1 ? 's' : ''} invitado${amigosIds.length > 1 ? 's' : ''}",
                            style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(13))),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.h(3)),
                  ],

                  _seccion("Valora la pista"),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Responsive.padding(20)),
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

                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    mediaValoracion.toStringAsFixed(1),
                                    style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(26), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "($totalValoraciones valoracion${totalValoraciones != 1 ? 'es' : ''})",
                                    style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(13)),
                                  ),
                                ],
                              ),

                              SizedBox(height: Responsive.h(2.5)),
                              const Divider(),
                              SizedBox(height: Responsive.h(1.8)),

                              Text(
                                miValoracion > 0 ? "Tu valoración:" : "¿Qué te pareció esta pista?",
                                style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(14)),
                              ),
                              SizedBox(height: Responsive.h(1.8)),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  final estrella = i + 1;
                                  return GestureDetector(
                                    onTap: () => _valorar(estrella.toDouble()),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: Responsive.padding(6)),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          estrella <= miValoracion ? Icons.star_rounded : Icons.star_border_rounded,
                                          key: ValueKey('$estrella-$miValoracion'),
                                          color: estrella <= miValoracion ? const Color(0xFFFFB300) : Colors.grey.shade300,
                                          size: Responsive.imageSize(42),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              if (miValoracion > 0) ...[
                                SizedBox(height: Responsive.h(1.8)),
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

                  SizedBox(height: Responsive.h(4.5)),
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
      padding: EdgeInsets.only(bottom: Responsive.h(1.5)),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(titulo, style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(16))),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Responsive.padding(16), vertical: Responsive.padding(8)),
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
      padding: EdgeInsets.symmetric(vertical: Responsive.h(1.8)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1F5DA0), size: 20),
          SizedBox(width: Responsive.w(3)),
          Text(label, style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(13))),
          const Spacer(),
          Text(valor, style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(14))),
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
          radius: Responsive.imageSize(16),
          backgroundColor: const Color(0xFF1F5DA0).withOpacity(0.1),
          child: Text(inicial, style: TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(13))),
        ),
        SizedBox(width: Responsive.w(2.5)),
        Text(esTu ? "$nombre (tú)" : nombre, style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(14), fontWeight: FontWeight.w500)),
      ],
    );
  }
}