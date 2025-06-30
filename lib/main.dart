import 'package:flutter/material.dart';
import 'package:live_tickets/backend.dart';
import 'package:live_tickets/colors.dart';
import 'package:live_tickets/connection.dart';
import 'package:live_tickets/schemas.dart';
import 'package:live_tickets/widgets/event_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? searchInput;

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(135),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event_seat, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "LiveTickets",
                        style: TextStyle(fontSize: 24),
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
