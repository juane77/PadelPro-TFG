import 'package:flutter/material.dart';
import '../service/amistad_service.dart';
import '../service/foto_service.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5DA0),
        foregroundColor: Colors.white,
        title: const Text("Amigos", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            const Tab(text: "Mis amigos"),
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
      padding: const EdgeInsets.all(16),
      itemCount: amigos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF1F5DA0).withOpacity(0.15),
          backgroundImage: _fotosAmigos[amigo["id"]] != null
              ? NetworkImage(_fotosAmigos[amigo["id"]]!) as ImageProvider
              : null,
          child: _fotosAmigos[amigo["id"]] == null
              ? Text(inicial, style: const TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18))
              : null,
        ),
        title: Text(amigo["nombre"], style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        subtitle: Text(amigo["email"], style: const TextStyle(fontFamily: "Poppins", fontSize: 12, color: Colors.grey)),
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
      padding: const EdgeInsets.all(16),
      itemCount: pendientes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.orange.withOpacity(0.15),
              child: Text(inicial, style: const TextStyle(color: Colors.orange, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text(sol["nombre"], style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
            subtitle: Text(sol["email"], style: const TextStyle(fontFamily: "Poppins", fontSize: 12, color: Colors.grey)),
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
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _buscar,
            decoration: InputDecoration(
              hintText: "Buscar por nombre o email...",
              hintStyle: const TextStyle(fontFamily: "Poppins", color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1F5DA0)),
              suffixIcon: buscando ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1F5DA0)))) : null,
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: resultadosBusqueda.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: const Text("Amigo ✓", style: TextStyle(color: Colors.green, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
      );
    } else if (estado == "PENDIENTE") {
      boton = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: const Text("Pendiente", style: TextStyle(color: Colors.orange, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(10)),
          child: const Text("Añadir", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 12)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF1F5DA0).withOpacity(0.1),
          backgroundImage: _fotosBusqueda[u["id"]] != null
              ? NetworkImage(_fotosBusqueda[u["id"]]!)
              : null,
          child: _fotosBusqueda[u["id"]] == null
              ? Text(inicial, style: const TextStyle(color: Color(0xFF1F5DA0), fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 18))
              : null,
        ),
        title: Text(u["nombre"], style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        subtitle: Text(u["email"], style: const TextStyle(fontFamily: "Poppins", fontSize: 12, color: Colors.grey)),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(titulo, style: TextStyle(color: Colors.grey.shade600, fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitulo, style: TextStyle(color: Colors.grey.shade400, fontFamily: "Poppins", fontSize: 13)),
        ],
      ),
    );
  }
}