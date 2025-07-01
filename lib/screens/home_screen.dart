// TODO Implement this library.// home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/backend.dart';
import 'package:mobile_app/colors.dart';
import 'package:mobile_app/connection.dart';
import 'package:mobile_app/schemas.dart';
import 'package:mobile_app/widgets/event_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? searchInput;

  Future<void> _signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      debugPrint('Error al cerrar sesión: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!verificarConexionAInternet()) {
      return const Scaffold(
        body: Center(
          child: Text('No hay conexión a internet'),
        ),
      );
    }

    final eventsJson = fetchEvents("/events");
    final events = EventInformationList.fromJson(eventsJson).events;

    // Obtener información del usuario actual
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(155),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "LiveTickets",
                        style: TextStyle(fontSize: 24),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.account_circle,
                            size: 28, color: appColor),
                        onSelected: (value) {
                          if (value == 'logout') {
                            _signOut();
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.email ?? 'Usuario',
                                  style: const TextStyle(
                                    color: appColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sesión activa',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 18),
                                SizedBox(width: 8),
                                Text('Cerrar Sesión'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchInput = value;
                          });
                        },
                        onTapOutside: (e) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          prefixIconColor: appColor,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: appColor,
                            ),
                          ),
                          hintText: 'Busca un evento',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Scrollbar(
          child: ListView(
            children: events
                .where(
                  (event) =>
                      searchInput == null ||
                      event.title
                          .toLowerCase()
                          .contains(searchInput!.toLowerCase()),
                )
                .map((event) => EventCard(data: event))
                .toList(),
          ),
        ),
      ),
    );
  }
}
