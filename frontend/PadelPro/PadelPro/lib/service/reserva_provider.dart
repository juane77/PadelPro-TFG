import 'package:flutter/foundation.dart';
import 'reserva_service.dart';
import 'session.dart';

class ReservaProvider extends ChangeNotifier {

  List<dynamic> _reservas = [];
  bool _cargando = false;

  List<dynamic> get reservas => _reservas;
  bool get cargando => _cargando;

  Future<void> cargarReservas() async {
    if (Session.usuarioId == null) return;
    
    _cargando = true;
    notifyListeners();

    _reservas = await ReservaService.getReservasUsuario(Session.usuarioId!);

    _cargando = false;
    notifyListeners();
  }

  void actualizar() {
    notifyListeners();
  }
}