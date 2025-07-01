// login_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/colors.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/home_organizador.dart';
import 'package:mobile_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Usuarios hardcodeados
  final Map<String, Map<String, String>> _users = {
    'user@user.com': {
      'password': 'user12345',
      'type': 'user',
    },
    'organizador@organizador.com': {
      'password': 'organizador12345',
      'type': 'organizador',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_users.containsKey(email)) {
        if (_users[email]!['password'] == password) {
          // Login exitoso
          if (mounted) {
            final userType = _users[email]!['type'];

            if (userType == 'user') {
              // Navegar al home de usuario
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } else if (userType == 'organizador') {
              // Navegar al home de organizador
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const HomeOrganizador()),
              );
            }
          }
        } else {
          setState(() {
            _errorMessage = 'Contraseña incorrecta';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Usuario no encontrado';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error inesperado. Intenta nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header
                const Row(
                  children: [
                    Icon(Icons.event_seat, size: 32, color: appColor),
                    SizedBox(width: 12),
                    Text(
                      "LiveTickets",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Mensaje de error
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Campo de email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  onTapOutside: (e) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    prefixIconColor: appColor,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                    hintText: 'ejemplo@correo.com',
                    labelText: 'Email',
                    labelStyle: TextStyle(color: appColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  autocorrect: false,
                  onTapOutside: (e) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    prefixIconColor: appColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                    hintText: 'Contraseña',
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: appColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de iniciar sesión
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: appColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appColor,
                      side: const BorderSide(color: appColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Crear Cuenta',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
