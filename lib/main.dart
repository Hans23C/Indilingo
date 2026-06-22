import 'package:flutter/material.dart';

import 'inicio_screen.dart';
import 'recuperar_contrasena.dart';
import 'registros_usuarios.dart';
import 'theme_controller.dart';
import 'user_progress_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserProgressController.initialize();
  runApp(const IndilingoApp());
}

class IndilingoApp extends StatelessWidget {
  const IndilingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF134343);
    const darkBackground = Color(0xFF101C1C);
    const darkSurface = Color(0xFF182929);

    return ValueListenableBuilder<bool>(
      valueListenable: AppThemeController.isDarkMode,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'INDIlingo',
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFFDF1E1),
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryDark,
              primary: primaryDark,
              surface: const Color(0xFFFDF1E1),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: primaryDark,
              surfaceTintColor: Colors.transparent,
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: primaryDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: darkBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5ED6CE),
              brightness: Brightness.dark,
              primary: const Color(0xFF5ED6CE),
              surface: darkSurface,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: darkSurface,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            drawerTheme: const DrawerThemeData(backgroundColor: darkSurface),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: const Color(0xFF5ED6CE),
              contentTextStyle: const TextStyle(color: Colors.black),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          home: const LoginScreen(),
          routes: {'/login': (_) => const LoginScreen()},
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryDark = Color(0xFF134343);

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validarLogin() async {
    final usuario = _userController.text.trim();
    final password = _passwordController.text;

    if (usuario.isEmpty || password.isEmpty) {
      _mostrarMensaje('Por favor llena todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    await UserProgressController.loginAndSave(userOrEmail: usuario);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioScreen()),
    );
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
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 170,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.language,
                      color: primaryDark,
                      size: 120,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Bienvenido a INDIlingo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aprende lenguas originarias a tu ritmo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    hint: 'Usuario o correo',
                    controller: _userController,
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _validarLogin,
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
                              'Ingresar',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecuperarContrasenaScreen(),
                      ),
                    ),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('¿No tienes una cuenta?'),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistroUsuarios(),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
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
      textInputAction: isObscure ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) {
        if (isObscure) _validarLogin();
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
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
