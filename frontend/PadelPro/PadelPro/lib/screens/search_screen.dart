import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../models/pista.dart';
import 'pista_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final ciudadController = TextEditingController();
  final tipoController = TextEditingController();
  final precioController = TextEditingController();

  List<Pista> resultados = [];
  bool cargando = false;

  /// FUNCIÓN BUSCAR
  void buscar() async {

    setState(() {
      cargando = true;
    });

    final ciudad = ciudadController.text;
    final tipo = tipoController.text;
    final precio = precioController.text;

    double? precioMax;

    if(precio.isNotEmpty){
      precioMax = double.parse(precio);
    }

    final pistas = await ApiService.buscarPistas(
      ciudad: ciudad,
      tipo: tipo,
      precioMax: precioMax,
    );

    setState(() {
      resultados = pistas;
      cargando = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        title: const Text("Buscar pistas"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            /// CIUDAD
            TextField(
              controller: ciudadController,

              decoration: InputDecoration(
                labelText: "Ciudad",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// TIPO
            TextField(
              controller: tipoController,

              decoration: InputDecoration(
                labelText: "Tipo pista (INDOOR / OUTDOOR)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// PRECIO
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                labelText: "Precio máximo",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// BOTÓN BUSCAR
            ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F5DA0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              onPressed: buscar,

              child: const Text(
                "Buscar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// CARGANDO
            if(cargando)
              const CircularProgressIndicator(),

            /// RESULTADOS
            if(resultados.isNotEmpty)
              Expanded(
                child: ListView.builder(

                  itemCount: resultados.length,

                  itemBuilder: (context, index){

                    final pista = resultados[index];

                    return GestureDetector(

                      onTap: (){

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PistaDetailScreen(pista: pista),
                          ),
                        );

                      },

                      child: Container(

                        margin: const EdgeInsets.only(bottom: 15),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),

                        child: Row(

                          children: [

                            /// IMAGEN
                            ClipRRect(

                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                              ),

                              child: Image.asset(
                                "assets/images/Basica1.png",
                                width: 95,
                                height: 85,
                                fit: BoxFit.cover,
                              ),

                            ),

                            const SizedBox(width: 15),

                            /// TEXTO
                            Expanded(

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    pista.nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "${pista.ciudad} • ${pista.precioHora}€/h",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Poppins",
                                    ),
                                  ),

                                ],

                              ),

                            ),

                            /// FLECHA
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_forward_ios, size: 16),
                            ),

                          ],

                        ),

                      ),

                    );

                  },
                ),
              ),

          ],
        ),
      ),
    );
  }
}