import 'package:flutter_test/flutter_test.dart';
import 'package:padelpro/models/pista.dart';

void main() {
  group('Pista.fromJson', () {
    test('crea Pista correctamente con datos completos', () {
      final json = {
        "id": 1,
        "nombre": "Pista Central",
        "tipo": "cubierta",
        "precioHora": 12.0,
        "club": {
          "nombre": "Club PadelPro",
          "ciudad": "Sevilla",
        },
        "latitud": 37.3891,
        "longitud": -5.9845,
        "direccion": "Calle Ejemplo 123",
      };

      final pista = Pista.fromJson(json);

      expect(pista.id, 1);
      expect(pista.nombre, "Pista Central");
      expect(pista.tipo, "cubierta");
      expect(pista.precioHora, 12.0);
      expect(pista.clubNombre, "Club PadelPro");
      expect(pista.ciudad, "Sevilla");
      expect(pista.latitud, 37.3891);
      expect(pista.longitud, -5.9845);
      expect(pista.direccion, "Calle Ejemplo 123");
    });

    test('crea Pista correctamente con latitud y longitud nulos', () {
      final json = {
        "id": 2,
        "nombre": "Pista Norte",
        "tipo": "descubierta",
        "precioHora": 8.0,
        "club": {
          "nombre": "Club Norte",
          "ciudad": "Madrid",
        },
        "latitud": null,
        "longitud": null,
        "direccion": null,
      };

      final pista = Pista.fromJson(json);

      expect(pista.id, 2);
      expect(pista.nombre, "Pista Norte");
      expect(pista.tipo, "descubierta");
      expect(pista.precioHora, 8.0);
      expect(pista.clubNombre, "Club Norte");
      expect(pista.ciudad, "Madrid");
      expect(pista.latitud, isNull);
      expect(pista.longitud, isNull);
      expect(pista.direccion, isNull);
    });

    test('precioHora se parsea correctamente aunque llegue como entero', () {
      final json = {
        "id": 3,
        "nombre": "Pista Sur",
        "tipo": "cubierta",
        "precioHora": 10,
        "club": {
          "nombre": "Club Sur",
          "ciudad": "Barcelona",
        },
      };

      final pista = Pista.fromJson(json);

      expect(pista.precioHora, isA<double>());
      expect(pista.precioHora, 10.0);
    });
  });
}
