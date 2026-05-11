import 'package:flutter/material.dart';
import '../service/recuperar_service.dart';
import '../utils/app_snackbar.dart';
import 'login_screen.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  int _step = 0;
  bool _cargando = false;

  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _codigoRecibido;
  String? _emailIngresado;

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _solicitarCodigo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AppSnackbar.aviso(context, "Introduce tu email");
      return;
    }
    if (!email.contains("@") || !email.contains(".")) {
      AppSnackbar.error(context, "El email no es válido");
      return;
    }

    setState(() => _cargando = true);

    final result = await RecuperarService.solicitarCodigo(email);

    setState(() => _cargando = false);

    if (result["success"]) {
      setState(() {
        _codigoRecibido = result["codigo"];
        _emailIngresado = email;
        _step = 1;
      });
      AppSnackbar.exito(context, "Código enviado: ${result["codigo"]}");
    } else {
      AppSnackbar.error(context, result["mensaje"]);
    }
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      AppSnackbar.aviso(context, "Introduce el código");
      return;
    }
    if (codigo.length != 6) {
      AppSnackbar.aviso(context, "El código debe tener 6 dígitos");
      return;
    }

    if (codigo == _codigoRecibido) {
      setState(() => _step = 2);
      AppSnackbar.exito(context, "Código verificado");
    } else {
      AppSnackbar.error(context, "Código incorrecto");
    }
  }

  Future<void> _cambiarPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      AppSnackbar.aviso(context, "Rellena todos los campos");
      return;
    }
    if (password.length < 4) {
      AppSnackbar.error(context, "La contraseña debe tener al menos 4 caracteres");
      return;
    }
    if (password != confirmPassword) {
      AppSnackbar.error(context, "Las contraseñas no coinciden");
      return;
    }

    setState(() => _cargando = true);

    final result = await RecuperarService.cambiarPassword(
      _emailIngresado!,
      _codigoRecibido!,
      password,
    );

    setState(() => _cargando = false);

    if (result["success"]) {
      AppSnackbar.exito(context, "Contraseña actualizada correctamente");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
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
                        "Recuperar contraseña",
                        style: TextStyle(
                          fontSize: (w * 0.09).clamp(26.0, 36.0),
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepSubtitle(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "Poppins",
                          fontSize: (w * 0.035).clamp(12.0, 14.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      IndexedStack(
                        index: _step,
                        children: [
                          _buildStep1(w, h),
                          _buildStep2(w, h),
                          _buildStep3(w, h),
                        ],
                      ),
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

  String _getStepSubtitle() {
    switch (_step) {
      case 0:
        return "Introduce tu email para recibir un código";
      case 1:
        return "Introduce el código de 6 dígitos";
      case 2:
        return "Crea una nueva contraseña";
      default:
        return "";
    }
  }

  Widget _buildStep1(double w, double h) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        SizedBox(height: h * 0.04),
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
            onPressed: _cargando ? null : _solicitarCodigo,
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
                    "Enviar código",
                    style: TextStyle(
                      fontSize: (w * 0.05).clamp(16.0, 20.0),
                      fontFamily: "Poppins",
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(double w, double h) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F5DA0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                "Tu código es:",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _codigoRecibido ?? "------",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: Color(0xFF1F5DA0),
                  letterSpacing: 8,
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
            onPressed: _cargando ? null : _verificarCodigo,
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
                    "Verificar código",
                    style: TextStyle(
                      fontSize: (w * 0.05).clamp(16.0, 20.0),
                      fontFamily: "Poppins",
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _step = 0),
          child: const Text(
            "Volver a introducir email",
            style: TextStyle(
              color: Color(0xFF1F5DA0),
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(double w, double h) {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Nueva contraseña",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        SizedBox(height: h * 0.018),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Confirmar contraseña",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        SizedBox(height: h * 0.04),
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
            onPressed: _cargando ? null : _cambiarPassword,
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
                    "Cambiar contraseña",
                    style: TextStyle(
                      fontSize: (w * 0.05).clamp(16.0, 20.0),
                      fontFamily: "Poppins",
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _step = 1),
          child: const Text(
            "Volver a introducir código",
            style: TextStyle(
              color: Color(0xFF1F5DA0),
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    );
  }
}