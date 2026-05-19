import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../models/pista.dart';
import '../utils/responsive.dart';
import 'pista_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final ciudadController = TextEditingController();
  final precioController = TextEditingController();

  String? tipoSeleccionado; // null = todos, "Cubierta", "Exterior"
  List<Pista> resultados = [];
  bool cargando = false;
  bool buscado = false;
  int _limite = 20;

  void buscar() async {
    setState(() {
      cargando = true;
      buscado = true;
    });

    final ciudad = ciudadController.text.trim();
    double? precioMax;
    if (precioController.text.isNotEmpty) {
      precioMax = double.tryParse(precioController.text.replaceAll(",", "."));
    }

    final pistas = await ApiService.buscarPistas(
      ciudad: ciudad,
      tipo: tipoSeleccionado,
      precioMax: precioMax,
    );

    setState(() {
      resultados = pistas;
      cargando = false;
      _limite = 20;
    });
  }

  void limpiar() {
    ciudadController.clear();
    precioController.clear();
    setState(() {
      tipoSeleccionado = null;
      resultados = [];
      buscado = false;
      _limite = 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        title: Text(
          "Buscar pistas",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18)),
        ),
        actions: [
          if (buscado)
            TextButton(
              onPressed: limpiar,
              child: Text(
                "Limpiar",
                style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: Responsive.font(13)),
              ),
            ),
        ],
      ),

      body: Column(
        children: [

          // FILTROS
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(Responsive.padding(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Filtros de búsqueda",
                  style: TextStyle(
                    fontSize: Responsive.font(16),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: Color(0xFF1F5DA0),
                  ),
                ),

                SizedBox(height: Responsive.h(2.5)),

                // CIUDAD
                TextField(
                  controller: ciudadController,
                  decoration: InputDecoration(
                    labelText: "Ciudad",
                    hintText: "Ej: Madrid, Barcelona...",
                    prefixIcon: const Icon(Icons.location_city, color: Color(0xFF1F5DA0)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2),
                    ),
                  ),
                ),

                SizedBox(height: Responsive.h(2)),

                // TIPO — SELECTOR CON CHIPS
                Text(
                  "Tipo de pista",
                  style: TextStyle(
                    fontSize: Responsive.font(13),
                    color: Colors.grey,
                    fontFamily: "Poppins",
                  ),
                ),

                SizedBox(height: Responsive.h(1.2)),

                Row(
                  children: [

                    // TODAS
                    _tipoChip(
                      label: "Todas",
                      icono: Icons.grid_view,
                      seleccionado: tipoSeleccionado == null,
                      onTap: () => setState(() => tipoSeleccionado = null),
                    ),

                    const SizedBox(width: 10),

                    // CUBIERTA
                    _tipoChip(
                      label: "Cubierta",
                      icono: Icons.house,
                      seleccionado: tipoSeleccionado == "Cubierta",
                      onTap: () => setState(() => tipoSeleccionado = "Cubierta"),
                    ),

                    const SizedBox(width: 10),

                    // EXTERIOR
                    _tipoChip(
                      label: "Exterior",
                      icono: Icons.wb_sunny,
                      seleccionado: tipoSeleccionado == "Exterior",
                      onTap: () => setState(() => tipoSeleccionado = "Exterior"),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.h(2)),

                // PRECIO MÁXIMO
                TextField(
                  controller: precioController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Precio máximo por hora",
                    hintText: "Ej: 12",
                    prefixIcon: const Icon(Icons.euro, color: Color(0xFF1F5DA0)),
                    suffixText: "€/h",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2),
                    ),
                  ),
                ),

                SizedBox(height: Responsive.h(2.5)),

                // BOTÓN BUSCAR
                SizedBox(
                  width: double.infinity,
                  height: Responsive.h(7),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5DA0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: buscar,
                    icon: const Icon(Icons.search),
                    label: Text(
                      "Buscar pistas",
                      style: TextStyle(
                        fontSize: Responsive.font(16),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.h(1.2)),

          // RESULTADOS
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : !buscado
                ? _estadoInicial()
                : resultados.isEmpty
                ? _sinResultados()
                : _listaResultados(),
          ),
        ],
      ),
    );
  }

  Widget _tipoChip({
    required String label,
    required IconData icono,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: Responsive.padding(14), vertical: Responsive.padding(8)),
        decoration: BoxDecoration(
          color: seleccionado
              ? const Color(0xFF1F5DA0)
              : const Color(0xFF1F5DA0).withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: seleccionado
                ? const Color(0xFF1F5DA0)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              size: Responsive.font(16),
              color: seleccionado ? Colors.white : const Color(0xFF1F5DA0),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? Colors.white : const Color(0xFF1F5DA0),
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                fontSize: Responsive.font(13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoInicial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: Responsive.imageSize(70), color: Colors.grey.shade300),
          SizedBox(height: Responsive.h(2.5)),
          Text(
            "Usa los filtros para\nencontrar tu pista ideal",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: Responsive.font(16),
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_tennis, size: Responsive.imageSize(70), color: Colors.grey.shade300),
          SizedBox(height: Responsive.h(2.5)),
          Text(
            "No hay pistas disponibles\ncon estos filtros",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: Responsive.font(16),
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  Widget _listaResultados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20), vertical: Responsive.padding(10)),
          child: Text(
            "${resultados.length} pista${resultados.length != 1 ? 's' : ''} encontrada${resultados.length != 1 ? 's' : ''}",
            style: TextStyle(
              color: Colors.grey,
              fontFamily: "Poppins",
              fontSize: Responsive.font(13),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: Responsive.padding(16)),
            itemCount: resultados.take(_limite).length + (resultados.length > _limite ? 1 : 0),
            itemBuilder: (context, index) {
              final visibles = resultados.take(_limite).toList();

              if (index == visibles.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(1.2)),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5DA0),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: Responsive.padding(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => setState(() => _limite += 20),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: Text(
                      "Mostrar más (${resultados.length - _limite} restantes)",
                      style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(13)),
                    ),
                  ),
                );
              }

              final pista = visibles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PistaDetailScreen(pista: pista),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: Responsive.h(1.8)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Image.asset(
                          pista.tipo.toLowerCase().contains("cubierta")
                              ? "assets/images/pista_cubierta.png"
                              : "assets/images/pista_descubierta.png",
                          width: Responsive.imageSize(95),
                          height: Responsive.imageSize(85),
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(width: Responsive.w(3.5)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              pista.nombre,
                              style: TextStyle(
                                fontSize: Responsive.font(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),

                            SizedBox(height: Responsive.h(0.6)),

                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 13, color: Colors.grey),
                                const SizedBox(width: 3),
                                Text(
                                  pista.ciudad,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: Responsive.font(12),
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: Responsive.h(0.9)),

                            Row(
                              children: [

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: pista.tipo.toLowerCase().contains("cubierta")
                                        ? const Color(0xFF1F5DA0).withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    pista.tipo,
                                    style: TextStyle(
                                      fontSize: Responsive.font(11),
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                      color: pista.tipo.toLowerCase().contains("cubierta")
                                          ? const Color(0xFF1F5DA0)
                                          : Colors.green,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  "${pista.precioHora}€/h",
                                  style: TextStyle(
                                    color: Color(0xFF1F5DA0),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins",
                                    fontSize: Responsive.font(14),
                                  ),
                                ),

                                const SizedBox(width: 12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}