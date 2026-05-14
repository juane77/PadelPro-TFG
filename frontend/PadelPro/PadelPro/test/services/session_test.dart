import 'package:flutter_test/flutter_test.dart';
import 'package:padelpro/service/session.dart';

void main() {
  tearDown(() {
    Session.clear();
  });

  group('Session', () {
    test('valores iniciales son null o 0', () {
      expect(Session.usuarioId, isNull);
      expect(Session.nombre, isNull);
      expect(Session.email, isNull);
      expect(Session.token, isNull);
      expect(Session.pelotas, 0);
      expect(Session.rol, isNull);
      expect(Session.idClub, isNull);
      expect(Session.clubNombre, isNull);
      expect(Session.fotoUrl, isNull);
    });

    test('authHeaders devuelve Content-Type y Authorization', () {
      Session.token = "test-token-123";
      final headers = Session.authHeaders;

      expect(headers["Content-Type"], "application/json");
      expect(headers["Authorization"], "Bearer test-token-123");
    });

    test('authHeaders devuelve Authorization con null si token es null', () {
      Session.token = null;
      final headers = Session.authHeaders;

      expect(headers["Authorization"], "Bearer null");
    });

    test('clear resetea todos los campos a su valor inicial', () {
      Session.usuarioId = 1;
      Session.nombre = "Test";
      Session.email = "test@test.com";
      Session.token = "token";
      Session.pelotas = 50;
      Session.rol = "USER";
      Session.idClub = 3;
      Session.clubNombre = "Club Test";
      Session.fotoUrl = "https://ejemplo.com/foto.jpg";

      Session.clear();

      expect(Session.usuarioId, isNull);
      expect(Session.nombre, isNull);
      expect(Session.email, isNull);
      expect(Session.token, isNull);
      expect(Session.pelotas, 0);
      expect(Session.rol, isNull);
      expect(Session.idClub, isNull);
      expect(Session.clubNombre, isNull);
      expect(Session.fotoUrl, isNull);
    });

    test('settear y leer valores funciona correctamente', () {
      Session.usuarioId = 42;
      Session.nombre = "Juan";
      Session.email = "juan@test.com";
      Session.pelotas = 100;

      expect(Session.usuarioId, 42);
      expect(Session.nombre, "Juan");
      expect(Session.email, "juan@test.com");
      expect(Session.pelotas, 100);
    });
  });
}
