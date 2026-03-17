import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {

          if(index == 0){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
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

            Container(
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                children: [

                  matchCard(
                    "6-2 · 1-6 · 7-6",
                    "Atocha Padel Club",
                    "Hoy, 5:00 pm",
                    "Pista Security",
                    "Nivel medio: 3.5",
                    Colors.green,
                  ),

                  const SizedBox(height: 20),

                  matchCard(
                    "6-0 · 6-1",
                    "Maguilla Club",
                    "1 oct, 2025",
                    "Pista Polideportivo",
                    "Nivel medio: 2.9",
                    Colors.green,
                  ),

                  const SizedBox(height: 20),

                  if(mostrarPerdidos) ...[

                    matchCard(
                      "6-4 · 1-6 · 3-6",
                      "Es+Padel Merida",
                      "12 nov, 2025",
                      "Pista Babolat",
                      "Nivel medio: 4.6",
                      Colors.red,
                    ),

                    const SizedBox(height: 20),

                    matchCard(
                      "0-6 · 5-7",
                      "World Padel Tour",
                      "15 ene, 2025",
                      "Pista Babolat",
                      "Nivel medio: 4.6",
                      Colors.red,
                    ),

                    const SizedBox(height: 30),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget matchCard(
      String score,
      String club,
      String date,
      String court,
      String level,
      Color scoreColor,
      ) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0,4),
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
                score,
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 26,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                level,
                style: const TextStyle(fontFamily: "Poppins"),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      club,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(date,
                        style: const TextStyle(fontFamily: "Poppins")),

                    const SizedBox(height: 5),

                    Text(court,
                        style: const TextStyle(fontFamily: "Poppins")),
                  ],
                ),
              ),

              Column(
                children: [

                  Row(
                    children: const [
                      CircleAvatar(radius: 14),
                      SizedBox(width: 6),
                      CircleAvatar(radius: 14),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text("VS"),
                  ),

                  Row(
                    children: const [
                      CircleAvatar(radius: 14),
                      SizedBox(width: 6),
                      CircleAvatar(radius: 14),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}