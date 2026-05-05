import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/pista.dart';
import '../service/api_service.dart';
import 'pista_detail_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {

  Position? posicion;
  List<Pista> todasPistas = [];
  List<Pista> pistasOrdenadas = [];
  bool cargando = true;
  bool errorUbicacion = false;
  final MapController mapController = MapController();

  // Agrupa pistas por ubicación (misma lat/lng = mismo club)
  Map<String, List<Pista>> get pistasPorUbicacion {
    final Map<String, List<Pista>> mapa = {};
    for (final p in pistasOrdenadas) {
      final key = "${p.latitud!.toStringAsFixed(4)}_${p.longitud!.toStringAsFixed(4)}";
      mapa.putIfAbsent(key, () => []).add(p);
    }
    return mapa;
  }

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    setState(() => cargando = true);

    try {
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever ||
          permiso == LocationPermission.denied) {
        setState(() { errorUbicacion = true; cargando = false; });
        return;
      }

      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        final ultima = await Geolocator.getLastKnownPosition();
        if (ultima != null) {
          pos = ultima;
        } else {
          setState(() { errorUbicacion = true; cargando = false; });
          return;
        }
      }

      final pistas = await ApiService.getPistas();
      final ordenadas = pistas.where((p) => p.latitud != null && p.longitud != null).toList();
      ordenadas.sort((a, b) {
        final dA = _distancia(pos.latitude, pos.longitude, a.latitud!, a.longitud!);
        final dB = _distancia(pos.latitude, pos.longitude, b.latitud!, b.longitud!);
        return dA.compareTo(dB);
      });

      setState(() {
        posicion = pos;
        todasPistas = pistas;
        pistasOrdenadas = ordenadas;
        cargando = false;
      });

    } catch (e) {
      setState(() { errorUbicacion = true; cargando = false; });
    }
  }

  double _distancia(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _rad(double deg) => deg * pi / 180;

  String _distanciaTexto(Pista pista) {
    if (posicion == null || pista.latitud == null) return "";
    final km = _distancia(posicion!.latitude, posicion!.longitude, pista.latitud!, pista.longitud!);
    if (km < 1) return "${(km * 1000).toInt()} m";
    return "${km.toStringAsFixed(1)} km";
  }

  void _mostrarPistasDelClub(List<Pista> pistas) {
    if (pistas.length == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PistaDetailScreen(pista: pistas.first)));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                pistas.first.clubNombre,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins",
                ),
              ),
              Text(
                pistas.first.direccion ?? pistas.first.ciudad,
                style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                "Elige una pista:",
                style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ...pistas.map((pista) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PistaDetailScreen(pista: pista)));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5DA0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.sports_tennis, color: Color(0xFF1F5DA0), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pista.nombre,
                              style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              "${pista.tipo} · ${pista.precioHora}€/h",
                              style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Pistas cercanas",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () {
              if (posicion != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  mapController.move(LatLng(posicion!.latitude, posicion!.longitude), 13);
                });
              }
            },
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)))
          : errorUbicacion
              ? _errorUbicacion()
              : Column(
                  children: [

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: posicion != null
                              ? LatLng(posicion!.latitude, posicion!.longitude)
                              : const LatLng(40.3281, -3.7634),
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: "com.example.padelpro",
                          ),
                          MarkerLayer(
                            markers: [
                              if (posicion != null)
                                Marker(
                                  point: LatLng(posicion!.latitude, posicion!.longitude),
                                  width: 40, height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8)],
                                    ),
                                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                                  ),
                                ),

                              // UN MARCADOR POR UBICACIÓN ÚNICA
                              ...pistasPorUbicacion.entries.map((entry) {
                                final grupo = entry.value;
                                final primera = grupo.first;
                                final tieneVarias = grupo.length > 1;

                                return Marker(
                                  point: LatLng(primera.latitud!, primera.longitud!),
                                  width: tieneVarias ? 52 : 44,
                                  height: tieneVarias ? 52 : 44,
                                  child: GestureDetector(
                                    onTap: () => _mostrarPistasDelClub(grupo),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1F5DA0),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)],
                                          ),
                                          child: const Icon(Icons.sports_tennis, color: Colors.white, size: 22),
                                        ),
                                        if (tieneVarias)
                                          Positioned(
                                            right: 0, top: 0,
                                            child: Container(
                                              width: 18, height: 18,
                                              decoration: const BoxDecoration(
                                                color: Colors.orange,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${grupo.length}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Text(
                            "Más cercanas",
                            style: TextStyle(fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F5DA0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${pistasOrdenadas.length} pistas",
                              style: const TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pistasOrdenadas.length,
                        itemBuilder: (context, index) {
                          final pista = pistasOrdenadas[index];
                          final distancia = _distanciaTexto(pista);

                          return GestureDetector(
                            onTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                mapController.move(LatLng(pista.latitud!, pista.longitud!), 15);
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (_) => PistaDetailScreen(pista: pista)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: index < 3 ? const Color(0xFF1F5DA0) : const Color(0xFF1F5DA0).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          color: index < 3 ? Colors.white : const Color(0xFF1F5DA0),
                                          fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pista.nombre, style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(
                                          pista.clubNombre,
                                          style: const TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                        child: Text(distancia, style: const TextStyle(color: Colors.green, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("${pista.precioHora}€/h", style: const TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _errorUbicacion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("No se pudo obtener tu ubicación", textAlign: TextAlign.center, style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text("Activa el GPS y los permisos de ubicación para ver las pistas más cercanas", textAlign: TextAlign.center, style: TextStyle(fontFamily: "Poppins", fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F5DA0), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: inicializar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Reintentar", style: TextStyle(fontFamily: "Poppins")),
            ),
          ],
        ),
      ),
    );
  }
}