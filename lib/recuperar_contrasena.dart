import 'package:flutter/material.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  static const Color primaryDark = Color(0xFF134343);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  int _currentStep = 0;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      final email = _emailController.text.trim();
      if (!email.contains('@') || !email.contains('.')) {
        _showMessage('Ingresa un correo válido');
        return;
      }
    }

    if (_currentStep == 1 && _codeController.text.trim().length < 4) {
      _showMessage('Ingresa el código de verificación');
      return;
    }

    if (_currentStep == 2) {
      if (_passwordController.text.length < 6) {
        _showMessage('La contraseña debe tener al menos 6 caracteres');
        return;
      }
      if (_passwordController.text != _confirmController.text) {
        _showMessage('Las contraseñas no coinciden');
        return;
      }
      _showMessage('Contraseña actualizada');
      Navigator.pop(context);
      return;
    }

    setState(() => _currentStep++);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryDark,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 10, 28, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 140,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.language,
                      color: primaryDark,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _StepIndicator(currentStep: _currentStep),
                  const SizedBox(height: 26),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _buildStep(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_currentStep) {
      0 => _RecoveryStep(
        key: const ValueKey('email'),
        title: 'Recuperar contraseña',
        subtitle: 'Escribe tu correo para enviarte un código de verificación.',
        fields: [
          _buildTextField(
            hint: 'Correo electrónico',
            controller: _emailController,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
        buttonText: 'Enviar código',
        onPressed: _nextStep,
      ),
      1 => _RecoveryStep(
        key: const ValueKey('code'),
        title: 'Verificación',
        subtitle: 'Ingresa el código que recibiste en tu correo.',
        fields: [
          _buildTextField(
            hint: 'Código de verificación',
            controller: _codeController,
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ],
        buttonText: 'Continuar',
        onPressed: _nextStep,
      ),
      _ => _RecoveryStep(
        key: const ValueKey('password'),
        title: 'Nueva contraseña',
        subtitle: 'Elige una contraseña segura para volver a entrar.',
        fields: [
          _buildTextField(
            hint: 'Nueva contraseña',
            controller: _passwordController,
            icon: Icons.lock_outline,
            isObscure: _hidePassword,
            suffix: IconButton(
              tooltip: _hidePassword
                  ? 'Mostrar contraseña'
                  : 'Ocultar contraseña',
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
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
        ],
        buttonText: 'Confirmar',
        onPressed: _nextStep,
      ),
    };
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isObscure = false,
    TextInputType? keyboardType,
    TextAlign textAlign = TextAlign.start,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      textAlign: textAlign,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
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

class _RecoveryStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String buttonText;
  final VoidCallback onPressed;

  const _RecoveryStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF134343),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.3),
        ),
        const SizedBox(height: 24),
        ...fields,
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF134343),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index <= currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: active ? 34 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF134343)
                : Colors.black.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
