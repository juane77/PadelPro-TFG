import 'package:flutter/material.dart';
import '../service/partido_service.dart';
import '../service/api_service.dart';
import '../service/session.dart';
import '../models/pista.dart';
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

  /// ABRIR FORMULARIO PARA REGISTRAR PARTIDO
  void abrirFormulario() async {

    // Primero cargamos las pistas disponibles
    List<Pista> pistas = [];
    try {
      pistas = await ApiService.getPistas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error cargando pistas")),
      );
      return;
    }

    if (!mounted) return;

    // Controllers del formulario
    final resultadoController = TextEditingController();
    final nivelController = TextEditingController();
    String resultadoFinal = "GANADO";
    Pista? pistaSeleccionada;
    DateTime fechaSeleccionada = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Text(
                      "Registrar partido",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PISTA
                    DropdownButtonFormField<Pista>(
                      decoration: InputDecoration(
                        labelText: "Pista",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: pistas.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text("${p.nombre} - ${p.clubNombre}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          pistaSeleccionada = value;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    // RESULTADO (ej: 6-2 · 1-6 · 7-6)
                    TextField(
                      controller: resultadoController,
                      decoration: InputDecoration(
                        labelText: "Resultado (ej: 6-2 · 1-6)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // NIVEL MEDIO
                    TextField(
                      controller: nivelController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Nivel medio (1.0 - 10.0)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // GANADO / PERDIDO
                    Row(
                      children: [
                        const Text(
                          "Resultado:",
                          style: TextStyle(fontFamily: "Poppins"),
                        ),
                        const SizedBox(width: 15),
                        ChoiceChip(
                          label: const Text("Ganado"),
                          selected: resultadoFinal == "GANADO",
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: resultadoFinal == "GANADO"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              resultadoFinal = "GANADO";
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text("Perdido"),
                          selected: resultadoFinal == "PERDIDO",
                          selectedColor: Colors.red,
                          labelStyle: TextStyle(
                            color: resultadoFinal == "PERDIDO"
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              resultadoFinal = "PERDIDO";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

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
                          setModalState(() {
                            fechaSeleccionada = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                          style: const TextStyle(fontFamily: "Poppins"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BOTÓN GUARDAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5DA0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {

                          if (pistaSeleccionada == null ||
                              resultadoController.text.isEmpty ||
                              nivelController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Rellena todos los campos")),
                            );
                            return;
                          }

                          double? nivel = double.tryParse(
                              nivelController.text.replaceAll(",", "."));

                          if (nivel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("El nivel medio no es válido")),
                            );
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text("Partido registrado correctamente")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceAll("Exception: ", ""))),
                            );
                          }
                        },
                        child: const Text(
                          "Guardar partido",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F5DA0),
        onPressed: abrirFormulario,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {

          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
          if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const NewsScreen()));
          }
          if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "INICIO"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis), label: "PARTIDOS"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "NOTICIAS"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "PERFIL"),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              height: 100,
              color: const Color(0xFF1F5DA0),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                "PadelPro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: "Poppins",
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "TUS PARTIDOS",
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text(
                        "Mostrar partidos perdidos",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: mostrarPerdidos,
                        activeColor: const Color(0xFF1F5DA0),
                        onChanged: (value) {
                          setState(() {
                            mostrarPerdidos = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<dynamic>>(

                future: partidos,

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List lista = snapshot.data!;

                  if (!mostrarPerdidos) {
                    lista = lista
                        .where((p) => p["resultadoFinal"] == "GANADO")
                        .toList();
                  }

                  if (lista.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay partidos registrados",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "Poppins",
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lista.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return matchCard(lista[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget matchCard(dynamic partido) {

    final bool ganado = partido["resultadoFinal"] == "GANADO";
    final Color scoreColor = ganado ? Colors.green : Colors.red;

    DateTime fecha = DateTime.parse(partido["fechaPartido"]);
    String fechaStr = "${fecha.day}/${fecha.month}/${fecha.year}";

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                partido["resultado"],
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 24,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "Nivel medio: ${partido["nivelMedio"]}",
                style: const TextStyle(fontFamily: "Poppins"),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                partido["club"],
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [

              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(fechaStr, style: const TextStyle(fontFamily: "Poppins")),

              const SizedBox(width: 16),

              const Icon(Icons.sports_tennis, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                partido["pista"],
                style: const TextStyle(fontFamily: "Poppins"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ganado
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ganado ? "GANADO" : "PERDIDO",
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}