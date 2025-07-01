import 'package:flutter/material.dart';
import 'package:mobile_app/colors.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/widgets/user_data.dart';

class BuyTicket extends StatefulWidget {
  final String title;
  final String image;
  final double price;
  final DateTime date;

  const BuyTicket(
      {super.key,
      required this.title,
      required this.image,
      required this.price,
      required this.date});

  @override
  State<BuyTicket> createState() => _BuyTicketState();
}

class _BuyTicketState extends State<BuyTicket> {
  int _ticketCount = 1;

  void _incrementCounter() {
    setState(() {
      _ticketCount++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_ticketCount > 0) {
        _ticketCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_cart),
            SizedBox(width: 8),
            Text('Compra de boletos'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Image.network(widget.image, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: appColor,
                    ),
                    onPressed: () {
                      _decrementCounter();
                    },
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.event_seat, size: 24),
                  const SizedBox(width: 8),
                  Text('$_ticketCount', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: appColor,
                    ),
                    onPressed: () {
                      _incrementCounter();
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Total: S/ ${widget.price * _ticketCount}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(appColor)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmForm(
                            ticketCount: _ticketCount,
                            title: widget.title,
                            price: widget.price,
                            image: widget.image,
                            date: widget.date,
                          ),
                        ),
                      );
                    },
                    child: const Text('Confirmar Compra',
                        style: TextStyle(fontSize: 20, color: Colors.black))),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Home()));
                    },
                    child: const Text('Cancelar Compra',
                        style: TextStyle(fontSize: 20, color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
