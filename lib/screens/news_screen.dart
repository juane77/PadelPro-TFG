import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  Future<void> abrirWeb() async {
    final Uri url = Uri.parse("https://www.padelspain.net/");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("No se pudo abrir la web");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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

          if(index == 1){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchesScreen(),
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                children: [

                  const SizedBox(height: 10),

                  const Text(
                    "NOTICIAS",
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// NOTICIA PRINCIPAL
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/Image4.png",
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "La nueva dupla que apunta a romper records.",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5DA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: abrirWeb,
                    child: const Text(
                      "MAS INFORMACION",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// NOTICIA SECUNDARIA
                  Row(
                    children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/images/Image5.png",
                          width: 150,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Garrido sigue sumando puestos en solitario",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F5DA0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: abrirWeb,
                              child: const Text(
                                "MAS INFORMACION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "La salud y el mal tiempo acaban con Veracruz",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5DA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: abrirWeb,
                    child: const Text(
                      "MAS INFORMACION",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Divider(),

                  const SizedBox(height: 10),

                  const Text(
                    "Lo más leído",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/images/Image6.png",
                          width: 150,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 15),

                      const Expanded(
                        child: Text(
                          "Coello y Tapia siguen su ritmo aplastante y consolidan el top 1",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Color(0xFF1F5DA0),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}