import 'package:flutter/material.dart';
import '../service/partido_service.dart';
import '../service/api_service.dart';
import '../service/session.dart';
import '../models/pista.dart';
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

class _MatchesScreenState extends State<MatchesScreen> {

  bool mostrarPerdidos = false;
  late Future<List<dynamic>> partidos;

  @override
  void initState() {
    super.initState();
    partidos = PartidoService.getPartidosUsuario(Session.usuarioId!);
  }

  void recargar() {
    setState(() {
      partidos = PartidoService.getPartidosUsuario(Session.usuarioId!);
    });
  }

  void abrirFormulario() async {
    List<Pista> pistas = [];
    try {
      pistas = await ApiService.getPistas();
    } catch (e) {
      AppSnackbar.error(context, "Error cargando pistas");
      return;
    }

    if (!mounted) return;

    final resultadoController = TextEditingController();
    final nivelController = TextEditingController();
    String resultadoFinal = "GANADO";
    Pista? pistaSeleccionada;
    DateTime fechaSeleccionada = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 28,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // HANDLE
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const Text(
                      "Registrar partido",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      "Añade los datos de tu partido",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins",
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PISTA
                    DropdownButtonFormField<Pista>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Pista",
                        prefixIcon: const Icon(Icons.sports_tennis, color: Color(0xFF1F5DA0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2),
                        ),
                      ),
                      items: pistas.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setModalState(() => pistaSeleccionada = value),
                    ),

                    const SizedBox(height: 16),

                    // RESULTADO
                    TextField(
                      controller: resultadoController,
                      decoration: InputDecoration(
                        labelText: "Resultado (ej: 6-2 · 1-6)",
                        prefixIcon: const Icon(Icons.scoreboard_outlined, color: Color(0xFF1F5DA0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NIVEL
                    TextField(
                      controller: nivelController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Nivel medio (1.0 - 10.0)",
                        prefixIcon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF1F5DA0)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // GANADO / PERDIDO
                    const Text(
                      "¿Cómo quedó?",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => resultadoFinal = "GANADO"),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: resultadoFinal == "GANADO"
                                    ? Colors.green
                                    : Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: resultadoFinal == "GANADO"
                                      ? Colors.green
                                      : Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_events_rounded,
                                    color: resultadoFinal == "GANADO" ? Colors.white : Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Ganado",
                                    style: TextStyle(
                                      color: resultadoFinal == "GANADO" ? Colors.white : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: resultadoFinal == "PERDIDO"
                                    ? Colors.red
                                    : Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: resultadoFinal == "PERDIDO"
                                      ? Colors.red
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sentiment_dissatisfied_rounded,
                                    color: resultadoFinal == "PERDIDO" ? Colors.white : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Perdido",
                                    style: TextStyle(
                                      color: resultadoFinal == "PERDIDO" ? Colors.white : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // FECHA
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => fechaSeleccionada = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFF1F5DA0), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                              style: const TextStyle(fontFamily: "Poppins", fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // BOTÓN GUARDAR
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5DA0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (pistaSeleccionada == null ||
                              resultadoController.text.isEmpty ||
                              nivelController.text.isEmpty) {
                            AppSnackbar.aviso(context, "Rellena todos los campos");
                            return;
                          }

                          double? nivel = double.tryParse(nivelController.text.replaceAll(",", "."));
                          if (nivel == null) {
                            AppSnackbar.aviso(context, "El nivel medio no es válido");
                            return;
                          }

                          try {
                            bool ok = await PartidoService.registrarPartido(
                              usuarioId: Session.usuarioId!,
                              pistaId: pistaSeleccionada!.id,
                              resultado: resultadoController.text,
                              nivelMedio: nivel,
                              resultadoFinal: resultadoFinal,
                              fechaPartido: fechaSeleccionada,
                            );
                            if (ok) {
                              Navigator.pop(context);
                              recargar();
                              AppSnackbar.exito(context, "Partido registrado correctamente");
                            }
                          } catch (e) {
                            AppSnackbar.error(context, e.toString().replaceAll("Exception: ", ""));
                          }
                        },
                        child: const Text(
                          "Guardar partido",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),
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
      backgroundColor: const Color(0xFFF7F8FA),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1F5DA0),
        onPressed: abrirFormulario,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Registrar",
          style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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
        child: Column(
          children: [

            AppHeader(
              titulo: "Tus partidos",
              
              extra: GestureDetector(
                onTap: () => setState(() => mostrarPerdidos = !mostrarPerdidos),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
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

            // LISTA
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: partidos,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)));
                  }

                  List lista = snapshot.data!;
                  if (!mostrarPerdidos) {
                    lista = lista.where((p) => p["resultadoFinal"] == "GANADO").toList();
                  }

                  if (lista.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_tennis, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            mostrarPerdidos
                                ? "No hay partidos registrados"
                                : "No hay partidos ganados",
                            style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    itemCount: lista.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _matchCard(lista[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleChip(String label, bool activo) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: activo ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: activo ? const Color(0xFF1F5DA0) : Colors.white70,
          fontFamily: "Poppins",
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _matchCard(dynamic partido) {
    final bool ganado = partido["resultadoFinal"] == "GANADO";
    final Color color = ganado ? Colors.green : Colors.red;
    DateTime fecha = DateTime.parse(partido["fechaPartido"]);

    const meses = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            // BLOQUE FECHA
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "${fecha.day}",
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  Text(
                    meses[fecha.month - 1],
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partido["resultado"],
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          "${partido["club"]} · ${partido["pista"]}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        "Nivel medio: ${partido["nivelMedio"]}",
                        style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ganado ? "WIN" : "LOSS",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}