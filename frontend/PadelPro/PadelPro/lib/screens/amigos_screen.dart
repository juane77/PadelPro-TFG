import 'package:flutter/material.dart';
import '../service/amistad_service.dart';
import '../service/foto_service.dart';
import '../utils/responsive.dart';
import '../utils/app_snackbar.dart';

class AmigosScreen extends StatefulWidget {
  const AmigosScreen({super.key});

  @override
  State<AmigosScreen> createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final _searchController = TextEditingController();

  List<dynamic> amigos = [];
  Map<int, String?> _fotosAmigos = {};
  List<dynamic> pendientes = [];
  List<dynamic> resultadosBusqueda = [];
  Map<int, String?> _fotosBusqueda = {};
  bool buscando = false;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => cargando = true);
    final a = await AmistadService.getAmigos();
    final p = await AmistadService.getSolicitudesPendientes();
    setState(() {
      amigos = a;
      pendientes = p;
      cargando = false;
    });
    await _cargarFotosAmigos(a);
    if (mounted) setState(() {
    });
  }


  Future<void> _cargarFotosAmigos(List<dynamic> lista) async {
    final Map<int, String?> fotos = {};
    for (final a in lista) {
      final id = a["id"] ?? a["idUsuario"];
      if (id != null) {
        final tiene = await FotoService.tieneFoto(id);
        fotos[id] = tiene ? FotoService.getUrlFoto(id) : null;
      }
    }
    if (mounted) setState(() => _fotosAmigos = fotos);
  }

  Future<void> _buscar(String q) async {
    if (q.trim().length < 2) {
      setState(() => resultadosBusqueda = []);
      return;
    }
    setState(() => buscando = true);
    final res = await AmistadService.buscarUsuarios(q.trim());
    setState(() {
      resultadosBusqueda = res;
      buscando = false;
    });
    await _cargarFotosBusqueda(res);
  }

  Future<void> _cargarFotosBusqueda(List<dynamic> lista) async {
    final Map<int, String?> fotos = {};
    for (final u in lista) {
      final id = u["id"];
      if (id != null) {
        final tiene = await FotoService.tieneFoto(id);
        fotos[id] = tiene ? FotoService.getUrlFoto(id) : null;
      }
    }
    if (mounted) setState(() => _fotosBusqueda = fotos);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        title: Text("Amigos", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18))),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(13)),
          tabs: [
            Tab(text: "Mis amigos"),
            Tab(text: pendientes.isNotEmpty ? "Solicitudes (${pendientes.length})" : "Solicitudes"),
            const Tab(text: "Buscar"),
          ],
        ),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)))
          : TabBarView(
              controller: _tabController,
              children: [
                _tabAmigos(),
                _tabPendientes(),
                _tabBuscar(),
              ],
            ),
    );
  }

  // TAB 1 — MIS AMIGOS
  Widget _tabAmigos() {
    if (amigos.isEmpty) {
      return _empty("Aún no tienes amigos", "Busca jugadores en la pestaña Buscar", Icons.people_outline);
    }
    return ListView.separated(
      padding: EdgeInsets.all(Responsive.padding(16)),
      itemCount: amigos.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(1.5)),
      itemBuilder: (context, index) {
        final amigo = amigos[index];
        return _amigoCard(amigo);
      },
    );
  }

  Widget _amigoCard(dynamic amigo) {
    final inicial = (amigo["nombre"] as String)[0].toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: Responsive.padding(16), vertical: Responsive.padding(8)),
        leading: CircleAvatar(
          radius: Responsive.imageSize(24),
          backgroundColor: const Color(0xFF1F5DA0).withOpacity(0.15),
          backgroundImage: _fotosAmigos[amigo["id"]] != null
              ? NetworkImage(_fotosAmigos[amigo["id"]]!) as ImageProvider
              : null,
          child: _fotosAmigos[amigo["id"]] == null
              ? Text(inicial, style: TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18)))
              : null,
        ),
        title: Text(amigo["nombre"], style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(14))),
        subtitle: Text(amigo["email"], style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(12), color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
          onPressed: () async {
            final ok = await AmistadService.eliminarAmistad(amigo["idAmistad"]);
            if (ok) {
              AppSnackbar.exito(context, "Amigo eliminado");
              _cargarDatos();
            }
          },
        ),
      ),
    );
  }

  // TAB 2 — SOLICITUDES PENDIENTES
  Widget _tabPendientes() {
    if (pendientes.isEmpty) {
      return _empty("Sin solicitudes pendientes", "Cuando alguien te añada aparecerá aquí", Icons.mark_email_unread_outlined);
    }
    return ListView.separated(
      padding: EdgeInsets.all(Responsive.padding(16)),
      itemCount: pendientes.length,
      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(1.5)),
      itemBuilder: (context, index) {
        final sol = pendientes[index];
        final inicial = (sol["nombre"] as String)[0].toUpperCase();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: Responsive.padding(16), vertical: Responsive.padding(8)),
            leading: CircleAvatar(
              radius: Responsive.imageSize(24),
              backgroundColor: Colors.orange.withOpacity(0.15),
              child: Text(inicial, style: TextStyle(color: Colors.orange, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18))),
            ),
            title: Text(sol["nombre"], style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(14))),
            subtitle: Text(sol["email"], style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(12), color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () async {
                    final ok = await AmistadService.aceptarSolicitud(sol["idAmistad"]);
                    if (ok) { AppSnackbar.exito(context, "Amistad aceptada 🎉"); _cargarDatos(); }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () async {
                    final ok = await AmistadService.eliminarAmistad(sol["idAmistad"]);
                    if (ok) { AppSnackbar.aviso(context, "Solicitud rechazada"); _cargarDatos(); }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 3 — BUSCAR
  Widget _tabBuscar() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(Responsive.padding(16)),
          child: TextField(
            controller: _searchController,
            onChanged: _buscar,
            decoration: InputDecoration(
              hintText: "Buscar por nombre o email...",
              hintStyle: TextStyle(fontFamily: "Poppins", color: Colors.grey, fontSize: Responsive.font(13)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1F5DA0)),
              suffixIcon: buscando ? Padding(padding: EdgeInsets.all(Responsive.padding(12)), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1F5DA0)))) : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1F5DA0), width: 2)),
            ),
          ),
        ),

        Expanded(
          child: resultadosBusqueda.isEmpty
              ? _empty("Busca jugadores", "Escribe al menos 2 caracteres", Icons.search)
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(Responsive.padding(16), 0, Responsive.padding(16), Responsive.padding(16)),
                  itemCount: resultadosBusqueda.length,
                  separatorBuilder: (_, __) => SizedBox(height: Responsive.h(1.5)),
                  itemBuilder: (context, index) {
                    final u = resultadosBusqueda[index];
                    return _resultadoBusquedaCard(u);
                  },
                ),
        ),
      ],
    );
  }

  Widget _resultadoBusquedaCard(dynamic u) {
    final inicial = (u["nombre"] as String)[0].toUpperCase();
    final estado = u["estadoAmistad"] as String;
    final idAmistad = u["idAmistad"] as int;

    Widget boton;
    if (estado == "ACEPTADA") {
      boton = Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(6)),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text("Amigo ✓", style: TextStyle(color: Colors.green, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(12))),
      );
    } else if (estado == "PENDIENTE") {
      boton = Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(6)),
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text("Pendiente", style: TextStyle(color: Colors.orange, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(12))),
      );
    } else {
      boton = GestureDetector(
        onTap: () async {
          final ok = await AmistadService.enviarSolicitud(u["id"]);
          if (ok) {
            AppSnackbar.exito(context, "Solicitud enviada a ${u["nombre"]}");
            _buscar(_searchController.text);
          } else {
            AppSnackbar.error(context, "Error al enviar solicitud");
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Responsive.padding(12), vertical: Responsive.padding(6)),
          decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(10)),
          child: Text("Añadir", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(12))),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: Responsive.padding(16), vertical: Responsive.padding(8)),
        leading: CircleAvatar(
          radius: Responsive.imageSize(24),
          backgroundColor: const Color(0xFF1F5DA0).withOpacity(0.1),
          backgroundImage: _fotosBusqueda[u["id"]] != null
              ? NetworkImage(_fotosBusqueda[u["id"]]!)
              : null,
          child: _fotosBusqueda[u["id"]] == null
              ? Text(inicial, style: TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(18)))
              : null,
        ),
        title: Text(u["nombre"], style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: Responsive.font(14))),
        subtitle: Text(u["email"], style: TextStyle(fontFamily: "Poppins", fontSize: Responsive.font(12), color: Colors.grey)),
        trailing: boton,
      ),
    );
  }

  Widget _empty(String titulo, String subtitulo, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.padding(24)),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(icon, size: Responsive.imageSize(48), color: Colors.grey.shade400),
          ),
          SizedBox(height: Responsive.h(2.5)),
          Text(titulo, style: TextStyle(color: Colors.grey.shade600, fontFamily: "Poppins", fontSize: Responsive.font(16), fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.h(0.9)),
          Text(subtitulo, style: TextStyle(color: Colors.grey.shade400, fontFamily: "Poppins", fontSize: Responsive.font(13))),
        ],
      ),
    );
  }
}