// main.dart - Configuración inicial
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ccpuhacxxcsceroyscgo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjcHVoYWN4eGNzY2Vyb3lzY2dvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzMzYzNjMsImV4cCI6MjA2NjkxMjM2M30.E5qC0gC1sFY8X3lP1w5PqCBgdWCwJbVps_M-exQDFqg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AuthWrapper(),
    );
  }
}

// Wrapper para manejar el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUser();

    // Escuchar cambios en el estado de autenticación
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      setState(() {
        _user = session?.user;
      });
    });
  }

  void _getUser() {
    setState(() {
      _user = Supabase.instance.client.auth.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const LoginScreen() : const Home();
  }
}

// Funciones de utilidad para auth
class AuthService {
  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  static User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }

  static bool isLoggedIn() {
    return Supabase.instance.client.auth.currentUser != null;
  }
}
