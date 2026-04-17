import 'package:flutter/material.dart';
import '../models/pista.dart';
import 'reservation_calendar_screen.dart';

class PistaDetailScreen extends StatelessWidget {

  final Pista pista;

  const PistaDetailScreen({super.key, required this.pista});

  String get imagenPista {
    return pista.tipo.toLowerCase().contains("cubierta")
        ? "assets/images/pista_cubierta.png"
        : "assets/images/pista_descubierta.png";
  }

  String get descripcion {
    switch (pista.nombre) {

    // MÉRIDA — Club Pádel Mérida
      case "Lusitania Court":
        return "Una pista cubierta de primer nivel en el corazón de Mérida, inspirada en el legado romano de la ciudad. Climatización de alta eficiencia, suelo de resina profesional e iluminación LED. El lugar perfecto para jugar al pádel en la capital extremeña todo el año.";
      case "Teatro Romano Arena":
        return "Con vistas al entorno arqueológico de Mérida, esta pista exterior es única en España. Rodeada del ambiente histórico de la ciudad romana, ofrece una experiencia de juego inigualable bajo el sol extremeño junto al Teatro Romano.";
      case "Guadiana Court":
        return "Situada junto al río Guadiana en Mérida, esta pista exterior aprovecha la brisa fresca del río para ofrecer partidos cómodos incluso en verano. Acceso directo desde el paseo fluvial y aparcamiento gratuito.";
      case "Emerita Indoor":
        return "La pista cubierta más completa de Mérida, nombrada en honor al nombre romano de la ciudad. Cristales panorámicos, vestuarios de lujo y cafetería integrada. Disponible los 365 días del año independientemente del clima extremeño.";

    // MADRID — Elite Padel Arena
      case "Arena Central":
        return "La pista estrella de Elite Padel Arena en el corazón de Madrid. Superficie de césped artificial de alta gama, iluminación LED profesional y temperatura controlada todo el año. Ideal para jugadores de todos los niveles que buscan las mejores condiciones de juego en la capital.";
      case "Champions Court":
        return "Diseñada para los más exigentes de Madrid. Cristales panorámicos de última generación, suelo de resina antideslizante y acústica optimizada. La pista preferida por jugadores federados de Elite Padel Arena en la Gran Vía madrileña.";
      case "Sky Court":
        return "Disfruta del pádel bajo el cielo de Madrid. Pista exterior con orientación norte-sur para evitar deslumbramientos, rodeada de vegetación y con acceso directo desde los vestuarios de Elite Padel Arena.";
      case "Sunset Arena":
        return "La pista más especial de Madrid. Con vistas al atardecer madrileño desde la Gran Vía, superficie de césped artificial de fibra larga y zona de descanso. Perfecta para partidos al caer la tarde en la capital.";

    // BARCELONA — Diagonal Padel Club
      case "Diagonal Pro":
        return "Pista de competición homologada por la Federación Española de Pádel, ubicada en plena Avenida Diagonal de Barcelona. Cuenta con gradas para espectadores y sistema de grabación de partidos para analizar tu juego.";
      case "Glass Court":
        return "La joya de Diagonal Padel Club en Barcelona. Paredes de cristal templado de 10mm, el más alto estándar del mercado. Visibilidad total desde todos los ángulos, usada habitualmente en torneos amateur de la ciudad condal.";
      case "Urban Court":
        return "Pádel en el corazón urbano de Barcelona. Diseño moderno con arte urbano en las paredes exteriores, ambiente joven y dinámico en plena Diagonal. La favorita de la nueva generación de jugadores barceloneses.";

    // VALENCIA — Turia Padel Experience
      case "Turia Open":
        return "Junto al cauce del río Turia en Valencia, esta pista exterior aprovecha el microclima privilegiado de la ciudad. Con vistas al parque fluvial y brisa mediterránea, ofrece una experiencia de juego única en la Comunitat Valenciana.";
      case "Levante Court":
        return "Con orientación al Mediterráneo desde Valencia, esta pista exterior es perfecta para los amantes del juego al aire libre. Superficie de césped artificial de última generación resistente al calor levantino.";
      case "Indoor Master":
        return "La pista cubierta de referencia en Valencia. Climatización de doble zona, suelo de resina profesional y sistema de sonido ambiente. Disponible todo el año independientemente del clima mediterráneo.";

    // SEVILLA — Sevilla Padel Factory
      case "Sevilla Prime":
        return "La pista premium de Sevilla Padel Factory en la Avenida Andalucía. Climatización especial para el verano sevillano, cristales de seguridad y el mejor ambiente de la capital hispalense para disfrutar del pádel.";
      case "Andalucía Court":
        return "Inspirada en la arquitectura andaluza de Sevilla, esta pista cubierta combina tradición y modernidad. Azulejos decorativos en las paredes, iluminación cálida y el mejor ambiente del sur de España.";
      case "Alcázar Arena":
        return "Pista exterior situada en Sevilla, con el inconfundible ambiente andaluz. Perfecta para partidos matutinos aprovechando la luz dorada de Sevilla antes del calor del mediodía. Un lujo jugar al pádel en la ciudad del flamenco.";

    // MÁLAGA — Costa del Sol Padel
      case "Beach Arena":
        return "A un paso de la playa en el Paseo Marítimo de Málaga. Esta pista exterior combina el ambiente de la Costa del Sol con instalaciones de primer nivel. Duchas exteriores y zona de bar incluidas para completar la experiencia.";
      case "Mediterráneo Court":
        return "La brisa del mar Mediterráneo acompaña cada partido en esta pista exterior de Málaga. Superficie de césped artificial especial para climas húmedos y sistema de drenaje ultrarrápido para jugar incluso tras la lluvia.";
      case "Costa Indoor":
        return "La pista cubierta más exclusiva de la Costa del Sol en Málaga. Climatización inversa, vestuarios de lujo con sauna y acceso privado desde el Paseo Marítimo. Frecuentada por jugadores de alto nivel que visitan la ciudad.";

      default:
        return "Pista profesional de pádel con instalaciones de primer nivel. Superficie de alta calidad, iluminación LED y todos los servicios necesarios para disfrutar del mejor pádel.";
    }
  }

  List<Map<String, dynamic>> get caracteristicas {
    if (pista.tipo.toLowerCase().contains("cubierta")) {
      return [
        {"icono": Icons.thermostat, "texto": "Climatizada"},
        {"icono": Icons.light_mode, "texto": "LED"},
        {"icono": Icons.shield, "texto": "Cristal"},
        {"icono": Icons.calendar_today, "texto": "Todo el año"},
      ];
    } else {
      return [
        {"icono": Icons.wb_sunny, "texto": "Aire libre"},
        {"icono": Icons.grass, "texto": "Césped"},
        {"icono": Icons.visibility, "texto": "Vistas"},
        {"icono": Icons.air, "texto": "Ventilación"},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1F5DA0)),
          ),
        ),
      ),

      body: Column(
        children: [

          Stack(
            children: [

              Image.asset(
                imagenPista,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Container(
                height: 260,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: pista.tipo.toLowerCase().contains("cubierta")
                            ? const Color(0xFF1F5DA0)
                            : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pista.tipo.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      pista.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${pista.clubNombre} · ${pista.ciudad}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Precio por hora",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontFamily: "Poppins",
                              ),
                            ),
                            Text(
                              "${pista.precioHora}€",
                              style: const TextStyle(
                                color: Color(0xFF1F5DA0),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                              SizedBox(width: 4),
                              Text(
                                "4.8",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Características",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: caracteristicas.map((c) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F5DA0).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    c["icono"] as IconData,
                                    color: const Color(0xFF1F5DA0),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c["texto"] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Poppins",
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Descripción",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          descripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: Colors.grey,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F5DA0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationCalendarScreen(pista: pista),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 20),
                SizedBox(width: 10),
                Text(
                  "Reservar pista",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}