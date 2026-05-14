import 'package:flutter/material.dart';
import '../service/partido_service.dart';
import 'partido_detalle_screen.dart';
import '../service/reserva_service.dart';
import '../service/amistad_service.dart';
import '../service/session.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_header.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'news_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {

  bool mostrarPerdidos = false;
  late Future<List<dynamic>> partidos;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    partidos = PartidoService.getTodosLosPartidos(Session.usuarioId!);
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }



  void recargar() {
    setState(() {
      partidos = PartidoService.getTodosLosPartidos(Session.usuarioId!);
    });
    _animController.forward(from: 0);
  }

  Map<String, dynamic> _calcularStats(List lista) {
    if (lista.isEmpty) return {
      'total': 0, 'ganados': 0, 'perdidos': 0,
      'porcentaje': 0.0, 'nivelMedio': 0.0,
      'rachaActual': 0, 'mejorRacha': 0,
    };

    final total = lista.length;
    final ganados = lista.where((p) => p['resultadoFinal'] == 'GANADO').length;
    final perdidos = total - ganados;
    final porcentaje = total > 0 ? (ganados / total * 100) : 0.0;
    final nivelMedio = lista.map((p) => (p['nivelMedio'] as num).toDouble()).reduce((a, b) => a + b) / total;

    final ordenados = List.from(lista)..sort((a, b) => DateTime.parse(b['fechaPartido']).compareTo(DateTime.parse(a['fechaPartido'])));
    int rachaActual = 0;
    for (var p in ordenados) {
      if (p['resultadoFinal'] == 'GANADO') rachaActual++;
      else break;
    }

    int mejorRacha = 0, rachaTemp = 0;
    for (var p in ordenados.reversed) {
      if (p['resultadoFinal'] == 'GANADO') {
        rachaTemp++;
        if (rachaTemp > mejorRacha) mejorRacha = rachaTemp;
      } else {
        rachaTemp = 0;
      }
    }

    return {
      'total': total, 'ganados': ganados, 'perdidos': perdidos,
      'porcentaje': porcentaje, 'nivelMedio': nivelMedio,
      'rachaActual': rachaActual, 'mejorRacha': mejorRacha,
    };
  }

  void abrirFormulario() async {
    // Cargar reservas pasadas y amigos en paralelo
    List<dynamic> reservasPasadas = [];
    List<dynamic> amigos = [];

    try {
      final resultados = await Future.wait([
        ReservaService.getReservasUsuario(Session.usuarioId!),
        AmistadService.getAmigos(),
      ]);
      final todasReservas = resultados[0] as List<dynamic>;
      // Solo reservas pasadas (ya jugadas)
      reservasPasadas = todasReservas.where((r) {
        final fecha = DateTime.parse(r["fechaReserva"]);
        return fecha.isBefore(DateTime.now());
      }).toList();
      reservasPasadas.sort((a, b) => DateTime.parse(b["fechaReserva"]).compareTo(DateTime.parse(a["fechaReserva"])));
      amigos = resultados[1] as List<dynamic>;
    } catch (e) {
      AppSnackbar.error(context, "Error cargando datos");
      return;
    }

    if (!mounted) return;

    final resultadoController = TextEditingController();
    final nivelController = TextEditingController();
    String resultadoFinal = "GANADO";
    dynamic reservaSeleccionada;
    List<dynamic> amigosSeleccionados = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            // Datos de la reserva seleccionada
            String pistaNombre = reservaSeleccionada != null
                ? reservaSeleccionada["pista"]["nombre"]
                : "";
            String clubNombre = reservaSeleccionada != null
                ? reservaSeleccionada["pista"]["club"]["nombre"]
                : "";
            DateTime? fechaReserva = reservaSeleccionada != null
                ? DateTime.parse(reservaSeleccionada["fechaReserva"])
                : null;

            return Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 28, bottom: MediaQuery.of(context).viewInsets.bottom + 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // HANDLE
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),

                    const Text("Nuevo partido", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                    const SizedBox(height: 4),
                    const Text("Selecciona una reserva y añade los detalles", style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 13)),
                    const SizedBox(height: 24),

                    // SECCIÓN 1 — SELECCIONAR RESERVA
                    Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        const Text("¿En qué reserva jugaste?", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (reservasPasadas.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Expanded(child: Text("No tienes reservas pasadas. Reserva una pista primero.", style: TextStyle(fontFamily: "Poppins", fontSize: 13, color: Colors.orange))),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: reservasPasadas.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final r = reservasPasadas[index];
                            final fecha = DateTime.parse(r["fechaReserva"]);
                            final seleccionada = reservaSeleccionada == r;
                            const meses = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"];

                            return GestureDetector(
                              onTap: () => setModalState(() => reservaSeleccionada = r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 130,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: seleccionada ? const Color(0xFF1F5DA0) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: seleccionada ? const Color(0xFF1F5DA0) : Colors.grey.shade200,
                                    width: seleccionada ? 2 : 1,
                                  ),
                                  boxShadow: seleccionada ? [BoxShadow(color: const Color(0xFF1F5DA0).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.sports_tennis, color: seleccionada ? Colors.white70 : Colors.grey.shade400, size: 18),
                                    Text(
                                      r["pista"]["nombre"],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 13, color: seleccionada ? Colors.white : Colors.black87),
                                    ),
                                    Text(
                                      "${fecha.day} ${meses[fecha.month - 1]} · ${fecha.hour}:00h",
                                      style: TextStyle(fontFamily: "Poppins", fontSize: 11, color: seleccionada ? Colors.white70 : Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // INFO RESERVA SELECCIONADA
                    if (reservaSeleccionada != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5DA0).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF1F5DA0), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "$pistaNombre · $clubNombre · ${fechaReserva!.day}/${fechaReserva.month}/${fechaReserva.year} ${fechaReserva.hour}:00h",
                                style: const TextStyle(fontFamily: "Poppins", fontSize: 12, color: Color(0xFF1F5DA0), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // SECCIÓN 2 — RESULTADO
                    Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        const Text("Resultado del partido", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: resultadoController,
                      decoration: InputDecoration(
                        labelText: "Marcador (ej: 6-2 · 1-6)",
                        prefixIcon: const Icon(Icons.scoreboard_outlined, color: Color(0xFF1F5DA0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nivelController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Nivel medio (1.0 - 10.0)",
                        prefixIcon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF1F5DA0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => resultadoFinal = "GANADO"),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: resultadoFinal == "GANADO" ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: resultadoFinal == "GANADO" ? const Color(0xFF2E7D32) : Colors.green.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.emoji_events_rounded, color: resultadoFinal == "GANADO" ? Colors.white : const Color(0xFF2E7D32), size: 24),
                                  const SizedBox(height: 4),
                                  Text("Ganado", style: TextStyle(color: resultadoFinal == "GANADO" ? Colors.white : const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => resultadoFinal = "PERDIDO"),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: resultadoFinal == "PERDIDO" ? const Color(0xFFC62828) : Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: resultadoFinal == "PERDIDO" ? const Color(0xFFC62828) : Colors.red.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.sentiment_dissatisfied_rounded, color: resultadoFinal == "PERDIDO" ? Colors.white : const Color(0xFFC62828), size: 24),
                                  const SizedBox(height: 4),
                                  Text("Perdido", style: TextStyle(color: resultadoFinal == "PERDIDO" ? Colors.white : const Color(0xFFC62828), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // SECCIÓN 3 — AMIGOS
                    if (amigos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 8),
                          const Text("¿Quién jugó contigo?", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text("Selecciona los amigos que participaron", style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 12)),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: amigos.map((amigo) {
                          final seleccionado = amigosSeleccionados.any((a) => a["id"] == amigo["id"]);
                          final inicial = (amigo["nombre"] as String)[0].toUpperCase();
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (seleccionado) {
                                  amigosSeleccionados.removeWhere((a) => a["id"] == amigo["id"]);
                                } else {
                                  amigosSeleccionados.add(amigo);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: seleccionado ? const Color(0xFF1F5DA0) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: seleccionado ? const Color(0xFF1F5DA0) : Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: seleccionado ? Colors.white.withOpacity(0.3) : const Color(0xFF1F5DA0).withOpacity(0.1),
                                    child: Text(inicial, style: TextStyle(color: seleccionado ? Colors.white : const Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    amigo["nombre"],
                                    style: TextStyle(color: seleccionado ? Colors.white : Colors.black87, fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if (seleccionado) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // BOTÓN GUARDAR
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5DA0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (reservaSeleccionada == null) {
                            AppSnackbar.aviso(context, "Selecciona la reserva en la que jugaste");
                            return;
                          }
                          if (resultadoController.text.isEmpty || nivelController.text.isEmpty) {
                            AppSnackbar.aviso(context, "Rellena el marcador y el nivel");
                            return;
                          }
                          double? nivel = double.tryParse(nivelController.text.replaceAll(",", "."));
                          if (nivel == null) { AppSnackbar.aviso(context, "El nivel no es válido"); return; }

                          final pistaId = reservaSeleccionada["pista"]["id"] as int;
                          final reservaId = reservaSeleccionada["id"] as int;
                          final fechaPartido = DateTime.parse(reservaSeleccionada["fechaReserva"]);
                          final amigosIds = amigosSeleccionados.map((a) => a["id"].toString()).join(",");

                          try {
                            bool ok = await PartidoService.registrarPartido(
                              usuarioId: Session.usuarioId!,
                              pistaId: pistaId,
                              reservaId: reservaId,
                              resultado: resultadoController.text,
                              nivelMedio: nivel,
                              resultadoFinal: resultadoFinal,
                              fechaPartido: fechaPartido,
                              amigosIds: amigosIds,
                            );
                            if (ok) {
                              Navigator.pop(context);
                              recargar();
                              AppSnackbar.exito(context, "Partido registrado correctamente ✓");
                            }
                          } catch (e) {
                            AppSnackbar.error(context, e.toString().replaceAll("Exception: ", ""));
                          }
                        },
                        child: const Text("Guardar partido", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1F5DA0),
        onPressed: abrirFormulario,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Registrar", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NewsScreen()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "INICIO"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: "PARTIDOS"),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: "NOTICIAS"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "PERFIL"),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              AppHeader(
                fotoUrl: Session.fotoUrl,
                titulo: "Tus partidos",
                extra: GestureDetector(
                  onTap: () => setState(() => mostrarPerdidos = !mostrarPerdidos),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _toggleChip("Solo ganados", !mostrarPerdidos),
                        _toggleChip("Todos", mostrarPerdidos),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: partidos,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)));

                    final todos = snapshot.data!;
                    final stats = _calcularStats(todos);
                    List lista = mostrarPerdidos ? todos : todos.where((p) => p["resultadoFinal"] == "GANADO").toList();

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (todos.isNotEmpty) ...[
                                  _heroCard(stats),
                                  const SizedBox(height: 16),
                                  _statsRow(stats),
                                  const SizedBox(height: 24),
                                ],
                                Row(
                                  children: [
                                    Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(width: 8),
                                    const Text("Historial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                                    const Spacer(),
                                    Text("${lista.length} partidos", style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),

                        if (lista.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: Icon(Icons.sports_tennis, size: 48, color: Colors.grey.shade400)),
                                  const SizedBox(height: 16),
                                  Text(mostrarPerdidos ? "No hay partidos registrados" : "No hay partidos ganados", style: TextStyle(color: Colors.grey.shade500, fontFamily: "Poppins", fontSize: 15)),
                                  const SizedBox(height: 8),
                                  Text("Pulsa + para registrar uno", style: TextStyle(color: Colors.grey.shade400, fontFamily: "Poppins", fontSize: 13)),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => PartidoDetalleScreen(partido: lista[index])),
                                    ),
                                    child: _matchCard(lista[index], index),
                                  ),
                                ),
                                childCount: lista.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard(Map<String, dynamic> stats) {
    final ganados = stats['ganados'] as int;
    final total = stats['total'] as int;
    final porcentaje = stats['porcentaje'] as double;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A4F8A), Color(0xFF1F5DA0), Color(0xFF2874C8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1F5DA0).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
          Positioned(right: 30, bottom: -30, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: const Text("Rendimiento global", style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: 12))),
                    const Spacer(),
                    const Icon(Icons.insights_rounded, color: Colors.white54, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${porcentaje.toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 52, fontWeight: FontWeight.bold, height: 1)),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("victorias", style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: 14)),
                          Text("$ganados de $total partidos", style: const TextStyle(color: Colors.white54, fontFamily: "Poppins", fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4))),
                    FractionallySizedBox(
                      widthFactor: total > 0 ? ganados / total : 0,
                      child: Container(height: 8, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.white, Color(0xFFB3D1FF)]), borderRadius: BorderRadius.circular(4))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniChip("✅ ${stats['ganados']} ganados"),
                    const SizedBox(width: 8),
                    _miniChip("❌ ${stats['perdidos']} perdidos"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(texto, style: const TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statsRow(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(child: _statTile(Icons.local_fire_department_rounded, "Racha", "${stats['rachaActual']} 🔥", Colors.deepOrange)),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.emoji_events_rounded, "Mejor racha", "${stats['mejorRacha']} 🏆", const Color(0xFFE8A000))),
        const SizedBox(width: 10),
        Expanded(child: _statTile(Icons.bar_chart_rounded, "Nivel", stats['nivelMedio'].toStringAsFixed(1), const Color(0xFF1F5DA0))),
      ],
    );
  }

  Widget _statTile(IconData icon, String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(color: color, fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 11)),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool activo) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: activo ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: activo ? const Color(0xFF1F5DA0) : Colors.white70, fontFamily: "Poppins", fontWeight: activo ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
    );
  }

  Widget _matchCard(dynamic partido, int index) {
    final bool ganado = partido["resultadoFinal"] == "GANADO";
    final Color color = ganado ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final Color bgColor = ganado ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    DateTime fecha = DateTime.parse(partido["fechaPartido"]);
    const meses = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"];
    final bool vinculado = partido["reservaVinculada"] == true;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(width: 5, height: 90, color: color),
              Container(
                width: 56, height: 90, color: bgColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${fecha.day}", style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Poppins", height: 1)),
                    Text(meses[fecha.month - 1], style: TextStyle(color: color.withOpacity(0.7), fontSize: 10, fontFamily: "Poppins", fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(partido["resultado"], style: TextStyle(color: color, fontSize: 20, fontFamily: "Poppins", fontWeight: FontWeight.bold, height: 1.1)),
                          if (vinculado) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF1F5DA0).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: const Text("✓ Verificado", style: TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Expanded(child: Text("${partido["club"]}", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade500, fontFamily: "Poppins", fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Text("Nivel ${partido["nivelMedio"]}", style: TextStyle(color: Colors.grey.shade500, fontFamily: "Poppins", fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(ganado ? "WIN" : "LOSS", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: "Poppins", fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}