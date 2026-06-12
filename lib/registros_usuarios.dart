import 'package:flutter/material.dart';

class RegistroUsuarios extends StatefulWidget {
  const RegistroUsuarios({super.key});

  @override
  State<RegistroUsuarios> createState() => _RegistroUsuariosState();
}

class _RegistroUsuariosState extends State<RegistroUsuarios> {
  static const Color primaryDark = Color(0xFF134343);

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPController = TextEditingController();
  final TextEditingController _apellidoMController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPController.dispose();
    _apellidoMController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final apellidoPaterno = _apellidoPController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text;
    final confirmar = _confirmController.text;

    if (nombre.isEmpty ||
        apellidoPaterno.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        confirmar.isEmpty) {
      _mostrarMensaje('Por favor llena los campos obligatorios');
      return;
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      _mostrarMensaje('Ingresa un correo válido');
      return;
    }

    if (password.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (password != confirmar) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    _mostrarMensaje('Cuenta creada con éxito');
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 115,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.language,
                      size: 92,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    hint: 'Nombre',
                    controller: _nombreController,
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Apellido paterno',
                    controller: _apellidoPController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Apellido materno (opcional)',
                    controller: _apellidoMController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Correo electrónico',
                    controller: _correoController,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Contraseña',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    isObscure: _hidePassword,
                    suffix: IconButton(
                      tooltip: _hidePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    hint: 'Confirmar contraseña',
                    controller: _confirmController,
                    icon: Icons.verified_user_outlined,
                    isObscure: _hidePassword,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('¿Ya tienes una cuenta?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isObscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryDark, width: 1.5),
        ),
      ),
    );
  }
}
