import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padelpro/service/session.dart';
import 'package:padelpro/widgets/app_header.dart';

void main() {
  setUp(() {
    Session.nombre = "Test";
  });

  tearDown(() {
    Session.nombre = null;
  });

  Widget buildAppHeader({String titulo = "Bienvenido"}) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: AppHeader(titulo: titulo),
        ),
      ),
    );
  }

  testWidgets('muestra el titulo PadelPro', (tester) async {
    await tester.pumpWidget(buildAppHeader());
    expect(find.text("PadelPro"), findsOneWidget);
  });

  testWidgets('muestra el titulo pasado como parametro', (tester) async {
    await tester.pumpWidget(buildAppHeader(titulo: "Mi perfil"));
    expect(find.text("Mi perfil"), findsOneWidget);
  });

  testWidgets('muestra la inicial del usuario en el avatar', (tester) async {
    await tester.pumpWidget(buildAppHeader());
    expect(find.text("T"), findsOneWidget);
  });

  testWidgets('muestra ? si el nombre es null', (tester) async {
    Session.nombre = null;
    await tester.pumpWidget(buildAppHeader());
    expect(find.text("?"), findsOneWidget);
  });
}
