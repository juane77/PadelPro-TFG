import 'package:flutter/material.dart';
import '../service/recuperar_service.dart';
import '../utils/app_snackbar.dart';
import 'login_screen.dart';

class ConfirmarEmailScreen extends StatefulWidget {
  final String email;
  final bool esRegistro;

  const ConfirmarEmailScreen({
    super.key,
    required this.email,
    this.esRegistro = false,
  });

  @override
  State<ConfirmarEmailScreen> createState() => _ConfirmarEmailScreenState();
}

class _ConfirmarEmailScreenState extends State<ConfirmarEmailScreen> {
  bool _cargando = false;
  final _codigoController = TextEditingController();

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      AppSnackbar.aviso(context, "Introduce el código");
      return;
    }
    if (codigo.length != 6) {
      AppSnackbar.aviso(context, "El código debe tener 6 dígitos");
      return;
    }

    setState(() => _cargando = true);

    final result = await RecuperarService.confirmarEmail(widget.email, codigo);

    setState(() => _cargando = false);

    if (result["success"]) {
      AppSnackbar.exito(context, "Email confirmado correctamente");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      AppSnackbar.error(context, result["mensaje"]);
    }
  }

  Future<void> _reenviar() async {
    setState(() => _cargando = true);

    final result = await RecuperarService.reenviarConfirmacion(widget.email);

    setState(() => _cargando = false);

    if (result["success"]) {
      AppSnackbar.exito(context, "Código reenviado");
    } else {
      AppSnackbar.error(context, result["mensaje"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1F5DA0),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: h * 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (widget.esRegistro)
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: h * 0.01),
            Image.asset("assets/images/logo.png", width: w * 0.30),
            SizedBox(height: h * 0.015),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.07,
                  vertical: h * 0.03,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Confirmar email",
                        style: TextStyle(
                          fontSize: (w * 0.09).clamp(26.0, 36.0),
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.esRegistro
                            ? "Te hemos enviado un código a tu email"
                            : "Introduce el código de confirmación",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "Poppins",
                          fontSize: (w * 0.035).clamp(12.0, 14.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5DA0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 48,
                              color: Color(0xFF1F5DA0),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.email,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                color: Color(0xFF1F5DA0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.03),
                      TextField(
                        controller: _codigoController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: "------",
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.03),
                      SizedBox(
                        width: w * 0.7,
                        height: h * 0.065,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F5DA0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _cargando ? null : _confirmar,
                          child: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Confirmar",
                                  style: TextStyle(
                                    fontSize: (w * 0.05).clamp(16.0, 20.0),
                                    fontFamily: "Poppins",
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _cargando ? null : _reenviar,
                        child: const Text(
                          "¿No te ha llegado? Reenviar código",
                          style: TextStyle(
                            color: Color(0xFF1F5DA0),
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                      if (widget.esRegistro) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          ),
                          child: const Text(
                            "Ya tengo cuenta, ir al login",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}