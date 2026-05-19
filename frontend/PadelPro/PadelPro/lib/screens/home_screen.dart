import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../service/reserva_provider.dart';
import '../service/api_service.dart';
import '../models/pista.dart';
import '../service/session.dart';
import '../widgets/app_header.dart';
import '../utils/responsive.dart';
import 'pista_detail_screen.dart';
import 'search_screen.dart';
import 'matches_screen.dart';
import 'news_screen.dart';
import 'mis_reservas_screen.dart';
import 'profile_screen.dart';
import 'mapa_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<Pista>> pistas;
  Position? _posicion;

  double _distancia(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  @override
  void initState() {
    super.initState();
    pistas = ApiService.getPistas();
    _obtenerubicacion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservaProvider>().cargarReservas();
      // DEBUG: comprobar si image3.png carga correctamente
      final ImageStream stream = const AssetImage("assets/images/image3.png")
          .resolve(ImageConfiguration.empty);
      stream.addListener(ImageStreamListener(
        (info, _) => print("✅ image3.png cargada correctamente"),
        onError: (error, stack) => print("❌ ERROR cargando image3.png: \$error"),
      ));
    });
  }


  Future<void> _obtenerubicacion() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 8));
      setState(() => _posicion = pos);
    } catch (_) {
      // Si no obtiene ubicación muestra las pistas sin ordenar
    }
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return "Buenos días";
    if (hora < 20) return "Buenas tardes";
    return "Buenas noches";
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        onTap: (index) {
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MatchesScreen()));
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
              fotoUrl: Session.fotoUrl,
              titulo: "${_saludo()}, ${Session.nombre ?? ""} 👋",
              extra: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(16)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.white70, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Buscar pistas, clubes...",
                        style: TextStyle(
                          color: Colors.white60,
                          fontFamily: "Poppins",
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: Responsive.h(3.5)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Próxima reserva",
                          style: TextStyle(
                            fontSize: Responsive.font(20),
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MisReservasScreen()),
                            );
                          },
                          child: Text(
                            "Ver todas",
                            style: TextStyle(
                              color: Color(0xFF1F5DA0),
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.font(13),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.h(1.8)),

                    _proximaReserva(),

                    SizedBox(height: Responsive.h(4)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pistas recomendadas",
                          style: TextStyle(
                            fontSize: Responsive.font(20),
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapaScreen()),
                          ),
                          icon: Icon(Icons.map_rounded, size: Responsive.font(16), color: const Color(0xFF1F5DA0)),
                          label: Text(
                            "Ver mapa",
                            style: TextStyle(
                              color: Color(0xFF1F5DA0),
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.font(13),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.h(2)),

                    FutureBuilder<List<Pista>>(
                      future: pistas,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text("No hay pistas disponibles");
                        }
                        final lista = snapshot.data!
                            .where((p) => p.latitud != null && p.longitud != null)
                            .toList();

                        if (_posicion != null) {
                          lista.sort((a, b) {
                            final dA = _distancia(_posicion!.latitude, _posicion!.longitude, a.latitud!, a.longitud!);
                            final dB = _distancia(_posicion!.latitude, _posicion!.longitude, b.latitud!, b.longitud!);
                            return dA.compareTo(dB);
                          });
                        }

                        final cercanas = lista.take(3).toList();
                        return Column(
                          children: cercanas.map((pista) => _pistaCard(pista)).toList(),
                        );
                      },
                    ),

                    SizedBox(height: Responsive.h(4.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proximaReserva() {
    return Consumer<ReservaProvider>(
      builder: (context, provider, child) {
        if (provider.cargando) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)));
        }

        final reservas = provider.reservas
            .where((r) => r["estado"] == "ACTIVA")
            .toList();

        if (reservas.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.padding(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.padding(12)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F5DA0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF1F5DA0), size: 26),
                ),
                SizedBox(width: Responsive.w(3.5)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sin reservas próximas",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.font(15),
                      ),
                    ),
                    Text(
                      "¡Reserva una pista ahora!",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey,
                        fontSize: Responsive.font(13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        reservas.sort((a, b) => DateTime.parse(a["fechaReserva"]).compareTo(DateTime.parse(b["fechaReserva"])));
        final reserva = reservas.first;
        DateTime fecha = DateTime.parse(reserva["fechaReserva"]);

        const meses = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage("assets/images/image3.png"),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F5DA0).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
            padding: EdgeInsets.all(Responsive.padding(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reserva["pista"],
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins",
                            fontSize: Responsive.font(12),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(1.2)),
                      Text(
                        reserva["club"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.font(20),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(height: Responsive.h(0.9)),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${fecha.hour}:00 · 1 hora",
                            style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: Responsive.font(13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(14), vertical: Responsive.padding(10)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${fecha.day}",
                        style: TextStyle(
                          color: Color(0xFF1F5DA0),
                          fontSize: Responsive.font(22),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        meses[fecha.month - 1],
                        style: TextStyle(
                          color: Color(0xFF1F5DA0),
                          fontSize: Responsive.font(11),
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pistaCard(Pista pista) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PistaDetailScreen(pista: pista)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.h(2)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
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
                width: Responsive.w(22),
                height: Responsive.w(22),
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
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        pista.ciudad,
                        style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(13)),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(0.9)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F5DA0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${pista.precioHora}€/hora",
                      style: TextStyle(
                        color: Color(0xFF1F5DA0),
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.font(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(right: Responsive.padding(14)),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}