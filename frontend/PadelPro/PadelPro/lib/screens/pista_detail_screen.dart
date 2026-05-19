import 'package:flutter/material.dart';
import '../models/pista.dart';
import '../service/valoracion_service.dart';
import '../utils/responsive.dart';
import 'reservation_calendar_screen.dart';

class PistaDetailScreen extends StatefulWidget {

  final Pista pista;

  const PistaDetailScreen({super.key, required this.pista});

  @override
  State<PistaDetailScreen> createState() => _PistaDetailScreenState();
}

class _PistaDetailScreenState extends State<PistaDetailScreen> {

  double mediaValoracion = 4.5;
  double miValoracion = 0.0;
  int totalValoraciones = 0;
  bool cargandoValoracion = true;

  // Valoraciones predefinidas por pista
  static const Map<String, double> _valoracionesPredefinidas = {
    "Lusitania Court": 4.7,
    "Teatro Romano Arena": 4.5,
    "Guadiana Court": 4.2,
    "Emerita Indoor": 4.6,
    "Arena Central": 4.8,
    "Champions Court": 4.9,
    "Sky Court": 4.3,
    "Sunset Arena": 4.4,
    "Diagonal Pro": 4.8,
    "Glass Court": 4.7,
    "Urban Court": 4.1,
    "Turia Open": 4.3,
    "Levante Court": 4.2,
    "Indoor Master": 4.6,
    "Sevilla Prime": 4.5,
    "Andalucía Court": 4.4,
    "Alcázar Arena": 4.0,
    "Beach Arena": 4.6,
    "Mediterráneo Court": 4.3,
    "Costa Indoor": 4.8,
  };

  @override
  void initState() {
    super.initState();
    _cargarValoracion();
  }

  Future<void> _cargarValoracion() async {
    final data = await ValoracionService.getValoracion(widget.pista.id);
    final totalServer = (data["total"] as num).toInt();
    final mediaServer = (data["media"] as num).toDouble();

    setState(() {
      // Si no hay valoraciones reales, usar la predefinida
      if (totalServer == 0) {
        mediaValoracion = _valoracionesPredefinidas[widget.pista.nombre] ?? 4.3;
        totalValoraciones = 0;
      } else {
        mediaValoracion = mediaServer;
        totalValoraciones = totalServer;
      }
      miValoracion = (data["miValoracion"] as num).toDouble();
      cargandoValoracion = false;
    });
  }

  Future<void> _valorar(double puntuacion) async {
    try {
      final data = await ValoracionService.valorar(widget.pista.id, puntuacion);
      setState(() {
        miValoracion = puntuacion;
        mediaValoracion = (data["media"] as num).toDouble();
        totalValoraciones = (data["total"] as num).toInt();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Gracias por tu valoración! ⭐"), backgroundColor: Colors.green),
      );
    } catch (_) {}
  }

  String get imagenPista {
    return widget.pista.tipo.toLowerCase().contains("cubierta")
        ? "assets/images/pista_cubierta.png"
        : "assets/images/pista_descubierta.png";
  }

  String get descripcion {
    switch (widget.pista.nombre) {
      case "Lusitania Court": return "Una pista cubierta de primer nivel en el corazón de Mérida, inspirada en el legado romano de la ciudad. Climatización de alta eficiencia, suelo de resina profesional e iluminación LED. El lugar perfecto para jugar al pádel en la capital extremeña todo el año.";
      case "Teatro Romano Arena": return "Con vistas al entorno arqueológico de Mérida, esta pista exterior es única en España. Rodeada del ambiente histórico de la ciudad romana, ofrece una experiencia de juego inigualable bajo el sol extremeño junto al Teatro Romano.";
      case "Guadiana Court": return "Situada junto al río Guadiana en Mérida, esta pista exterior aprovecha la brisa fresca del río para ofrecer partidos cómodos incluso en verano. Acceso directo desde el paseo fluvial y aparcamiento gratuito.";
      case "Emerita Indoor": return "La pista cubierta más completa de Mérida, nombrada en honor al nombre romano de la ciudad. Cristales panorámicos, vestuarios de lujo y cafetería integrada. Disponible los 365 días del año independientemente del clima extremeño.";
      case "Arena Central": return "La pista estrella de Elite Padel Arena en el corazón de Madrid. Superficie de césped artificial de alta gama, iluminación LED profesional y temperatura controlada todo el año. Ideal para jugadores de todos los niveles que buscan las mejores condiciones de juego en la capital.";
      case "Champions Court": return "Diseñada para los más exigentes de Madrid. Cristales panorámicos de última generación, suelo de resina antideslizante y acústica optimizada. La pista preferida por jugadores federados de Elite Padel Arena en la Gran Vía madrileña.";
      case "Sky Court": return "Disfruta del pádel bajo el cielo de Madrid. Pista exterior con orientación norte-sur para evitar deslumbramientos, rodeada de vegetación y con acceso directo desde los vestuarios de Elite Padel Arena.";
      case "Sunset Arena": return "La pista más especial de Madrid. Con vistas al atardecer madrileño desde la Gran Vía, superficie de césped artificial de fibra larga y zona de descanso. Perfecta para partidos al caer la tarde en la capital.";
      case "Diagonal Pro": return "Pista de competición homologada por la Federación Española de Pádel, ubicada en plena Avenida Diagonal de Barcelona. Cuenta con gradas para espectadores y sistema de grabación de partidos para analizar tu juego.";
      case "Glass Court": return "La joya de Diagonal Padel Club en Barcelona. Paredes de cristal templado de 10mm, el más alto estándar del mercado. Visibilidad total desde todos los ángulos, usada habitualmente en torneos amateur de la ciudad condal.";
      case "Urban Court": return "Pádel en el corazón urbano de Barcelona. Diseño moderno con arte urbano en las paredes exteriores, ambiente joven y dinámico en plena Diagonal. La favorita de la nueva generación de jugadores barceloneses.";
      case "Turia Open": return "Junto al cauce del río Turia en Valencia, esta pista exterior aprovecha el microclima privilegiado de la ciudad. Con vistas al parque fluvial y brisa mediterránea, ofrece una experiencia de juego única en la Comunitat Valenciana.";
      case "Levante Court": return "Con orientación al Mediterráneo desde Valencia, esta pista exterior es perfecta para los amantes del juego al aire libre. Superficie de césped artificial de última generación resistente al calor levantino.";
      case "Indoor Master": return "La pista cubierta de referencia en Valencia. Climatización de doble zona, suelo de resina profesional y sistema de sonido ambiente. Disponible todo el año independientemente del clima mediterráneo.";
      case "Sevilla Prime": return "La pista premium de Sevilla Padel Factory en la Avenida Andalucía. Climatización especial para el verano sevillano, cristales de seguridad y el mejor ambiente de la capital hispalense para disfrutar del pádel.";
      case "Andalucía Court": return "Inspirada en la arquitectura andaluza de Sevilla, esta pista cubierta combina tradición y modernidad. Azulejos decorativos en las paredes, iluminación cálida y el mejor ambiente del sur de España.";
      case "Alcázar Arena": return "Pista exterior situada en Sevilla, con el inconfundible ambiente andaluz. Perfecta para partidos matutinos aprovechando la luz dorada de Sevilla antes del calor del mediodía. Un lujo jugar al pádel en la ciudad del flamenco.";
      case "Beach Arena": return "A un paso de la playa en el Paseo Marítimo de Málaga. Esta pista exterior combina el ambiente de la Costa del Sol con instalaciones de primer nivel. Duchas exteriores y zona de bar incluidas para completar la experiencia.";
      case "Mediterráneo Court": return "La brisa del mar Mediterráneo acompaña cada partido en esta pista exterior de Málaga. Superficie de césped artificial especial para climas húmedos y sistema de drenaje ultrarrápido para jugar incluso tras la lluvia.";
      case "Costa Indoor": return "La pista cubierta más exclusiva de la Costa del Sol en Málaga. Climatización inversa, vestuarios de lujo con sauna y acceso privado desde el Paseo Marítimo. Frecuentada por jugadores de alto nivel que visitan la ciudad.";
      default: return "Pista profesional de pádel con instalaciones de primer nivel. Superficie de alta calidad, iluminación LED y todos los servicios necesarios para disfrutar del mejor pádel.";
    }
  }

  List<Map<String, dynamic>> get caracteristicas {
    if (widget.pista.tipo.toLowerCase().contains("cubierta")) {
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
    Responsive.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(Responsive.padding(8)),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1F5DA0)),
          ),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(imagenPista, height: Responsive.imageSize(260), width: double.infinity, fit: BoxFit.cover),
              Container(
                height: Responsive.imageSize(260),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              Positioned(
                bottom: Responsive.padding(20), left: Responsive.padding(20), right: Responsive.padding(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.pista.tipo.toLowerCase().contains("cubierta") ? const Color(0xFF1F5DA0) : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.pista.tipo.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: Responsive.font(11), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                    ),
                    SizedBox(height: Responsive.h(0.9)),
                    Text(widget.pista.nombre, style: TextStyle(color: Colors.white, fontSize: Responsive.font(28), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text("${widget.pista.clubNombre} · ${widget.pista.ciudad}", style: TextStyle(color: Colors.white70, fontSize: Responsive.font(14), fontFamily: "Poppins")),
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

                  // PRECIO Y VALORACIÓN
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20), vertical: Responsive.padding(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Precio por hora", style: TextStyle(color: Colors.grey, fontSize: Responsive.font(13), fontFamily: "Poppins")),
                            Text("${widget.pista.precioHora}€", style: TextStyle(color: Color(0xFF1F5DA0), fontSize: Responsive.font(32), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                          ],
                        ),

                        cargandoValoracion
                            ? SizedBox(width: Responsive.w(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1F5DA0))))
                            : GestureDetector(
                                onTap: () => _mostrarDialogoValorar(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(14), vertical: Responsive.padding(8)),
                                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                                          const SizedBox(width: 4),
                                          Text(mediaValoracion.toStringAsFixed(1), style: TextStyle(fontSize: Responsive.font(18), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                                        ],
                                      ),
                                      if (totalValoraciones > 0)
                                        Text("$totalValoraciones reseña${totalValoraciones != 1 ? 's' : ''}", style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(10)))
                                      else
                                        Text("Valórala", style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: Responsive.font(10))),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.h(1.2)),

                  // CARACTERÍSTICAS
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(Responsive.padding(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Características", style: TextStyle(fontSize: Responsive.font(18), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                        SizedBox(height: Responsive.h(2.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: caracteristicas.map((c) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(Responsive.padding(12)),
                                  decoration: BoxDecoration(color: const Color(0xFF1F5DA0).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                                  child: Icon(c["icono"] as IconData, color: const Color(0xFF1F5DA0), size: Responsive.imageSize(26)),
                                ),
                                SizedBox(height: Responsive.h(0.9)),
                                Text(c["texto"] as String, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.font(11), fontFamily: "Poppins", color: Colors.grey)),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.h(1.2)),

                  // DESCRIPCIÓN
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.all(Responsive.padding(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Descripción", style: TextStyle(fontSize: Responsive.font(18), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                        SizedBox(height: Responsive.h(1.5)),
                        Text(descripcion, style: TextStyle(fontSize: Responsive.font(14), fontFamily: "Poppins", color: Colors.grey, height: 1.6)),
                      ],
                    ),
                  ),

                  // MI VALORACIÓN
                  if (miValoracion > 0) ...[
                    SizedBox(height: Responsive.h(1.2)),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(Responsive.padding(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tu valoración", style: TextStyle(fontSize: Responsive.font(18), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                          SizedBox(height: Responsive.h(1.8)),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < miValoracion ? Icons.star_rounded : Icons.star_border_rounded,
                              color: i < miValoracion ? Colors.amber : Colors.grey.shade300,
                              size: Responsive.imageSize(30),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: Responsive.h(15)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.padding(20), vertical: Responsive.padding(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: Responsive.h(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F5DA0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationCalendarScreen(pista: widget.pista))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 10),
                Text("Reservar pista", style: TextStyle(fontSize: Responsive.font(18), fontWeight: FontWeight.bold, fontFamily: "Poppins")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoValorar(BuildContext context) {
    double seleccion = miValoracion > 0 ? miValoracion : 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Valorar pista", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.pista.nombre, style: const TextStyle(fontFamily: "Poppins", color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final estrella = i + 1;
                  return GestureDetector(
                    onTap: () => setDialogState(() => seleccion = estrella.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        estrella <= seleccion ? Icons.star_rounded : Icons.star_border_rounded,
                        color: estrella <= seleccion ? Colors.amber : Colors.grey.shade300,
                        size: 38,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              if (seleccion > 0)
                Text(_textoValoracion(seleccion), style: const TextStyle(fontFamily: "Poppins", color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F5DA0), foregroundColor: Colors.white),
              onPressed: seleccion > 0 ? () { Navigator.pop(context); _valorar(seleccion); } : null,
              child: const Text("Guardar", style: TextStyle(fontFamily: "Poppins")),
            ),
          ],
        ),
      ),
    );
  }

  String _textoValoracion(double v) {
    if (v >= 5) return "¡Excelente!";
    if (v >= 4) return "Muy buena";
    if (v >= 3) return "Normal";
    if (v >= 2) return "Mejorable";
    return "Mala experiencia";
  }
}