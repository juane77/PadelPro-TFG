import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../service/reserva_service.dart';
import '../models/pista.dart';
import 'pista_detail_screen.dart';
import 'search_screen.dart';
import 'matches_screen.dart';
import 'news_screen.dart';
import 'mis_reservas_screen.dart';
import 'profile_screen.dart';
import 'profile_screen.dart';
import '../service/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<Pista>> pistas;

  @override
  void initState() {
    super.initState();
    pistas = ApiService.getPistas();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {

          if(index == 1){

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchesScreen(),
              ),
            );

          }

          if(index == 2){

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NewsScreen(),
              ),
            );

          }

          if(index == 3){

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );

          }

        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "INICIO",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: "PARTIDOS",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "NOTICIAS",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "PERFIL",
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// HEADER
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const SizedBox(height: 20),

                    const Text(
                      "INICIO",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    searchBar(context),

                    const SizedBox(height: 30),

                    const Text(
                      "Partidos previstos",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    partidosPrevistos(),

                    const SizedBox(height: 5),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const MisReservasScreen(),
                            ),
                          ).then((_) {
                            setState(() {});
                          });

                        },

                        child: const Text(
                          "Ver otras reservas",
                          style: TextStyle(
                            color: Color(0xFF1F5DA0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Pistas recomendadas",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    FutureBuilder<List<Pista>>(

                      future: pistas,

                      builder: (context, snapshot) {

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {

                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text("No hay pistas disponibles");
                        }

                        final lista = snapshot.data!.take(2).toList();

                        return Column(
                          children: lista.map((pista) {
                            return pistaItem(pista);
                          }).toList(),
                        );

                      },

                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PARTIDO MÁS CERCANO
  Widget partidosPrevistos(){

    return FutureBuilder(

        future: ReservaService.getReservasUsuario(Session.usuarioId!),

      builder: (context, snapshot) {

        if(!snapshot.hasData){
          return const Center(child: CircularProgressIndicator());
        }

        List reservas = snapshot.data!
            .where((r) => r["estado"] == "ACTIVA")
            .toList();

        if(reservas.isEmpty){
          return const Text("No tienes reservas todavía");
        }

        reservas.sort((a,b){
          return DateTime.parse(a["fechaReserva"])
              .compareTo(DateTime.parse(b["fechaReserva"]));
        });

        final reserva = reservas.first;

        DateTime fecha =
        DateTime.parse(reserva["fechaReserva"]);

        return Container(
          width: double.infinity,
          height: 160,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            image: const DecorationImage(
              image: AssetImage("assets/images/image3.png"),
              fit: BoxFit.cover,
            ),
          ),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Text(
                reserva["pista"]["nombre"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                reserva["pista"]["club"]["nombre"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "${fecha.day}/${fecha.month} - ${fecha.hour}:00",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

            ],
          ),
        );

      },
    );
  }

  /// BUSCADOR
  Widget searchBar(BuildContext context) {

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );

      },

      child: Container(

        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),

        decoration: BoxDecoration(
          color: const Color(0xFF1F5DA0),
          borderRadius: BorderRadius.circular(16),
        ),

        child: const Row(

          children: [

            Expanded(
              child: Text(
                "Buscar...",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
              ),
            ),

            Icon(
              Icons.search,
              color: Colors.white,
            ),

          ],
        ),
      ),
    );
  }

  /// PISTA RECOMENDADA (DISEÑO IGUAL QUE BUSCAR)
  Widget pistaItem(Pista pista){

    return GestureDetector(

      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PistaDetailScreen(pista: pista),
          ),
        );
      },

      child: Container(

        margin: const EdgeInsets.only(bottom: 16),

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

            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 16),
            ),

          ],
        ),
      ),
    );
  }
}