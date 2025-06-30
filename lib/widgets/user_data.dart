import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:live_tickets/main.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ConfirmForm extends StatefulWidget {
  final int ticketCount;
  final String title;
  final double price;
  final String image;
  final DateTime date;

  const ConfirmForm(
      {super.key,
      required this.ticketCount,
      required this.title,
      required this.price,
      required this.image,
      required this.date});

  @override
  State<ConfirmForm> createState() => _ConfirmFormState();
}

class _ConfirmFormState extends State<ConfirmForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  Future<File> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/event_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Error al descargar la imagen: ${response.statusCode}');
    }
  }

  Future<File> _generateQrCode() async {
    final qrData = '''
      Evento: ${widget.title}
      Cantidad: ${widget.ticketCount}
      Total: S/ ${widget.price * widget.ticketCount}
    ''';

    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: false,
    ).toImage(300);

    final ByteData? byteData =
        await qrImage.toByteData(format: ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final qrFile = File('${tempDir.path}/ticket_qr.png');
    await qrFile.writeAsBytes(bytes);

    return qrFile;
  }

  Future<void> sendEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String userName = _nameController.text;
    final String userEmail = _emailController.text;

    try {
      final imageFile = await _downloadImage(widget.image);
      final qrFile = await _generateQrCode();

      String username = 'timmyprotection@gmail.com';
      String password = 'qmmv qwwq ipcx jfhz';

      final smtpServer = gmail(username, password);
      final formattedDate =
          DateFormat('dd/MM/yyyy – HH:mm a').format(widget.date);
      final message = Message()
        ..from = Address(username, 'Live Tickets')
        ..recipients.add(userEmail)
        ..subject = 'Confirmación de Compra: ${widget.title}'
        ..html = '''
        <h1>Gracias por tu compra, $userName!</h1>
        <p>Detalles de tu compra:</p>
        <ul>
          <li><strong>Evento:</strong> ${widget.title}</li>
          <li><strong>Fecha:</strong> $formattedDate</li>
          <li><strong>Precio unitario:</strong> S/ ${widget.price}</li>
          <li><strong>Cantidad de boletos:</strong> ${widget.ticketCount}</li>
          <li><strong>Total:</strong> S/ ${widget.price * widget.ticketCount}</li>
        </ul>
        <p><img src="cid:event_image"></p>
        <p><strong>Escanea el siguiente QR para obtener los detalles de tu compra:</strong></p>
        <p><img src="cid:qr_code"></p>
      '''
        ..attachments = [
          FileAttachment(imageFile)
            ..location = Location.inline
            ..cid = 'event_image',
          FileAttachment(qrFile)
            ..location = Location.inline
            ..cid = 'qr_code',
        ];

      await send(message, smtpServer);
      _showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el correo: $e')),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 10), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _redirectToHome(context);
          }
        });

        return AlertDialog(
          title: const Text('¡Correo enviado con éxito!'),
          content: const Text(
              'Hemos enviado los detalles de tu compra a tu correo electrónico.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _redirectToHome(context);
              },
              child: const Text('Ir a la página principal'),
            ),
          ],
        );
      },
    );
  }

  void _redirectToHome(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmación de Compra')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Evento: ${widget.title}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200, // Tamaño fijo para la imagen.
                          child: Image.network(widget.image, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Cantidad: ${widget.ticketCount}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Total: S/ ${widget.price * widget.ticketCount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Nombre'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa tu correo electrónico';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Por favor, ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => sendEmail(context),
                          child: const Text('Enviar Confirmación por Correo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
